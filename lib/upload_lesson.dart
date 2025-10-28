import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadLessonFromAsset() async {
  final String jsonString = await rootBundle.loadString('assets/lessons/english/lesson4.json');
  final Map<String, dynamic> lessonData = json.decode(jsonString);

  await FirebaseFirestore.instance
    .collection('languages')
    .doc('en')
    .collection('lessons')
    .doc(lessonData['id'])
    .set(lessonData);
}