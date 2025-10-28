import 'package:lingua_iter/models/lesson_step.dart';

class LessonDetail {
  final String id;
  final String title;
  final List<LessonStep> steps;
  final String unit;
  final bool? isCompleted;
  final String? imageUrl;

  LessonDetail({
    required this.id,
    required this.title,
    required this.steps,
    required this.unit,
    this.isCompleted,
    this.imageUrl,
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) => LessonDetail(
    id: json['id'],
    title: json['title'],
    steps: (json['steps'] as List)
        .map((e) => LessonStep.fromJson(e))
        .toList(),
    unit: json['unit'] ?? 'unit1',
    isCompleted: json['isCompleted'],
    imageUrl: json['imageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'steps': steps.map((e) => e.toJson()).toList(),
    'unit': unit,
    'isCompleted': isCompleted,
    'imageUrl': imageUrl,
  };
}