import 'package:flutter/material.dart';
import 'package:lingua_iter/models/languages.dart';
import 'package:lingua_iter/screens/sign_up/sign_up_screen.dart';
import 'package:lingua_iter/widgets/language_cell.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLanguageScreen extends StatelessWidget {
  const SelectLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Визначаємо поточну локаль інтерфейсу ('uk', 'en' тощо)
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.chooseLanguage,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 69, 142),
            fontFamily: 'Outfit',
          ),
        ),
        toolbarHeight: 48,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 69, 142),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: localLanguages.length,
            itemBuilder: (context, index) {
              final lang = localLanguages[index];
              return LanguageCell(
                languageName: getLanguageName(lang.code, currentLocale), // локалізована назва
                flagUrl: lang.assetFlag,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(
                        selectedLanguage: lang.code,
                        selectedFlag: lang.assetFlag,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}