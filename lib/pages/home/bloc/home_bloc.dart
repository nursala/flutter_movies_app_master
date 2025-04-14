// lib/pages/home/bloc/home_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // لـ debugPrint
import 'package:meta/meta.dart';

import '../../../services/tmdb_service.dart'; // تأكد من صحة المسار
import '../../../models/movie.dart';       // تأكد من صحة المسار
import '../../../config/constants.dart';    // تأكد من صحة المسار
import 'home_state.dart';            // استيراد ملف الحالة

part 'home_event.dart'; // ربط ملف الأحداث

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TmdbService _tmdbService;

  String get _serviceLanguage => _tmdbService.defaultLanguage;

  HomeBloc(this._tmdbService) : super(const HomeState()) {

    on<HomeLoadInitialDataEvent>(_onLoadInitialData);
    on<HomeLoadMoreMoviesEvent>(_onLoadMoreMovies);
    on<HomeTypeChangedEvent>(_onTypeChanged);
    on<HomeSortChangedEvent>(_onSortChanged);
    on<HomeGenreChangedEvent>(_onGenreChanged);
    on<HomeSearchQueryChangedEvent>(_onSearchChanged);
  }

  // --- معالجات الأحداث ---

  Future<void> _onLoadInitialData(
      HomeLoadInitialDataEvent event, Emitter<HomeState> emit) async {
    if (state.status == HomeStatus.loading) return;
    emit(state.copyWith(
        status: HomeStatus.loading, currentPage: 1, movies: [],
        hasReachedMax: false, clearErrorMessage: true));
    try {
      final genres = await _tmdbService.fetchGenres(type: state.selectedType);
      final movies = await _fetchMediaPage(1);
      emit(state.copyWith(
          status: HomeStatus.success, movies: movies, genres: genres,
          currentPage: 1, hasReachedMax: movies.isEmpty));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: _handleError(e)));
    }
  }

  Future<void> _onLoadMoreMovies(
      HomeLoadMoreMoviesEvent event, Emitter<HomeState> emit) async {
    if (state.hasReachedMax || state.isLoadingMore || state.status == HomeStatus.loading) return;
    emit(state.copyWith(isLoadingMore: true, clearErrorMessage: true));
    try {
      final nextPage = state.currentPage + 1;
      final movies = await _fetchMediaPage(nextPage);
      emit(state.copyWith(
          movies: List.of(state.movies)..addAll(movies),
          currentPage: nextPage, hasReachedMax: movies.isEmpty,
          isLoadingMore: false));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: _handleError(e)));
    }
  }

  Future<void> _onTypeChanged(
      HomeTypeChangedEvent event, Emitter<HomeState> emit) async {
    if (event.newType == state.selectedType) return;
    emit(state.copyWith(
        selectedType: event.newType, selectedGenreId: null, clearGenreId: true,
        selectedSort: 'popular', currentPage: 1, genres: [], movies: [],
        searchQuery: '', isSearching: false, status: HomeStatus.initial,
        clearErrorMessage: true));
    add(HomeLoadInitialDataEvent()); // إضافة حدث لبدء التحميل من جديد
  }

  Future<void> _onSortChanged(
      HomeSortChangedEvent event, Emitter<HomeState> emit) async {
    if (event.newSort == state.selectedSort || state.selectedGenreId != null) return;
    emit(state.copyWith(selectedSort: event.newSort, currentPage: 1));
    await _fetchAndEmitFirstPage(emit); // استخدام دالة مساعدة
  }

  Future<void> _onGenreChanged(
      HomeGenreChangedEvent event, Emitter<HomeState> emit) async {
    if (event.newGenreId == state.selectedGenreId) return;
    emit(state.copyWith(
        selectedGenreId: event.newGenreId, clearGenreId: event.newGenreId == null,
        currentPage: 1));
    await _fetchAndEmitFirstPage(emit); // استخدام دالة مساعدة
  }

  Future<void> _onSearchChanged(
      HomeSearchQueryChangedEvent event, Emitter<HomeState> emit) async {
    final trimmedQuery = event.query.trim();
    if (trimmedQuery == state.searchQuery) return;
    emit(state.copyWith(
        searchQuery: trimmedQuery, isSearching: trimmedQuery.isNotEmpty,
        currentPage: 1));
    await _fetchAndEmitFirstPage(emit); // استخدام دالة مساعدة
  }

  // --- دوال مساعدة داخلية ---

  Future<List<Movie>> _fetchMediaPage(int page) async {
    final lang = _serviceLanguage;
    if (state.isSearching && state.searchQuery.isNotEmpty) {
      return await _tmdbService.searchMedia(
          type: state.selectedType, query: state.searchQuery, page: page, language: lang);
    } else {
      return await _tmdbService.fetchMedia(
          type: state.selectedType, sortBy: state.selectedSort, page: page,
          genreId: state.selectedGenreId, language: lang);
    }
  }

  Future<void> _fetchAndEmitFirstPage(Emitter<HomeState> emit) async {
    // أصبحنا نمرر emit لهذه الدالة
    if (!state.isSearching || state.movies.isEmpty) {
      emit(state.copyWith(status: HomeStatus.loading, movies: [],
          hasReachedMax: false, clearErrorMessage: true));
    } else {
      emit(state.copyWith(movies: [], hasReachedMax: false, clearErrorMessage: true));
    }
    try {
      final movies = await _fetchMediaPage(1);
      emit(state.copyWith(
          status: HomeStatus.success, movies: movies, currentPage: 1,
          hasReachedMax: movies.isEmpty));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: _handleError(e), movies: []));
    }
  }

  String _handleError(Object e) {
    if (e is TmdbApiException) {
      return e.message;
    }
    debugPrint("Unknown error in HomeBloc: $e");
    return kErrorLoadingData; // استخدام الثابت من ملف constants
  }
}