import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lingua_iter/models/languages.dart';
import 'package:lingua_iter/models/learn_unit.dart';
import 'package:lingua_iter/models/lesson_detail.dart';
import 'package:lingua_iter/models/user_profile.dart';
import 'package:lingua_iter/repositories/lesson_repository.dart';
import 'package:lingua_iter/screens/lesson_screens/lesson_screen.dart';
import 'package:lingua_iter/widgets/lesson_list.dart';
import 'package:lingua_iter/widgets/top_bar.dart';

class LearnScreen extends StatefulWidget {
  final UserProfile userProfile;

  LearnScreen({super.key, required this.userProfile});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late Future<List<LessonDetail>> _lessonsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() {
    final activeLangProgress = widget.userProfile.languages.firstWhere(
      (lang) => lang.languageCode == widget.userProfile.activeLanguageCode,
      orElse: () => UserLanguageProgress(languageCode: widget.userProfile.activeLanguageCode, totalPoints: 0, completedLessons: []),
    );
    _lessonsFuture = LessonRepository().fetchLessons(widget.userProfile.activeLanguageCode, activeLangProgress.completedLessons.toSet());
  }

  Future<void> _openLesson(LessonDetail lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LessonScreen(lesson: lesson)),
    );
    setState(() {
      _loadLessons(); // Оновити список після повернення з уроку
    });
  }

  Future<void> _changeActiveLanguage(String newLangCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Оновити у Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'activeLanguageCode': newLangCode});

    // Оновити локально (можна через setState або повторно завантажити профіль)
    setState(() {
      widget.userProfile.activeLanguageCode = newLangCode; // якщо поле не final
      _loadLessons(); // перезавантажити уроки для нової мови
    });
  }

  //final int streak = 0;
  @override
  Widget build(BuildContext context) {
    final activeLang = widget.userProfile.activeLanguageCode;
    final langObj = localLanguages.firstWhere((l) => l.code == activeLang);
    final streak = widget.userProfile.streak;

    return Column(
      children: [
        // Верхня панель з тінню
        SafeArea(
          top: true,
          bottom: false,
          child: TopBar(
            left: GestureDetector(
                    onTap: () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        showDragHandle: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final lang in localLanguages.where((l) => l.code == 'en' || l.code == 'de'))
                                ListTile(
                                  leading: ClipOval(
                                    child: SvgPicture.asset(
                                      lang.assetFlag,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(getLanguageName(lang.code, Localizations.localeOf(context).languageCode)),
                                  onTap: () {
                                    Navigator.pop(context, lang.code);
                                  },
                                ),
                            ],
                          );
                        },
                      );
                      if (selected != null && selected != activeLang) {
                        await _changeActiveLanguage(selected);
                      }
                    },
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        width: 28,
                        height: 28,
                        child: SvgPicture.asset(
                          langObj.assetFlag,
                          fit: BoxFit.cover,
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                  ),
            right: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                const SizedBox(width: 4),
                Text(
                  streak.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
                // Список уроків
        Expanded(
          child: FutureBuilder<List<LessonDetail>>(
            future: _lessonsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print('LESSON ERROR: ${snapshot.error}');
                return Center(child: Text('Помилка завантаження уроків'));
              }
              final lessons = snapshot.data ?? [];
              print('LESSONS COUNT: ${lessons.length}');
              print('LESSONS DATA: $lessons');
              if (lessons.isEmpty) {
                return const Center(child: Text('Уроки не знайдено'));
              }

              // Групування за unit
              final Map<String, List<LessonDetail>> unitsMap = {};
              for (final lesson in lessons) {
                final unitKey = lesson.unit;
                unitsMap.putIfAbsent(unitKey, () => []).add(lesson);
              }

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: unitsMap.entries.map((entry) {
                  final unitKey = entry.key;
                  final unitLessons = entry.value;
                  final unitTitle = _getUnitTitle(context, unitKey);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unitTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LessonList(
                        lessons: unitLessons,
                        onLessonTap: _openLesson, // Додаємо callback
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getUnitTitle(BuildContext context, String unitKey) {
    switch (unitKey) {
      case 'unit1':
        return 'Розділ 1';
      case 'unit2':
        return 'Розділ 2';
      default:
        return unitKey;
    }
  }
}