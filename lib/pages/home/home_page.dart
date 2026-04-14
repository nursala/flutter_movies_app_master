// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'bloc/home_bloc.dart';
import 'bloc/home_state.dart';
// ---------------------------------

import '../../models/movie.dart';
import '../../models/genre.dart';
import '../../widgets/movie_grid_item.dart';
import '../../widgets/dropdown_filters.dart';
import '../../config/constants.dart';
import '../../services/tmdb_service.dart';
import '../../utils/movie_utils.dart'; // Import utils

class MovieHomePage extends StatelessWidget {
  const MovieHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>( // <-- Change type to HomeBloc
      create: (context) => HomeBloc(context.read<TmdbService>()) // <-- Create HomeBloc and pass the service
        ..add(HomeLoadInitialDataEvent()),
      child: const _MovieHomeView(),
    );
  }
}

class _MovieHomeView extends StatefulWidget {
  const _MovieHomeView();

  @override
  State<_MovieHomeView> createState() => _MovieHomeViewState();
}

class _MovieHomeViewState extends State<_MovieHomeView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    final initialQuery = context.read<HomeBloc>().state.searchQuery; // <-- Change type to HomeBloc
    _searchController.text = initialQuery;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<HomeBloc>().add(HomeLoadMoreMoviesEvent()); // <-- Change function call to adding an event
      // -----------------------------
    }
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text;
      debugPrint("🔍 HomePage: Search changed, sending query to Bloc: '$query'"); // <-- Changed Cubit to Bloc in the text
      if (mounted) {
        // --- Send search change event ---
        context.read<HomeBloc>().add(HomeSearchQueryChangedEvent(query)); // <-- Change function call to adding an event
        // ---------------------------
      }
    });

  }

  void _clearSearch() {
    _searchController.clear();
  }

  Map<int, String> _buildGenreMap(List<Genre> genres) {
    return {for (var genre in genres) genre.id: genre.name};
  }

  List<String> _getGenreNamesForMovie(Movie movie, Map<int, String> genreMap) {
    return movie.genreIds.map((id) => genreMap[id] ?? kUnknownGenreLabel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final String currentLang = context.read<TmdbService>().getCurrentLanguage();
    final String moviesLabel = MovieUtils.getMediaTypeLabelByLang('movie', currentLang);
    final String tvShowsLabel = MovieUtils.getMediaTypeLabelByLang('tv', currentLang);
    final String popularLabel = kLabels[currentLang]?['popular'] ?? kLabels['en']!['popular'] ?? kPopularLabel;
    final String nowPlayingLabel = kLabels[currentLang]?['now_playing'] ?? kLabels['en']!['now_playing'] ?? kNowPlayingLabel;
    final String upcomingLabel = kLabels[currentLang]?['upcoming'] ?? kLabels['en']!['upcoming'] ?? kUpcomingLabel;
    final String topRatedLabel = kLabels[currentLang]?['top_rated'] ?? kLabels['en']!['top_rated'] ?? kTopRatedLabel;
    final String allGenresLabel = kLabels[currentLang]?['all_genres'] ?? kLabels['en']!['all_genres'] ?? kAllGenresLabel;

    final sortLabels = {
      'popular': popularLabel,
      'now_playing': nowPlayingLabel,
      'upcoming': upcomingLabel,
      'top_rated': topRatedLabel,
    };


    return Scaffold(
      appBar: AppBar(
        title: Text(kLabels[currentLang]?['app_title'] ?? kLabels['en']!['app_title'] ?? kAppTitle),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 4.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: kSearchHint,
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          _searchController.text.isNotEmpty?IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
            tooltip: 'Clear search',
          ): IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: kSearchHint,
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<HomeBloc, HomeState>( // <-- Change type to HomeBloc
              buildWhen: (previous, current) =>
              previous.selectedType != current.selectedType ||
                  previous.selectedSort != current.selectedSort ||
                  previous.selectedGenreId != current.selectedGenreId ||
                  previous.genres != current.genres,
              builder: (context, state) {
                return DropdownFilters(
                  selectedType: state.selectedType,
                  selectedSort: state.selectedSort,
                  selectedGenreId: state.selectedGenreId,
                  genres: state.genres,
                  onTypeChanged: (type) => context.read<HomeBloc>().add(HomeTypeChangedEvent(type)),
                  onSortChanged: (sort) => context.read<HomeBloc>().add(HomeSortChangedEvent(sort)),
                  onGenreChanged: (id) => context.read<HomeBloc>().add(HomeGenreChangedEvent(id)),
                  // ------------------------------------------
                  typeLabels: {'movie': moviesLabel, 'tv': tvShowsLabel},
                  sortLabels: sortLabels,
                  allGenresLabel: allGenresLabel,
                );
              }
          ),
          Expanded(
            child: BlocConsumer<HomeBloc, HomeState>( // <-- Change type to HomeBloc
              listener: (context, state) {
                // No changes in listener logic
                if (state.errorMessage != null && !state.isLoadingMore && state.status != HomeStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("خطأ: ${state.errorMessage!}"),
                      backgroundColor: Colors.orange[800],
                    ),
                  );
                }
              },
              builder: (context, state) {
                // --- No major changes in the builder logic itself as it depends on State ---
                if (state.status == HomeStatus.loading && state.movies.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == HomeStatus.failure && state.movies.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: kDefaultPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("حدث خطأ:\n${state.errorMessage ?? kErrorLoadingData}",
                              textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            // --- تغيير استدعاء الدالة إلى إضافة حدث ---
                            onPressed: () => context.read<HomeBloc>().add(HomeLoadInitialDataEvent()),
                            // ------------------------------------------
                            child: const Text("إعادة المحاولة"),
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (state.movies.isEmpty && state.status == HomeStatus.success && !state.isLoadingMore) {
                  return Center(
                    child: Padding(
                      padding: kDefaultPadding,
                      child: Text(
                        state.isSearching
                            ? 'لا توجد نتائج بحث عن "${state.searchQuery}"'
                            : 'لا توجد بيانات تطابق هذه المعايير.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final genreMap = _buildGenreMap(state.genres);
                return Stack(
                  children: [
                    GridView.builder(
                      controller: _scrollController,
                      padding: kDefaultPadding,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2 / 3.5,
                      ),
                      itemCount: state.movies.length,
                      itemBuilder: (context, index) {
                        final movie = state.movies[index];
                        final genreNames = _getGenreNamesForMovie(movie, genreMap);
                        return MovieGridItem(
                          movie: movie,
                          genreNames: genreNames,
                        );
                      },
                    ),
                    if (state.isLoadingMore)
                      Positioned(
                        bottom: 16, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}