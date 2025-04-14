// lib/widgets/movie_grid_item.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Needed to read context

import '../models/movie.dart';
import '../pages/movie_details/movie_details_page.dart';
import '../config/constants.dart';
import '../services/tmdb_service.dart'; // To read service language
import '../utils/movie_utils.dart';

class MovieGridItem extends StatelessWidget {
  final Movie movie;
  final List<String> genreNames; // Still useful for passing to details page initially
  // REMOVED lang parameter

  const MovieGridItem({
    super.key,
    required this.movie,
    required this.genreNames,
    // required this.lang, // REMOVED
  });

  @override
  Widget build(BuildContext context) {
    // Get language from the service via context for UI consistency
    final String currentLang = context.read<TmdbService>().defaultLanguage;
    final mediaTypeLabel = MovieUtils.getMediaTypeLabelByLang(movie.mediaType, currentLang);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(
              movie: movie,
              genreNames: genreNames, // Pass initial genres
              // lang: lang, // REMOVED - Details page will get lang from context/service
            ),
          ),
        );
      },
      child: Hero(
        // Ensure Hero tag is unique per item type and ID
        tag: '${movie.mediaType}_${movie.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: movie.fullPosterUrl.isNotEmpty ? movie.fullPosterUrl : movie.fullBackdropUrl, // Fallback to backdrop
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[850]), // Placeholder color
                errorWidget: (context, url, error) => Container(
                    color: Colors.grey[850],
                    child: const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey))),
              ),

              // Gradient Overlay for Text Readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.8)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 0.7, 1.0], // Adjust gradient stops
                    ),
                  ),
                ),
              ),


              // Media Type Chip
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mediaTypeLabel, // Use localized label
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Rating Chip
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.yellowAccent, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title at the Bottom
              Positioned(
                bottom: 8, // Adjust padding
                left: 8,
                right: 8,
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Slightly smaller font
                    shadows: [Shadow(blurRadius: 1.0, color: Colors.black)], // Add shadow for readability
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}