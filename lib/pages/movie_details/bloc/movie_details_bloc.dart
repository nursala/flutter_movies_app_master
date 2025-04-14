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
  final String _mediaType = 'movie'; // افترض أن التفاصيل للأفلام

  MovieDetailsBloc(this._tmdbService) : super(const MovieDetailsState()) {
    on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
      LoadMovieDetailsEvent event, Emitter<MovieDetailsState> emit) async {

    emit(state.copyWith(status: MovieDetailsStatus.loading, clearError: true));
    try {
      // --- تعديل لجلب اللغتين والدمج ---

      // 1. جلب البيانات باللغتين + الاعتمادات + الفيديوهات بالتوازي
      final results = await Future.wait([
        // جلب التفاصيل باللغة الافتراضية للخدمة
        _tmdbService.fetchFullDetails(
            type: _mediaType, id: event.movieId, language: _tmdbService.defaultLanguage),
        // جلب التفاصيل باللغة الإنجليزية كاحتياطي (إذا كانت اللغة الافتراضية ليست الإنجليزية)
        if (_tmdbService.defaultLanguage != 'en')
          _tmdbService.fetchFullDetails(
              type: _mediaType, id: event.movieId, language: 'en')
        else // إذا كانت اللغة الافتراضية هي الإنجليزية، لا داعي لجلبها مرة أخرى
          Future.value(null), // نضع قيمة null مؤقتة لت保持 بنية القائمة
        // جلب الاعتمادات (Credits)
        _tmdbService.fetchCredits(type: _mediaType, id: event.movieId),
        // جلب الفيديوهات (Videos)
        _tmdbService.fetchVideos(type: _mediaType, id: event.movieId),
      ]);

      // 2. استخلاص النتائج
      final detailsMapLang = results[0] as Map<String, dynamic>;
      // الخريطة الإنجليزية قد تكون null إذا كانت اللغة الافتراضية هي en
      final Map<String, dynamic>? detailsMapEn = results[1] as Map<String, dynamic>?;
      final credits = results[2] as Credits;
      final videos = results[3] as List<Video>;

      // 3. دمج الخريطتين (إذا لزم الأمر)
      final Map<String, dynamic> mergedDetailsMap = Map.from(detailsMapLang); // ابدأ باللغة المطلوبة

      if (detailsMapEn != null) {
        // قائمة الحقول النصية المحتملة التي نريد لها احتياطي إنجليزي
        const fieldsToCheck = ['overview', 'title', 'tagline']; // أضف أي حقول أخرى

        for (var field in fieldsToCheck) {
          // تحقق إذا كان الحقل فارغاً أو null في اللغة المطلوبة
          if (mergedDetailsMap[field] == null || (mergedDetailsMap[field] is String && (mergedDetailsMap[field] as String).trim().isEmpty)) {
            // إذا كان فارغاً، استخدم القيمة من الخريطة الإنجليزية إذا كانت موجودة وغير فارغة
            if (detailsMapEn[field] != null && (detailsMapEn[field] is String && (detailsMapEn[field] as String).trim().isNotEmpty)) {
              mergedDetailsMap[field] = detailsMapEn[field];
              debugPrint("🔄 Using English fallback for field '$field' for ID ${event.movieId}");
            }
          }
        }
      }

      // 4. تحويل الخريطة المدمجة إلى كائن MovieDetails
      final movieDetails = MovieDetails.fromJson(mergedDetailsMap, _mediaType);

      // 5. إصدار الحالة النهائية
      emit(state.copyWith(
        status: MovieDetailsStatus.success,
        movieDetails: movieDetails, // <-- استخدم الكائن المدمج
        credits: credits,
        videos: videos,
      ));
      // --- نهاية التعديل ---

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
    return kErrorLoadingData; // استخدم الثابت
  }
}