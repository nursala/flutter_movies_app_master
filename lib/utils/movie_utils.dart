import 'package:flutter/material.dart';
import '../models/credit.dart';
import '../config/constants.dart';

class MovieUtils {
  static String getDirector(List<CrewMember> crew) {
    final director = crew.firstWhere(
          (member) => member.job == 'Director',
      orElse: () => CrewMember(id: 0, name: kUnknownLabel, job: ''),
    );
    return director.name;
  }

  static String getWriter(List<CrewMember> crew) {
    final writer = crew.firstWhere(
          (member) =>
      member.job.toLowerCase().contains('writer') ||
          member.job.toLowerCase().contains('screenplay'),
      orElse: () => CrewMember(id: 0, name: kUnknownLabel, job: ''),
    );
    return writer.name;
  }

  /// ✅ ترجمة نوع المحتوى حسب اللغة المعطاة
  static String getMediaTypeLabelByLang(String type, String langCode) {
    final translations = mediaTypeTranslations[langCode] ?? mediaTypeTranslations['en']!;
    return translations[type] ?? type;
  }
}
