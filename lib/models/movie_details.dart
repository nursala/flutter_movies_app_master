// lib/models/movie_details.dart
import 'genre.dart';
import '../config/constants.dart'; // Needed for kNoDescriptionLabel, tmdbImageBaseUrl

class MovieDetails {
  final int id;
  final String title;
  late String overview; // Keep late final if updated in cubit fallback
  final int? runtime;
  final String releaseDate;
  final List<Genre> genres;
  final String? backdropPath; // <-- ADDED
  final double voteAverage; // <-- ADDED

  MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    this.runtime,
    required this.releaseDate,
    required this.genres,
    this.backdropPath, // <-- ADDED to constructor
    required this.voteAverage, // <-- ADDED to constructor
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json, String mediaType) {
    return MovieDetails(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '', // Handle movie/tv title
      overview: json['overview'] ?? kNoDescriptionLabel, // Use constant for missing overview
      runtime: json['runtime'],
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '', // Handle movie/tv date
      genres: (json['genres'] as List? ?? [])
          .map((g) => Genre.fromJson(g))
          .toList(),
      backdropPath: json['backdrop_path'], // <-- PARSE backdrop_path
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(), // <-- PARSE vote_average
    );
  }

  // Calculated properties remain the same
  String get releaseYear =>
      releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '';

  String get fullBackdropUrl => backdropPath != null
      ? '$tmdbImageBaseUrl$backdropPath'
      : ''; // Provide a default or handle missing image later
}