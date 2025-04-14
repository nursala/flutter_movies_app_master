// lib/config/constants.dart
import 'package:flutter/material.dart';

// TMDB API Configuration
const String tmdbApiKey = 'ab2c96cc48c60d7838015ca2dc9a9180'; // استبدل بمفتاحك الخاص إذا لزم الأمر
const String tmdbApiBaseUrl = 'https://api.themoviedb.org/3';
const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
const String youtubeBaseUrl = 'https://www.youtube.com/watch?v=';

// UI Constants (Optional)
const EdgeInsets kDefaultPadding = EdgeInsets.all(16.0);

// Arabic Strings (Example, more can be added)
const String kAppTitle = '🎬 الأفلام';
const String kSearchHint = 'ابحث...';
const String kErrorLoadingData = 'فشل تحميل البيانات.';
const String kMoviesLabel = 'أفلام';
const String kTvShowsLabel = 'مسلسلات';
const String kPopularLabel = 'شائع';
const String kNowPlayingLabel = 'يعرض حالياً';
const String kUpcomingLabel = 'قادمة';
const String kTopRatedLabel = 'الأعلى تقييماً';
const String kAllGenresLabel = 'الكل';
const String kUnknownGenreLabel = 'غير معروف';
const String kShowTrailerLabel = 'عرض التريلر';
const String kNoTrailerAvailableLabel = '❌ لا يوجد تريلر متاح';
const String kFailedToOpenLinkLabel = '❌ فشل في فتح الرابط:';
const String kDirectorLabel = 'المخرج';
const String kCastLabel = 'الممثلون';
const String kUnknownLabel = 'غير معروف';
const String kNoDescriptionLabel = 'لا يوجد وصف.';
const String kMinutesSuffix = 'دقيقة';
const String kUnknownDurationLabel = 'مدة غير معروفة';

// Endpoints Maps (Moved here for clarity, could also be in TmdbService)
const Map<String, String> movieEndpoints = {
  'now_playing': 'movie/now_playing',
  'popular': 'movie/popular',
  'top_rated': 'movie/top_rated',
  'upcoming': 'movie/upcoming',
};

const Map<String, String> tvEndpoints = {
  'now_playing': 'tv/on_the_air', // Equivalent for TV
  'popular': 'tv/popular',
  'top_rated': 'tv/top_rated',
  'upcoming': 'tv/airing_today', // Equivalent for TV
};
const Map<String, Map<String, String>> kLabels = {
  'ar': {
    'app_title': '🎬 الأفلام',
    'story': 'القصة',
    'director': 'المخرج',
    'writer': 'الكاتب',
    'cast': 'الممثلون',
    'popular' : 'شائع',
    'now_playing' : 'يعرض حالياً',
    'upcoming' : 'قادمة',
    'top_rated' : 'الأعلى تقييماً',
    'all_genres' : 'الكل',
  },
  'en': {
    'app_title': '🎬 Movies',
    'story': 'Story',
    'director': 'Director',
    'writer': 'Writer',
    'cast': 'Cast',
    'popular' : 'Popular',
    'now_playing' : 'Now Playing',
    'upcoming' : 'Upcoming',
    'top_rated' : 'Top Rated',
    'all_genres' : 'All',
  },
  'he': {
    'app_title': '🎬 סרטים',
    'story': 'עלילה',
    'director': 'במאי',
    'writer': 'תסריטאי',
    'cast': 'שחקנים',
    'popular' : 'פופולרי',
    'now_playing' : 'משודר עכשיו',
    'upcoming' : 'קרוב',
    'top_rated' : 'הדירוג הגבוה ביותר',
    'all_genres' : 'הכל',
  },
};
const Map<String, Map<String, String>> mediaTypeTranslations = {
  'ar': {
    'movie': 'فيلم',
    'tv': 'مسلسل',
    'person': 'شخص',
  },
  'en': {
    'movie': 'Movie',
    'tv': 'TV Show',
    'person': 'Person',
  },
  'he': {
    'movie': 'סרט',
    'tv': 'סדרה',
    'person': 'אדם',
  },
};


