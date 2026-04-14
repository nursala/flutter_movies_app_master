// lib/pages/movie_details/bloc/movie_details_event.dart

part of 'movie_details_bloc.dart';

@immutable
abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object> get props => [];
}

// Event to load details for a specific movie
class LoadMovieDetailsEvent extends MovieDetailsEvent {
  final int movieId;

  const LoadMovieDetailsEvent(this.movieId);

  @override
  List<Object> get props => [movieId];
}

// You can add other events here later
// such as AddToFavoritesEvent, RateMovieEvent etc.