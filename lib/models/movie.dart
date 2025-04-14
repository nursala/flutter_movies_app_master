// lib/models/movie.dart
import '../config/constants.dart';

class Movie {
  final int id;
  final String title; // Handles both movie title and TV name
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseYear; // Extracts only the year
  final double voteAverage;
  final List<int> genreIds;
  final String mediaType; // 'movie' or 'tv'

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseYear,
    required this.voteAverage,
    required this.genreIds,
    required this.mediaType,
  });

  String get fullPosterUrl => posterPath != null
      ? '$tmdbImageBaseUrl$posterPath'
      : ''; // Provide a default or handle missing image later

  String get fullBackdropUrl => backdropPath != null
      ? '$tmdbImageBaseUrl$backdropPath'
      : '';

  factory Movie.fromJson(Map<String, dynamic> json, String type) {
    // Determine title and release date based on type
    String title = json['title'] ?? json['name'] ?? 'No Title';
    String dateString = json['release_date'] ?? json['first_air_date'] ?? '';
    String year = dateString.isNotEmpty ? dateString.substring(0, 4) : '';

    return Movie(
      id: json['id'],
      title: title,
      overview: json['overview'] ?? kNoDescriptionLabel,
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseYear: year,
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      mediaType: type, // Store the type ('movie' or 'tv')
    );
  }

  // Method to update overview if needed (used by TmdbService)
  Movie copyWith({String? overview}) {
    return Movie(
      id: id,
      title: title,
      overview: overview ?? this.overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseYear: releaseYear,
      voteAverage: voteAverage,
      genreIds: genreIds,
      mediaType: mediaType,
    );
}}


