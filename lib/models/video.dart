// lib/models/video.dart
import '../config/constants.dart';

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type; // e.g., Trailer, Teaser

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  String? get youtubeUrl {
    if (site == 'YouTube' && key.isNotEmpty) {
      return '$youtubeBaseUrl$key';
    }
    return null;
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
    );
  }
}


