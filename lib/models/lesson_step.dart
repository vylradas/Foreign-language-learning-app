class LessonStep {
  final String type; // 'theory', 'question', 'audio', 'image', ...
  final String? text; // для теорії або питання
  final List<String>? answers; // для тесту
  final String? correctAnswer; // для тесту
  final String? imageUrl; // для картинки
  final String? audioUrl; // для аудіо
  // нововедення
  final String? example; // для прикладу
  final List<Map<String, dynamic>>? pairs; // для зіставлення пар

  LessonStep({
    required this.type,
    this.text,
    this.answers,
    this.correctAnswer,
    this.imageUrl,
    this.audioUrl,
    // нововедення
    this.example,
    this.pairs,
  });

  factory LessonStep.fromJson(Map<String, dynamic> json) => LessonStep(
    type: json['type'],
    text: json['text'],
    answers: (json['answers'] as List?)?.map((e) => e.toString()).toList(),
    correctAnswer: json['correctAnswer'],
    imageUrl: json['imageUrl'],
    audioUrl: json['audioUrl'],
    // нововедення
    example: json['example'],
    pairs: (json['pairs'] as List?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    'answers': answers,
    'correctAnswer': correctAnswer,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
    // нововедення
    'example': example,
    'pairs': pairs,
  };
}