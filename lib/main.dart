import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:lingua_iter/firebase_options.dart';
import 'package:lingua_iter/screens/sign_in/sing_in_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lingua_iter/screens/auth_gate.dart';

final Rx<Locale> appLocale = Locale('uk').obs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); // Ініціалізація Firebase
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  // await uploadLessonFromAsset(); // Завантаження уроків з assets
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      locale: appLocale.value,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('uk', ''),
      ],
      title: 'Language Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
      routes: {
        '/signin': (context) => SignInScreen(),
      },
    ));
  }
}



