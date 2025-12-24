import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/lesson_detail.dart';

class LessonRepository {
  Future<List<LessonDetail>> fetchLessons(String language, Set<String> completedLessons) async {
    print('LANGUAGE PARAM: $language');
    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('languages')
        .doc(language)
        .collection('lessons')
        .get();
    print('FIRESTORE DOCS COUNT: ${lessonsSnapshot.docs.length}');
    return lessonsSnapshot.docs
        .map((doc) {
          final lesson = LessonDetail.fromJson(doc.data());
          return lesson.copyWith(isCompleted: completedLessons.contains(lesson.id));
        })
        .toList();
  }
}