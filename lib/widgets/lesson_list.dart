import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lingua_iter/models/learn_unit.dart';
import 'package:lingua_iter/models/lesson_detail.dart';
import 'package:lingua_iter/screens/lesson_screens/lesson_screen.dart';

class LessonList extends StatelessWidget {
  final List<LessonDetail> lessons;
  final int completedCount;
  final void Function(LessonDetail lesson)? onLessonTap;

  const LessonList({super.key, required this.lessons, this.completedCount = 0, this.onLessonTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(lessons.length, (index) {
        final lesson = lessons[index];
        final isCompleted = lesson.isCompleted ?? false;
        final isAvailable = !isCompleted && (index == 0 || (lessons[index - 1].isCompleted ?? false));
        final isLocked = !isCompleted && !isAvailable;
        final showLine = index < lessons.length - 1;

        return Stack(
          children: [
            if (showLine)
              Positioned(
                left: 36,
                top: 60,
                bottom: -8,
                child: Container(
                  width: 3,
                  height: 40,
                  color: isCompleted ? Colors.green[300] : Colors.grey[300],
                ),
              ),
            GestureDetector(
              onTap: () {
                if ((isAvailable || isCompleted) && onLessonTap != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LessonScreen(
                        lesson: lesson,
                        isReplay: lesson.isCompleted ?? false, // Передаємо прапорець
                      ),
                    ),
                  );
                }
              },
              child: Opacity(
                opacity: isLocked ? 0.5 : 1.0, // Сірі недоступні — напівпрозорі
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green[50]
                        : isAvailable
                            ? Colors.blue.withOpacity(0.07)
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green
                          : isAvailable
                              ? Colors.blue
                              : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: isCompleted
                                ? Colors.green[100]
                                : isAvailable
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                            backgroundImage: lesson.imageUrl != null
                                ? NetworkImage(lesson.imageUrl!)
                                : null,
                            child: lesson.imageUrl == null
                                ? Text(
                                    lesson.title.substring(0, 1),
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          if (isCompleted)
                            const Positioned(
                              bottom: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                              ),
                            ),
                          if (isLocked)
                            const Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(Icons.lock, color: Colors.grey, size: 22),
                            ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.cloud_download_outlined, color: Colors.blue[300]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}