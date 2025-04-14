// lib/services/tmdb_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// افترض أن هذه الملفات موجودة في المسارات الصحيحة
import '../config/constants.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../models/credit.dart';
import '../models/video.dart';

// استثناء مخصص لأخطاء واجهة برمجة تطبيقات TMDb
class TmdbApiException implements Exception {
  final String message;
  TmdbApiException(this.message);

  @override
  String toString() => message;
}

// خدمة للتفاعل مع واجهة برمجة تطبيقات TMDb
class TmdbService {
  late final Dio _dio;
  final String defaultLanguage; // اللغة الافتراضية إذا لم يتم تمرير لغة أخرى

  // Constructor: يقبل لغة افتراضية (الافتراضي هنا هو 'ar')
  TmdbService({this.defaultLanguage = 'en'}) {
    _dio = Dio(BaseOptions(
      baseUrl: tmdbApiBaseUrl,
      queryParameters: {
        'api_key': tmdbApiKey,
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  // جلب قائمة الميديا (أفلام أو مسلسلات)
  Future<List<Movie>> fetchMedia({
    required String type,
    required String sortBy,
    int page = 1,
    int? genreId,
    String? language,
  }) async {
    final String effectiveLanguage = language ?? defaultLanguage;

    try {
      String endpoint;
      final Map<String, dynamic> queryParams = {
        'language': effectiveLanguage, // <-- استخدام اللغة الصحيحة
        'page': page,
      };

      if (genreId != null) {
        endpoint = 'discover/$type';
        queryParams['with_genres'] = genreId.toString();
        queryParams['sort_by'] = 'popularity.desc';
      } else {
        final endpoints = type == 'movie' ? movieEndpoints : tvEndpoints;
        endpoint = endpoints[sortBy] ?? (type == 'movie' ? 'movie/popular' : 'tv/popular');
      }

      // --- جملة تحقق إضافية ---
      debugPrint("  [Check] fetchMedia: Making API call to '/$endpoint' with language='${queryParams['language']}'");
      // --- نهاية جملة التحقق ---
      final response = await _dio.get('/$endpoint', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] ?? [];
        List<Movie> mediaList = [];

        for (var itemJson in results) {
          Movie mediaItem = Movie.fromJson(itemJson, type);
          // الجزء الخاص بالوصف الاحتياطي معطل حاليًا
          /*
          if ((mediaItem.overview.trim().isEmpty || mediaItem.overview == kNoDescriptionLabel) &&
              effectiveLanguage != 'en') {
            try {
              // ملاحظة: الاستدعاء التالي لـ fetchFullDetails سيحتوي على جملة تحقق خاصة به
              final details = await fetchFullDetails(type: type, id: mediaItem.id, language: 'en');
              final overviewEn = details['overview']?.toString() ?? '';
              if (overviewEn.isNotEmpty) {
                mediaItem = mediaItem.copyWith(overview: overviewEn);
              }
            } catch (e) {
              debugPrint("⚠️ Failed overview fallback for ${mediaItem.id}: $e");
            }
          }
          */
          mediaList.add(mediaItem);
        }
        return mediaList;
      } else {
        throw TmdbApiException('Failed to load media list: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioError fetching media ($type/$sortBy): ${e.message}');
      throw TmdbApiException(kErrorLoadingData ?? 'Network error occurred.');
    } catch (e) {
      debugPrint('Error fetching media: $e');
      throw TmdbApiException(kErrorLoadingData ?? 'Error loading data.');
    }
  }

  // البحث في الميديا
// --- دالة البحث في الميديا ---
  Future<List<Movie>> searchMedia({
    required String type,    // 'movie' or 'tv'
    required String query,   // نص البحث
    int page = 1,          // رقم الصفحة
    String? language,      // اللغة المطلوبة (سيتم استخدام اللغة الافتراضية للخدمة إذا كانت null)
  }) async {
    // التحقق من أن نص البحث غير فارغ بعد إزالة المسافات
    if (query.trim().isEmpty) {
      debugPrint("⚠️ TmdbService.searchMedia: Search query is empty, returning empty list.");
      return [];
    }

    // تحديد اللغة الفعالة
    final String effectiveLanguage = language ?? defaultLanguage;

    // [طباعة أساسية]

    try {
      const String endpointBase = 'search';
      final String endpoint = '$endpointBase/$type';

      // معاملات الاستعلام
      final Map<String, dynamic> queryParams = {
        'language': effectiveLanguage,
        'page': page,
        'query': query,
        'include_adult': 'false',
      };

      // [طباعة تحقق]
      debugPrint("  [Check] searchMedia: Making API call to '/$endpoint' with language='${queryParams['language']}', query='${queryParams['query']}', page=${queryParams['page']}");

      // تنفيذ طلب GET
      final response = await _dio.get('/$endpoint', queryParameters: queryParams);

      // [طباعة استجابة]
      debugPrint("  [Response] searchMedia: Status Code: ${response.statusCode}");

      // التحقق من نجاح الطلب والبيانات
      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] ?? []; // results is List<dynamic>
        debugPrint("  [Response Data] searchMedia: Received ${results.length} results.");

        // --- START OF CHANGE ---
        // Explicitly create the List<Movie> using List.from for stronger typing
        final List<Movie> movies = List<Movie>.from(results.map((json) {
          // Optional: Add a try-catch here if Movie.fromJson might fail for specific items
          try {
            // Ensure json is actually a Map<String, dynamic> before passing
            if (json is Map<String, dynamic>) {
              return Movie.fromJson(json, type);
            } else {
              // Handle cases where an item in 'results' is not a map
              debugPrint("⚠️ Skipping non-map item in search results: $json");
              // Return a placeholder or handle appropriately - returning null here would break List<Movie>.from
              // Throwing an error or skipping seems better. Let's throw to indicate bad data.
              throw FormatException("Invalid item format in search results: $json");
            }
          } catch (e) {
            debugPrint("⚠️ Error parsing movie item: $json. Error: $e");
            // Rethrow the error to be caught by the outer catch block
            rethrow;
          }
        }));
        // --- END OF CHANGE ---

        // Return the correctly typed list
        return movies;

      } else {
        // رمي استثناء مخصص في حالة فشل الطلب
        throw TmdbApiException('Failed to search media: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      // التعامل مع أخطاء Dio
      debugPrint("DioError searching media ('$query'): ${e.message}");
      if (e.response != null) {
        debugPrint("  -> DioError Status Code: ${e.response?.statusCode}");
        debugPrint("  -> DioError Response Data: ${e.response?.data}");
      }
      throw TmdbApiException(kErrorLoadingData ?? 'Network error occurred.');
    } catch (e) {
      // التعامل مع أي أخطاء أخرى (including errors from Movie.fromJson or the List.from conversion)
      debugPrint("Error searching media ('$query'): $e");
      debugPrintStack(stackTrace: StackTrace.current, label: 'StackTrace for searchMedia error');
      throw TmdbApiException(kErrorLoadingData ?? 'Error processing search data.');
    }
  }
  // --- نهاية دالة البحث ---

  // جلب الأنواع (Genres)
  Future<List<Genre>> fetchGenres({
    required String type,
    String? language,
  }) async {
    final String effectiveLanguage = language ?? defaultLanguage;

    try {
      final queryParams = {'language': effectiveLanguage};
      final endpoint = '/genre/$type/list';

      // --- جملة تحقق إضافية ---
      debugPrint("  [Check] fetchGenres: Making API call to '$endpoint' with language='${queryParams['language']}'");
      // --- نهاية جملة التحقق ---
      final response = await _dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['genres'] ?? [];
        return List<Genre>.from(results.map((json) => Genre.fromJson(json)));
      } else {
        throw TmdbApiException('Failed to load genres: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioError fetching genres: ${e.message}');
      throw TmdbApiException(kErrorLoadingData ?? 'Network error occurred.');
    } catch (e) {
      debugPrint('Error fetching genres: $e');
      throw TmdbApiException(kErrorLoadingData ?? 'Error loading data.');
    }
  }

  // جلب التفاصيل الكاملة لعنصر معين
  Future<Map<String, dynamic>> fetchFullDetails({
    required String type,
    required int id,
    String? language,
  }) async {
    final String effectiveLanguage = language ?? defaultLanguage;

    try {
      final queryParams = {'language': effectiveLanguage};
      final endpoint = '/$type/$id';

      // --- جملة تحقق إضافية ---
      debugPrint("  [Check] fetchFullDetails: Making API call to '$endpoint' with language='${queryParams['language']}'");
      // --- نهاية جملة التحقق ---
      final response = await _dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw TmdbApiException('Failed to load full details ($type/$id): Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioError fetching full details ($type/$id): ${e.message}');
      throw TmdbApiException(kErrorLoadingData ?? 'Network error occurred.');
    } catch (e) {
      debugPrint('Error fetching full details ($type/$id): $e');
      throw TmdbApiException(kErrorLoadingData ?? 'Error loading data.');
    }
  }

  // جلب فريق العمل (Credits) - لا يتطلب لغة في الطلب
  Future<Credits> fetchCredits({
    required String type,
    required int id,
    String? language, // غير مستخدم بواسطة API
  }) async {
    final String effectiveLanguage = language ?? defaultLanguage;

    try {
      final endpoint = '/$type/$id/credits';
      // --- لا توجد جملة تحقق للغة هنا لأنها لا تُرسل ---
      debugPrint("  [Check] fetchCredits: Making API call to '$endpoint' (language parameter not applicable)");
      final response = await _dio.get(endpoint); // لا نمرر language

      if (response.statusCode == 200 && response.data != null) {
        return Credits.fromJson(response.data);
      } else {
        throw TmdbApiException('Failed to load credits ($type/$id): Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioError fetching credits ($type/$id): ${e.message}');
      throw TmdbApiException(kErrorLoadingData ?? 'Network error occurred.');
    } catch (e) {
      debugPrint('Error fetching credits ($type/$id): $e');
      throw TmdbApiException(kErrorLoadingData ?? 'Error loading data.');
    }
  }

  // جلب الفيديوهات (مثل الإعلانات)
  Future<List<Video>> fetchVideos({required String type, required int id}) async {
    List<dynamic>? resultsLang1, resultsEn;
    final lang1 = defaultLanguage;

    try {
      // 1. محاولة اللغة الأولى
      try {
        final queryParams1 = {'language': lang1};
        final endpoint = '/$type/$id/videos';
        // --- جملة تحقق إضافية ---
        debugPrint("  [Check] fetchVideos: Making API call (Attempt 1) to '$endpoint' with language='${queryParams1['language']}'");
        // --- نهاية جملة التحقق ---
        final response1 = await _dio.get(endpoint, queryParameters: queryParams1);
        if (response1.statusCode == 200 && response1.data != null) {
          resultsLang1 = response1.data['results'];
        }
      } catch (e) {
        debugPrint("⚠️ Failed to fetch '$lang1' videos (proceeding to English fallback): $e");
      }

      // 2. محاولة اللغة الإنجليزية كاحتياطي
      if ((resultsLang1 == null || resultsLang1.isEmpty) && lang1 != 'en') {
        try {
          final queryParamsEn = {'language': 'en'};
          final endpoint = '/$type/$id/videos';
          // --- جملة تحقق إضافية ---
          debugPrint("  [Check] fetchVideos: Making API call (Attempt 2 - Fallback) to '$endpoint' with language='${queryParamsEn['language']}'");
          // --- نهاية جملة التحقق ---
          final responseEn = await _dio.get(endpoint, queryParameters: queryParamsEn);
          if (responseEn.statusCode == 200 && responseEn.data != null) {
            resultsEn = responseEn.data['results'];
          }
        } catch (e) {
          debugPrint("⚠️ Failed to fetch English fallback videos: $e");
          if (resultsLang1 == null) throw TmdbApiException('Failed to load videos in primary or fallback language.');
        }
      }

      final results = resultsLang1?.isNotEmpty == true ? resultsLang1 : (resultsEn ?? []);
      return results?.map((json) => Video.fromJson(json)).toList() ?? [];
    } on DioException catch (e) {
      debugPrint('DioError fetching videos ($type/$id): ${e.message}');
      throw TmdbApiException(kErrorLoadingData ?? 'Network error occurred.');
    } catch (e) {
      debugPrint('Error fetching videos ($type/$id): $e');
      if (e is TmdbApiException) rethrow;
      throw TmdbApiException(kErrorLoadingData ?? 'Error loading data.');
    }
  }

  String getCurrentLanguage() {
    return defaultLanguage;
  }

}