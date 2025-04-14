// lib/pages/movie_details/bloc/movie_details_state.dart

import 'package:equatable/equatable.dart';
import '../../../models/movie_details.dart'; // <-- Use MovieDetails model
import '../../../models/credit.dart';       // <-- Add Credits model
import '../../../models/video.dart';        // <-- Add Video model

// حالة تحميل تفاصيل الفيلم
enum MovieDetailsStatus { initial, loading, success, failure }

class MovieDetailsState extends Equatable {
  final MovieDetailsStatus status;
  final MovieDetails? movieDetails; // <-- Changed from Movie to MovieDetails
  final Credits? credits;          // <-- Added Credits
  final List<Video> videos;        // <-- Added Videos
  final String? errorMessage;

  const MovieDetailsState({
    this.status = MovieDetailsStatus.initial,
    this.movieDetails,
    this.credits,
    this.videos = const [], // Default to empty list
    this.errorMessage,
  });

  MovieDetailsState copyWith({
    MovieDetailsStatus? status,
    MovieDetails? movieDetails, // <-- Updated type
    Credits? credits,          // <-- Added Credits
    List<Video>? videos,       // <-- Added Videos
    String? errorMessage,
    bool clearError = false,
  }) {
    return MovieDetailsState(
      status: status ?? this.status,
      movieDetails: movieDetails ?? this.movieDetails,
      credits: credits ?? this.credits,       // <-- Added Credits
      videos: videos ?? this.videos,         // <-- Added Videos
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movieDetails, // <-- Updated property
    credits,      // <-- Added property
    videos,       // <-- Added property
    errorMessage,
  ];
}