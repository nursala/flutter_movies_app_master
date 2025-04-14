// lib/pages/home/bloc/home_event.dart


part of 'home_bloc.dart'; // يربط بملف البلوك



@immutable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadInitialDataEvent extends HomeEvent {}

class HomeLoadMoreMoviesEvent extends HomeEvent {}

class HomeTypeChangedEvent extends HomeEvent {
  final String newType;
  const HomeTypeChangedEvent(this.newType);
  @override
  List<Object?> get props => [newType];
}

class HomeSortChangedEvent extends HomeEvent {
  final String newSort;
  const HomeSortChangedEvent(this.newSort);
  @override
  List<Object?> get props => [newSort];
}

class HomeGenreChangedEvent extends HomeEvent {
  final int? newGenreId;
  const HomeGenreChangedEvent(this.newGenreId);
  @override
  List<Object?> get props => [newGenreId];
}

class HomeSearchQueryChangedEvent extends HomeEvent {
  final String query;
  const HomeSearchQueryChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}