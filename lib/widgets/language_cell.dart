import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lingua_iter/screens/select_language/select_language_screen.dart';

class LanguageCell extends StatelessWidget {
  final String languageName;
  final String flagUrl;
  final VoidCallback onTap; // Функція натискання

  const LanguageCell({
    super.key,
    required this.languageName,
    required this.flagUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Викликає функцію при натисканні
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, // Колір можна змінювати
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color.fromARGB(255, 193, 192, 192)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              flagUrl, // локальний asset шлях до прапора
              width: 80,
              height: 50,
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              languageName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}