// lib/pages/movie_details/bloc/movie_details_event.dart

part of 'movie_details_bloc.dart';

@immutable
abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object> get props => [];
}

// حدث لتحميل تفاصيل فيلم معين
class LoadMovieDetailsEvent extends MovieDetailsEvent {
  final int movieId;

  const LoadMovieDetailsEvent(this.movieId);

  @override
  List<Object> get props => [movieId];
}

// يمكنك إضافة أحداث أخرى هنا لاحقاً
// مثل AddToFavoritesEvent, RateMovieEvent etc.