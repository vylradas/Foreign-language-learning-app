import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_iter/models/user_profile.dart';

void main() {
  group('UserLanguageProgress', () {
    final progress = UserLanguageProgress(
      languageCode: 'en',
      totalPoints: 100,
      completedLessons: ['lesson1', 'lesson2', 'lesson3', 'lesson4', 'lesson5'],
    );

    test('should create a UserLanguageProgress object correctly', () {
      expect(progress.languageCode, 'en');
      expect(progress.lessonsCompleted, 5);
      expect(progress.totalPoints, 100);
    });

    test('should correctly convert to JSON and back (serialization/deserialization)', () {
      final progressJson = progress.toJson();
      final progressFromJson = UserLanguageProgress.fromJson(progressJson);

      expect(progressFromJson.languageCode, 'en');
      expect(progressFromJson.lessonsCompleted, 5);
      expect(progressFromJson.totalPoints, 100);
    });
  });

  group('UserProfile', () {
    final initialProgress = UserLanguageProgress(
      languageCode: 'fr',
      totalPoints: 250,
      completedLessons: List.generate(10, (i) => 'lesson${i+1}'),
    );

    final profile = UserProfile(
      id: 'user1',
      name: 'Test User',
      languages: [initialProgress],
      streak: 3, 
      activeLanguageCode: 'english',
    );

    test('should create a UserProfile object correctly', () {
      expect(profile.id, 'user1');
      expect(profile.name, 'Test User');
      expect(profile.streak, 3);
      expect(profile.languages.length, 1);
      expect(profile.languages.first.languageCode, 'fr');
    });

    test('should correctly convert to JSON and back (serialization/deserialization)', () {
      final profileJson = profile.toJson();
      final profileFromJson = UserProfile.fromJson(profileJson);

      expect(profileFromJson.id, 'user1');
      expect(profileFromJson.name, 'Test User');
      expect(profileFromJson.streak, 3);
      expect(profileFromJson.languages.length, 1);
      expect(profileFromJson.languages.first.languageCode, 'fr');
    });

    test('should correctly handle adding/removing/updating languages', () {
      final newProgress = UserLanguageProgress(languageCode: 'es', totalPoints: 40, completedLessons: ['lesson1', 'lesson2']);
      final updatedLanguages = List<UserLanguageProgress>.from(profile.languages)..add(newProgress);

      expect(updatedLanguages.length, 2);
      expect(updatedLanguages.last.languageCode, 'es');

      final filteredLanguages = updatedLanguages.where((p) => p.languageCode != 'fr').toList();
      expect(filteredLanguages.length, 1);
      expect(filteredLanguages.first.languageCode, 'es');
    });
  });
}