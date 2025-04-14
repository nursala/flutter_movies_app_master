// lib/models/credit.dart
import '../config/constants.dart';

class Credits {
  final int id;
  final List<CastMember> cast;
  final List<CrewMember> crew;

  Credits({required this.id, required this.cast, required this.crew});

  factory Credits.fromJson(Map<String, dynamic> json) {
    return Credits(
      id: json['id'],
      cast: (json['cast'] as List? ?? [])
          .map((v) => CastMember.fromJson(v))
          .toList(),
      crew: (json['crew'] as List? ?? [])
          .map((v) => CrewMember.fromJson(v))
          .toList(),
    );
  }
}

class CastMember {
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  CastMember({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  String get fullProfileUrl => profilePath != null
      ? '$tmdbImageBaseUrl$profilePath'
      : ''; // Add a placeholder image URL if needed

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'],
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      character: json['character'] ?? '',
    );
  }
}

class CrewMember {
  final int id;
  final String name;
  final String job;

  CrewMember({
    required this.id,
    required this.name,
    required this.job,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'],
      name: json['name'] ?? '',
      job: json['job'] ?? '',
    );
  }
}

