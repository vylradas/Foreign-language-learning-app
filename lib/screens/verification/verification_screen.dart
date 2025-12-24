import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lingua_iter/screens/main_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String uid;

  const VerificationScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool isLoading = false;

  Future<void> _checkEmailVerified() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user!.emailVerified) {
          // Перехід до MainScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email ще не підтверджений. Перевірте свою пошту.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Лист підтвердження відправлено повторно.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Підтвердження Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Перевірте свою електронну пошту та натисніть на посилання для підтвердження.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _checkEmailVerified,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Перевірити підтвердження'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isLoading ? null : _resendVerificationEmail,
              child: const Text('Відправити лист повторно'),
            ),
          ],
        ),
      ),
    );
  }
}
