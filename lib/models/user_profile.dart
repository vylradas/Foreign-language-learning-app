class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl; 
  final List<UserLanguageProgress> languages;
  final int streak;
  String activeLanguageCode;
  final String? interfaceLocale;

  UserProfile({
    required this.id,
    required this.name,
    required this.languages,
    required this.streak,
    this.avatarUrl,
    required this.activeLanguageCode,
    this.interfaceLocale,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    streak: json['streak'] ?? 0,
    languages: (json['languages'] as List)
        .map((e) => UserLanguageProgress.fromJson(e))
        .toList(),
    avatarUrl: json['avatarUrl'],
    activeLanguageCode: json['activeLanguageCode'],
    interfaceLocale: json['interfaceLocale'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'streak': streak,
    'languages': languages.map((e) => e.toJson()).toList(),
    'avatarUrl': avatarUrl,
    'activeLanguageCode': activeLanguageCode,
    'interfaceLocale': interfaceLocale,
  };
}

class UserLanguageProgress {
  final String languageCode; // 'en', 'de', 'uk' тощо
  final int lessonsCompleted;
  final int totalPoints;

  UserLanguageProgress({
    required this.languageCode,
    required this.lessonsCompleted,
    required this.totalPoints,
  });

  factory UserLanguageProgress.fromJson(Map<String, dynamic> json) => UserLanguageProgress(
    languageCode: json['languageCode'],
    lessonsCompleted: json['lessonsCompleted'] ?? 0,
    totalPoints: json['totalPoints'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'languageCode': languageCode,
    'lessonsCompleted': lessonsCompleted,
    'totalPoints': totalPoints,
  };
}