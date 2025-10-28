import 'package:flutter/material.dart';
import 'package:lingua_iter/screens/select_language/select_language_screen.dart';
import 'package:lingua_iter/screens/sign_in/sing_in_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Логотип і назва
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_icon_clear.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 9),
                GradientText(
                  'Lingua Iter',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                  colors: const [Color(0xFF0069D9), Color(0xFF00D7D0)],
                  gradientDirection: GradientDirection.ltr,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Підзаголовок
            Text(
              'Free app for learning language',
              style: GoogleFonts.readexPro(
                color: const Color(0xC05398BC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            // Зображення
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/Welcome.jpg',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Запрошення до навчання
            Text(
              AppLocalizations.of(context)!.readyToStartLearning,
              style: GoogleFonts.ubuntu(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            // Кнопка "Start learning"
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectLanguageScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D7D0),
                minimumSize: const Size(312, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF0069D9), width: 3),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.startLearning,
                style: GoogleFonts.ubuntu(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            // Кнопка "I already have an account"
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF468DFF),
                minimumSize: const Size(312, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF00D7D0), width: 3),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.alreadyHaveAccount,
                style: GoogleFonts.readexPro(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}