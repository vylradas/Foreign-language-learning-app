import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lingua_iter/models/languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lingua_iter/screens/main_screen.dart';


class SignUpScreen extends StatefulWidget {
  final String selectedFlag;
  final String selectedLanguage;
  SignUpScreen({Key? key, 
  required this.selectedLanguage, 
  required this.selectedFlag}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
          'languages': [
            {
              'languageCode': widget.selectedLanguage,
              'lessonsCompleted': 0,
              'totalPoints': 0,
            }
          ],
          'streak': 0,
          'activeLanguageCode': widget.selectedLanguage,
        });
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      }
    } catch (e) {
      print("Помилка реєстрації: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Користувач скасував вхід
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        // Перевірка на наявність користувача у Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // Якщо користувача немає у Firestore, додаємо його
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName ?? 'google_user',
            'languages': [
              {
                'languageCode': widget.selectedLanguage,
                'lessonsCompleted': 0,
                'totalPoints': 0,
              }
            ],
            'streak': 0,
            'activeLanguageCode': widget.selectedLanguage,
          });
        }
      }
    } catch (e) {
      print("Помилка входу через Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          toolbarHeight: 48,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          color: Colors.white, // або інший фон, якщо потрібно
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset(
                            widget.selectedFlag,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            placeholderBuilder: (context) => Icon(Icons.flag, size: 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        helloGreetings[widget.selectedLanguage] ?? 'Hello!',
                        style: GoogleFonts.ubuntu(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${AppLocalizations.of(context)!.registerAndStartLearning} \n${getLanguageName(widget.selectedLanguage, Localizations.localeOf(context).languageCode)}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildTextField(AppLocalizations.of(context)!.email, emailController),
                  _buildTextField(AppLocalizations.of(context)!.name, nameController),
                  _buildTextField(AppLocalizations.of(context)!.password, passwordController, obscureText: true),
                  const SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0069D9), // синій фон
                        foregroundColor: Colors.white, // білий текст
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.or ?? 'АБО',
                          style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                      onPressed: signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // білий фон
                        foregroundColor: Colors.black, // чорний текст
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                        side: const BorderSide(color: Color(0xFF0069D9), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                TextSpan(text: AppLocalizations.of(context)!.continueWithGoogle.split('Google')[0]),
                                TextSpan(
                                  text: 'Google',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w500)),
          SizedBox(
            height: 50, // Висота поля (наприклад, 50)
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12), // Внутрішній відступ
              ),
            ),
          ),
        ],
      ),
    );
  }
}

