// на даний момент не використовується, але може бути корисним у майбутньому
class LearnUnit {
  final String title;
  final String description;
  final List<Lesson> lessons;

  LearnUnit({
    required this.title,
    required this.description,
    required this.lessons,
  });
} //"блок" або "розділ" курсу (наприклад, Unit 1, Unit 2)

class Lesson {  
  final int number;
  final bool isUnlocked;

  Lesson({
    required this.number,
    required this.isUnlocked,
  });
} //окремий урок, який входить до складу певного LearnUnit