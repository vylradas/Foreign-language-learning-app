class LocalLanguage {
  final String code; // 'en', 'uk', 'de' ...
  final String assetFlag; // шлях до прапора у assets/images
  LocalLanguage({required this.code, required this.assetFlag});
}

final List<LocalLanguage> localLanguages = [
  LocalLanguage(code: 'en', assetFlag: 'assets/images/Flag_of_the_United_Kingdom_(3-5).svg'),
  LocalLanguage(code: 'uk', assetFlag: 'assets/images/Flag_of_Ukraine.svg'),
  LocalLanguage(code: 'de', assetFlag: 'assets/images/Flag_of_Germany.svg'),
  LocalLanguage(code: 'fr', assetFlag: 'assets/images/Flag_of_France.svg'),
  LocalLanguage(code: 'es', assetFlag: 'assets/images/Flag_of_Spain.svg'),
  // список прапорів для різних мов
];

final Map<String, String> helloGreetings = {
  'en': 'Hello!',
  'uk': 'Привіт!',
  'de': 'Hallo!',
  'fr': 'Bonjour!',
  'es': '¡Hola!',
  // список привітань на різних мовах
};

final Map<String, Map<String, String>> languageNames = {
  'en': {
    'en': 'English',
    'uk': 'Англійська',
  },
  'uk': {
    'en': 'Ukrainian',
    'uk': 'Українська',
  },
  'de': {
    'en': 'German',
    'uk': 'Німецька',
  },
  'fr': {
    'en': 'French',
    'uk': 'Французька',
  },
  'es': {
    'en': 'Spanish',
    'uk': 'Іспанська',
  },
  // додайте інші мови за потреби
};

String getLanguageName(String code, String locale) {
  return languageNames[code]?[locale] ?? languageNames[code]?['en'] ?? code;
}