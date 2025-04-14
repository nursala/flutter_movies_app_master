// lib/pages/movie_details/movie_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

// --- استيراد ملفات Bloc الجديدة ---
import 'bloc/movie_details_bloc.dart';
import 'bloc/movie_details_state.dart';
// ---------------------------------

import '../../models/movie.dart'; // Base movie model passed in
import '../../models/credit.dart';
import '../../models/video.dart';
import '../../models/movie_details.dart'; // Updated model
import '../../services/tmdb_service.dart';
import '../../utils/movie_utils.dart';
import '../../config/constants.dart';


class MovieDetailsPage extends StatelessWidget {
  final Movie movie; // Base movie info passed for initial display/ID
  final List<String> genreNames; // Passed from home (can be removed if not needed before load)

  const MovieDetailsPage({
    super.key,
    required this.movie,
    required this.genreNames,
  });

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider should be above this in the widget tree (e.g., in app.dart)
    // final tmdbService = RepositoryProvider.of<TmdbService>(context); // No longer needed here

    return BlocProvider<MovieDetailsBloc>( // <-- Change to MovieDetailsBloc
      create: (context) => MovieDetailsBloc(context.read<TmdbService>()) // <-- Create Bloc
        ..add(LoadMovieDetailsEvent(movie.id)), // <-- Add initial event
      child: _MovieDetailView(
          movie: movie, // Pass initial movie data for fallback display
          initialGenreNames: genreNames // Pass initial genres
      ),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  final Movie movie; // Basic movie info for initial display fallback
  final List<String> initialGenreNames;

  const _MovieDetailView({required this.movie, required this.initialGenreNames});

  // Helper functions remain largely the same, just ensure they use the correct data source (state)

  String _getLang(BuildContext context) => context.read<TmdbService>().defaultLanguage;

  String _getLabel(BuildContext context, String key, String fallbackConstant) {
    final lang = _getLang(context);
    return kLabels[lang]?[key] ?? kLabels['en']?[key] ?? fallbackConstant;
  }

  String _formatRuntime(BuildContext context, int? totalMinutes) {
    if (totalMinutes == null || totalMinutes <= 0) {
      return kUnknownDurationLabel;
    }
    final duration = Duration(minutes: totalMinutes);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String result = '';
    final lang = _getLang(context);
    if (hours > 0) result += '$hours ${lang == 'ar' ? 'ساعات' : (lang == 'he' ? 'שעות' : 'h')}';
    if (minutes > 0) {
      if (result.isNotEmpty) result += ' ';
      result += '$minutes ${lang == 'ar' ? 'دقائق' : (lang == 'he' ? 'דקות' : 'min')}';
    }
    return result.isEmpty ? kUnknownDurationLabel : result;
  }

  Future<void> _launchTrailer(BuildContext context, List<Video> videos) async {
    debugPrint("Attempting to find trailer. Video list count: ${videos.length}"); // <-- طباعة عدد الفيديوهات

    final trailer = videos.firstWhere(
          (v) {
        // طباعة كل فيديو يتم التحقق منه (اختياري)
        // debugPrint("Checking video: name=${v.name}, type=${v.type}, site=${v.site}, key=${v.key}");
        return v.type == 'Trailer' && v.site == 'YouTube';
      },
      orElse: () {
        debugPrint("⚠️ No YouTube Trailer found in the list."); // <-- طباعة إذا لم يتم العثور عليه
        return Video(id: '', key: '', name: '', site: '', type: '');
      },
    );

    final url = trailer.youtubeUrl;
    debugPrint("Trailer found: key='${trailer.key}', site='${trailer.site}', name='${trailer.name}'"); // <-- طباعة تفاصيل التريلر
    debugPrint("Constructed URL: $url"); // <-- طباعة الرابط

    if (url != null) {
      try {
        debugPrint("Attempting to launch URL..."); // <-- طباعة قبل المحاولة
        if (!context.mounted) return;
        await launchUrlString(url, mode: LaunchMode.externalApplication);
        debugPrint("URL launch successful (or initiated)."); // <-- طباعة بعد المحاولة (قد لا تصل إذا حدث خطأ فوري)
      } catch (e) {
        debugPrint("🔴 Error launching URL: $e"); // <-- طباعة الخطأ هنا مهمة جداً
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$kFailedToOpenLinkLabel $url. Error: $e')), // <-- عرض الخطأ للمستخدم
          );
        }
      }
    } else {
      debugPrint("URL is null, cannot launch."); // <-- طباعة إذا كان الرابط null
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kNoTrailerAvailableLabel)),
        );
      }
    }
  }
  Widget _infoChip(BuildContext context, String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8)),
      label: Text(text, style: Theme.of(context).textTheme.bodySmall),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      side: BorderSide.none,
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String currentLang = _getLang(context);

    // Use BlocConsumer to listen and build
    return Scaffold(
      body: BlocConsumer<MovieDetailsBloc, MovieDetailsState>( // <-- Use BlocConsumer and MovieDetailsBloc
        listener: (context, state) {
          // Listener remains the same
          if (state.errorMessage != null && state.status != MovieDetailsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("خطأ: ${state.errorMessage!}"), backgroundColor: Colors.orange[800]),
            );
          }
        },
        builder: (context, state) {
          // --- Use the updated state properties ---
          final MovieDetails? details = state.movieDetails;
          final Credits? credits = state.credits;
          final List<Video> videos = state.videos;
          // --- Use the correct status enum ---
          final bool isLoading = state.status == MovieDetailsStatus.loading;
          final bool hasError = state.status == MovieDetailsStatus.failure;
          // ------------------------------------

          // Fallback logic using initial movie data remains similar
          final String displayTitle = details?.title ?? movie.title;
          final String displayOverview = details?.overview ?? movie.overview;
          final String displayBackdropUrl = details?.fullBackdropUrl.isNotEmpty == true
              ? details!.fullBackdropUrl
              : movie.fullBackdropUrl.isNotEmpty
              ? movie.fullBackdropUrl
              : movie.fullPosterUrl;
          final String displayReleaseYear = details?.releaseYear ?? movie.releaseYear;
          final double displayVoteAverage = details?.voteAverage ?? movie.voteAverage;
          final int? displayRuntime = details?.runtime;
          // Prioritize genres from detailed data if available
          final List<String> genresToDisplay = details != null && details.genres.isNotEmpty
              ? details.genres.map((g) => g.name).toList()
              : initialGenreNames;


          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    displayTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2)]),
                    overflow: TextOverflow.ellipsis, maxLines: 1,
                  ),
                  centerTitle: true,
                  titlePadding: const EdgeInsetsDirectional.only(bottom: 16.0),
                  background: Hero(
                    tag: '${movie.mediaType}_${movie.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: displayBackdropUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                          placeholder: (context, url) => Container(color: Colors.grey[900]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6), Colors.transparent,
                                Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0)
                              ],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  stretchModes: const [StretchMode.zoomBackground],
                ),
                actions: [
                  // Use MovieDetailsStatus for check
                  if (state.status == MovieDetailsStatus.success && videos.any((v) => v.type == 'Trailer' && v.site == 'YouTube'))
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline, size: 28, color: Colors.white),
                      tooltip: kShowTrailerLabel,
                      onPressed: () => _launchTrailer(context, videos),
                    ),
                ],
              ),

              // Loading/Error Indicators
              // Show loading only if details haven't loaded yet
              if (isLoading && details == null)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              // Show error only if details haven't loaded yet
              if (hasError && details == null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: kDefaultPadding,
                      // Consider adding a retry button here too
                      child: Text(state.errorMessage ?? kErrorLoadingData, textAlign: TextAlign.center),
                    ),
                  ),
                ),

              // Main Content Area
              // Show content if successfully loaded OR if it's not loading/erroring (allowing display of initial data before load)
              if (state.status == MovieDetailsStatus.success || (!isLoading && !hasError))
                SliverToBoxAdapter(
                  child: _buildLoadedContent( // Pass the actual loaded state data
                      context,
                      state, // Pass the full state
                      details, // Pass loaded details (nullable)
                      credits, // Pass loaded credits (nullable)
                      videos,  // Pass loaded videos
                      currentLang,
                      // Pass calculated display values
                      displayOverview: displayOverview,
                      displayReleaseYear: displayReleaseYear,
                      displayVoteAverage: displayVoteAverage,
                      displayRuntime: displayRuntime,
                      genresToDisplay: genresToDisplay
                  ),
                ),
            ],
          );
        },
      ),
    );
  }


  // Helper for loaded content - takes state data as parameters
  Widget _buildLoadedContent(
      BuildContext context,
      MovieDetailsState state, // Receive full state
      MovieDetails? details,
      Credits? credits,
      List<Video> videos,
      String currentLang,
      // Receive pre-calculated display values
          { required String displayOverview,
        required String displayReleaseYear,
        required double displayVoteAverage,
        required int? displayRuntime,
        required List<String> genresToDisplay}
      ) {

    // Calculate derived data based on available state.credits
    final String formattedRuntime = _formatRuntime(context, displayRuntime);
    final String director = credits != null ? MovieUtils.getDirector(credits.crew) : kUnknownLabel;
    final String writer = credits != null ? MovieUtils.getWriter(credits.crew) : kUnknownLabel;
    final List<CastMember> cast = credits?.cast ?? [];

    // Use constants map for labels
    final String storyLabel = _getLabel(context, 'story', kNoDescriptionLabel);
    final String directorLabel = _getLabel(context, 'director', kDirectorLabel);
    final String writerLabel = _getLabel(context, 'writer', 'Writer');
    final String castLabel = _getLabel(context, 'cast', kCastLabel);
    final String mediaTypeLabel = MovieUtils.getMediaTypeLabelByLang(movie.mediaType, currentLang);


    return Container(
      padding: kDefaultPadding.copyWith(top: 24, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Wrap( // Information chips
              spacing: 8,
              runSpacing: 4,
              children: [
                if (displayReleaseYear.isNotEmpty)
                  _infoChip(context, displayReleaseYear, Icons.calendar_today_outlined),
                _infoChip(context, mediaTypeLabel, Icons.local_movies_outlined),
                ...genresToDisplay.map((name) =>
                    _infoChip(context, name, Icons.label_outline)),
                if (displayRuntime != null && displayRuntime > 0)
                  _infoChip(context, formattedRuntime, Icons.timer_outlined),
                _infoChip(context, '${displayVoteAverage.toStringAsFixed(1)}/10 ⭐', Icons.star_border),
              ],
            ),
          ),

          _sectionTitle(context, storyLabel),
          Text(
            displayOverview.isNotEmpty ? displayOverview : kNoDescriptionLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5 ) ,
          ),

          if (director != kUnknownLabel) ...[
            _sectionTitle(context, directorLabel),
            Text(director, style: Theme.of(context).textTheme.bodyLarge),
          ],

          if (writer != kUnknownLabel) ...[
            _sectionTitle(context, writerLabel),
            Text(writer, style: Theme.of(context).textTheme.bodyLarge),
          ],


          if (cast.isNotEmpty) ...[
            _sectionTitle(context, castLabel),
            const SizedBox(height: 4),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: (context, index) {
                  final actor = cast[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: actor.fullProfileUrl.isNotEmpty
                              ? CachedNetworkImageProvider(actor.fullProfileUrl)
                              : null,
                          backgroundColor: Colors.grey[800],
                          child: actor.fullProfileUrl.isEmpty
                              ? const Icon(Icons.person, size: 45, color: Colors.white70)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actor.name,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          actor.character,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}