import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lingua_iter/screens/main_screen.dart';
import 'package:lingua_iter/screens/verification/verification_screen.dart';
import 'package:lingua_iter/screens/welcome_screen/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Перевірити, чи Firebase ініціалізований
    if (Firebase.apps.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase ще ініціалізується або помилка
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // ❌ Користувач не залогінений
        if (user == null) {
          return WelcomeScreen();
        }

        // ⚠️ Email не підтверджений
        if (!user.emailVerified) {
          return VerificationScreen(uid: user.uid);
        }

        // ✅ Все добре
        return MainScreen();
      },
    );
  }
}