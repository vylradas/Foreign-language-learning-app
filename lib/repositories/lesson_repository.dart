import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/lesson_detail.dart';

class LessonRepository {
  Future<List<LessonDetail>> fetchLessons(String language) async {
    print('LANGUAGE PARAM: $language');
    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('languages')
        .doc(language)
        .collection('lessons')
        .get();
    print('FIRESTORE DOCS COUNT: ${lessonsSnapshot.docs.length}');
    return lessonsSnapshot.docs
        .map((doc) => LessonDetail.fromJson(doc.data()))
        .toList();
  }
}