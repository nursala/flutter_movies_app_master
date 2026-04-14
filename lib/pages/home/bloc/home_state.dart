// lib/pages/home/bloc/home_state.dart

import 'package:equatable/equatable.dart';
import '../../../models/movie.dart'; // Make sure the path is correct
import '../../../models/genre.dart'; // Make sure the path is correct
import '../../../config/constants.dart'; // Make sure the path is correct

// Main loading states for the page
enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Movie> movies;
  final List<Genre> genres;
  final String selectedType;
  final String selectedSort;
  final int? selectedGenreId;
  final String searchQuery;
  final bool isSearching;
  final int currentPage;
  final bool isLoadingMore; // Loading state when scrolling down
  final bool hasReachedMax; // Has all available pages been loaded?
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.movies = const <Movie>[],
    this.genres = const <Genre>[],
    this.selectedType = 'movie', // Default value
    this.selectedSort = 'popular', // Default value
    this.selectedGenreId,
    this.searchQuery = '',
    this.isSearching = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Movie>? movies,
    List<Genre>? genres,
    String? selectedType,
    String? selectedSort,
    int? selectedGenreId,
    bool clearGenreId = false,
    String? searchQuery,
    bool? isSearching,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      genres: genres ?? this.genres,
      selectedType: selectedType ?? this.selectedType,
      selectedSort: selectedSort ?? this.selectedSort,
      selectedGenreId: clearGenreId ? null : selectedGenreId ?? this.selectedGenreId,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movies,
    genres,
    selectedType,
    selectedSort,
    selectedGenreId,
    searchQuery,
    isSearching,
    currentPage,
    isLoadingMore,
    hasReachedMax,
    errorMessage,
  ];
}