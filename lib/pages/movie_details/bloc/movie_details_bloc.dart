// lib/pages/movie_details/bloc/movie_details_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

import '../../../services/tmdb_service.dart';
import '../../../models/movie_details.dart';
import '../../../models/credit.dart';
import '../../../models/video.dart';
import '../../../config/constants.dart';
import 'movie_details_state.dart';

part 'movie_details_event.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final TmdbService _tmdbService;
  final String _mediaType = 'movie'; // Assume details are for movies

  MovieDetailsBloc(this._tmdbService) : super(const MovieDetailsState()) {
    on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
      LoadMovieDetailsEvent event, Emitter<MovieDetailsState> emit) async {

    emit(state.copyWith(status: MovieDetailsStatus.loading, clearError: true));
    try {
      // --- Modification to fetch both languages and merge ---

      // 1. Fetch data in both languages + credits + videos in parallel
      final results = await Future.wait([
        // Fetch details in the service's default language
        _tmdbService.fetchFullDetails(
            type: _mediaType, id: event.movieId, language: _tmdbService.defaultLanguage),
        // Fetch details in English as fallback (if the default language is not English)
        if (_tmdbService.defaultLanguage != 'en')
          _tmdbService.fetchFullDetails(
              type: _mediaType, id: event.movieId, language: 'en')
        else // If the default language is English, no need to fetch it again
          Future.value(null), // We put a temporary null value to maintain the list structure
        // Fetch credits
        _tmdbService.fetchCredits(type: _mediaType, id: event.movieId),
        // Fetch videos
        _tmdbService.fetchVideos(type: _mediaType, id: event.movieId),
      ]);

      // 2. Extract results
      final detailsMapLang = results[0] as Map<String, dynamic>;
      // The English map may be null if the default language is 'en'
      final Map<String, dynamic>? detailsMapEn = results[1] as Map<String, dynamic>?;
      final credits = results[2] as Credits;
      final videos = results[3] as List<Video>;

      // 3. Merge the two maps (if needed)
      final Map<String, dynamic> mergedDetailsMap = Map.from(detailsMapLang); // Start with the requested language

      if (detailsMapEn != null) {
        // List of potential text fields we want an English fallback for
        const fieldsToCheck = ['overview', 'title', 'tagline']; // Add any other fields

        for (var field in fieldsToCheck) {
          // Check if the field is empty or null in the requested language
          if (mergedDetailsMap[field] == null || (mergedDetailsMap[field] is String && (mergedDetailsMap[field] as String).trim().isEmpty)) {
            // If empty, use the value from the English map if it exists and is not empty
            if (detailsMapEn[field] != null && (detailsMapEn[field] is String && (detailsMapEn[field] as String).trim().isNotEmpty)) {
              mergedDetailsMap[field] = detailsMapEn[field];
              debugPrint("🔄 Using English fallback for field '$field' for ID ${event.movieId}");
            }
          }
        }
      }

      // 4. Convert the merged map to a MovieDetails object
      final movieDetails = MovieDetails.fromJson(mergedDetailsMap, _mediaType);

      // 5. Emit the final state
      emit(state.copyWith(
        status: MovieDetailsStatus.success,
        movieDetails: movieDetails, // <-- Use the merged object
        credits: credits,
        videos: videos,
      ));
      // --- End of modification ---

    } catch (e) {
      emit(state.copyWith(
        status: MovieDetailsStatus.failure,
        errorMessage: _handleError(e),
      ));
    }
  }

  String _handleError(Object e) {
    if (e is TmdbApiException) {
      return e.message;
    }
    debugPrint("Unknown error in MovieDetailsBloc: $e");
    return kErrorLoadingData; // Use the constant
  }
}