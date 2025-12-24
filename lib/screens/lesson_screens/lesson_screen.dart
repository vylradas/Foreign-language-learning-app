import 'package:flutter/material.dart';
import 'package:lingua_iter/models/lesson_detail.dart';
import 'package:lingua_iter/models/lesson_step.dart';
import 'package:lingua_iter/widgets/answer_result_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LessonScreen extends StatefulWidget {
  final LessonDetail lesson;
  final bool isReplay;

  const LessonScreen({super.key, required this.lesson, this.isReplay = false});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int currentStep = 0;

  late DateTime _startTime;
  int _totalExp = 0;
  int _correctAnswers = 0;

  bool? isAnswerCorrect;
  bool showResult = false;
  String? selectedAnswer;

  // Для matching step
  int? _selectedLeft;
  int? _selectedRight;
  final Map<int, int> _matches = {}; // leftIndex -> rightIndex
  List<String>? _shuffledRight;
  int? _errorLeft;
  int? _errorRight;

  void _onAnswerSelected(String answer, LessonStep step) {
    setState(() {
      selectedAnswer = answer;
      isAnswerCorrect = answer == step.correctAnswer;
      showResult = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initMatchingStepIfNeeded();
  }

  void _initMatchingStepIfNeeded() {
    final step = widget.lesson.steps[currentStep];
    if (step.type == 'matching') {
      final pairs = step.pairs ?? [];
      _shuffledRight = pairs.map((e) => e['right'] as String).toList()..shuffle();
      _selectedLeft = null;
      _selectedRight = null;
      _matches.clear();
    }
  }

  @override
  void didUpdateWidget(LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initMatchingStepIfNeeded();
  }

  Future<void> _markLessonCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();
    final data = userSnapshot.data();
    if (data == null) return;

    List languages = data['languages'] ?? [];
    final activeLang = data['activeLanguageCode'];
    for (var lang in languages) {
      if (lang['languageCode'] == activeLang) {
        List<String> completed = List<String>.from(lang['completedLessons'] ?? []);
        if (!completed.contains(widget.lesson.id)) {
          completed.add(widget.lesson.id);
          lang['completedLessons'] = completed;
        }
        break;
      }
    }

    await userDoc.update({'languages': languages});
  }

  Future<void> _addExp(int exp) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();
    final data = userSnapshot.data();
    if (data == null) return;

    List languages = data['languages'] ?? [];
    final activeLang = data['activeLanguageCode'];
    for (var lang in languages) {
      if (lang['languageCode'] == activeLang) {
        lang['totalPoints'] = (lang['totalPoints'] ?? 0) + exp;
        break;
      }
    }

    await userDoc.update({'languages': languages});
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.lesson.steps[currentStep];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Верхній бар з прогресом
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (currentStep + 1) / widget.lesson.steps.length,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Контент уроку
                Expanded(
                  child: _buildStepContent(step),
                ),
                // Кнопка "Продовжити" тільки для theory
                if (step.type == 'theory')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (currentStep < widget.lesson.steps.length - 1) {
                            setState(() {
                              currentStep++;
                              _initMatchingStepIfNeeded();
                            });
                          } else {
                            if (!widget.isReplay) {
                              await _markLessonCompleted();
                            }
                            // Додаємо діалог перед виходом
                            final duration = DateTime.now().difference(_startTime);
                            await _showLessonResultDialog(context, _totalExp, duration, _totalExp / duration.inSeconds);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.continue_button,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Спливаюче вікно для питання (question)
            if (showResult)
              AnswerResultBottomSheet(
                isCorrect: isAnswerCorrect ?? false,
                onContinue: () async {
                  if (isAnswerCorrect == true && !(widget.isReplay)) {
                    await _addExp(3);
                    setState(() {
                      _totalExp += 3;
                      _correctAnswers += 1;
                    });
                  }
                  if (currentStep < widget.lesson.steps.length - 1) {
                    setState(() {
                      showResult = false;
                      selectedAnswer = null;
                      isAnswerCorrect = null;
                      currentStep++;
                      _initMatchingStepIfNeeded();
                    });
                  } else {
                    if (!widget.isReplay) {
                      await _markLessonCompleted();
                    }
                    final duration = DateTime.now().difference(_startTime);
                    final percent = widget.lesson.steps
                        .where((s) => s.type == 'question')
                        .isEmpty
                        ? 100.0
                        : (_correctAnswers /
                            widget.lesson.steps.where((s) => s.type == 'question').length) *
                          100;
                    await _showLessonResultDialog(context, _totalExp, duration, percent);
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String getLocalizedLessonText(BuildContext context, LessonStep step) {
    final localizations = AppLocalizations.of(context)!;
    final textKey = step.text ?? '';
    final example = step.example ?? '';

    final Map<String, String Function(String)> keyToFunc = {
      'lesson1_theory_hello': localizations.lesson1_theory_hello,
      'lesson1_theory_hi': localizations.lesson1_theory_hi,
      'lesson1_theory_niceToMeetYou': localizations.lesson1_theory_niceToMeetYou,
      'lesson_finish_sentence': localizations.lesson_finish_sentence,
    };

    if (keyToFunc.containsKey(textKey)) {
      return keyToFunc[textKey]!(example);
    }
    final Map<String, String> keyToString = {
      'lesson1_question_hello': localizations.lesson1_question_hello,
      'lesson1_question_hi': localizations.lesson1_question_hi,
    };
    if (keyToString.containsKey(textKey)) {
      return keyToString[textKey]!;
    }
    return textKey;
  }

  Widget _buildStepContent(LessonStep step) {
    switch (step.type) {
      case 'theory':
        return Center(
          child: Text(
            getLocalizedLessonText(context, step),
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        );
      case 'question':
        return _buildQuestionStep(step);
      case 'matching':
        return Column(
          children: [
            Expanded(child: _buildMatchingStep(step)),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _matches.length == (step.pairs?.length ?? 0)
                      ? () async {
                          if (currentStep < widget.lesson.steps.length - 1) {
                            setState(() {
                              currentStep++;
                              _initMatchingStepIfNeeded();
                            });
                          } else {
                            if (!widget.isReplay) {
                              await _markLessonCompleted();
                            }
                            final duration = DateTime.now().difference(_startTime);
                            await _showLessonResultDialog(context, _totalExp, duration, _totalExp / duration.inSeconds);
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: Text(
                    AppLocalizations.of(context)!.continue_button,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildQuestionStep(LessonStep step) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(getLocalizedLessonText(context, step), style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: (step.answers ?? []).map((answer) => OutlinedButton(
            onPressed: showResult ? null : () => _onAnswerSelected(answer, step),
            style: OutlinedButton.styleFrom(
              backgroundColor: selectedAnswer == answer
                  ? (isAnswerCorrect == true
                      ? Colors.green[100]
                      : Colors.red[100])
                  : Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade300, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              elevation: 2,
              shadowColor: Colors.black12,
            ),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMatchingStep(LessonStep step) {
    final pairs = step.pairs ?? [];
    final left = pairs.map((e) => e['left']!).toList();
    final right = _shuffledRight ?? [];

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(left.length, (i) {
              final isSelected = _selectedLeft == i;
              final isMatched = _matches.containsKey(i);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedLeft = null;
                    } else {
                      _selectedLeft = i;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isMatched
                      ? Colors.green[100]
                      : _errorLeft == i
                          ? Colors.red[200]
                          : isSelected
                              ? Colors.blue[100]
                              : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  alignment: Alignment.center,
                  child: Text(
                    left[i],
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(right.length, (j) {
              final isSelected = _selectedRight == j;
              final isMatched = _matches.containsValue(j);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedRight = null;
                    } else if (_selectedLeft != null && !isMatched) {
                      // Перевіряємо правильність
                      final pairs = step.pairs ?? [];
                      final leftIndex = _selectedLeft!;
                      final rightIndex = j;
                      final correctRight = pairs[leftIndex]['right'];
                      if (right[rightIndex] == correctRight) {
                        // Вірна пара
                        _matches[leftIndex] = rightIndex;
                        _selectedLeft = null;
                        _selectedRight = null;
                      } else {
                        // Невірна пара — підсвічуємо червоним
                        _errorLeft = leftIndex;
                        _errorRight = rightIndex;
                        _selectedLeft = null;
                        _selectedRight = null;
                        Future.delayed(const Duration(milliseconds: 700), () {
                          setState(() {
                            _errorLeft = null;
                            _errorRight = null;
                          });
                        });
                      }
                    } else {
                      _selectedRight = j;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isMatched
                      ? Colors.green[100]
                      : _errorRight == j
                          ? Colors.red[200]
                          : isSelected
                              ? Colors.blue[100]
                              : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  alignment: Alignment.center,
                  child: Text(
                    right[j],
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Future<void> _showLessonResultDialog(
    BuildContext context, int exp, Duration duration, double percent) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Урок завершено!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Усього балів
                _ResultBlock(
                  label: 'Усього балів',
                  value: '$exp',
                  icon: Icons.flash_on,
                  iconColor: Colors.amber,
                ),
                // Оцінка
                _ResultBlock(
                  label: 'Оцінка',
                  value: '${percent.toStringAsFixed(0)}%',
                  icon: Icons.signal_cellular_alt_rounded,
                  iconColor: Colors.green,
                ),
                // Час проходження
                _ResultBlock(
                  label: 'Час',
                  value: '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  icon: Icons.access_time,
                  iconColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Готово',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _ResultBlock({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}