import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lingua_iter/models/user_profile.dart';
import 'package:lingua_iter/repositories/user_repository.dart';
import 'package:lingua_iter/screens/settings_screen.dart';
import 'package:lingua_iter/widgets/top_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Не вдалося завантажити профіль'));
        }
        final user = snapshot.data!;
        final activeLang = user.activeLanguageCode;
        final langProgress = user.languages.firstWhere(
          (l) => l.languageCode == activeLang,
          orElse: () => user.languages.first,
        );
        // TODO: Додати league визначення, поки просто "Copper"
        final league = "Copper";

        return SingleChildScrollView(
          child: Column(
            children: [
              // Верхній бар з назвою та кнопкою налаштувань
               SafeArea(
                top: true,
                bottom: false,
                 child: TopBar(
                  left: const Text(
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  right: IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 23),
                    onPressed: () {
                      final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          userName: user.name,
                          userEmail: userEmail,
                          currentLocale: Localizations.localeOf(context).languageCode,
                          onLocaleChanged: (code) {
                            // тут зміни локалізацію у своєму app state
                          },
                        ),
                      ));
                    },
                  ),
                               ),
               ),
               const SizedBox(height: 12),
              // Аватар та ім'я користувача
              Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, size: 48, color: Colors.blue)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ ADD BIO',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 115, 172),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
              // Контейнери: streak, XP, league
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ProfileStat(
                      icon: Icons.local_fire_department,
                      value: user.streak.toString(),
                      label: 'DAYS STREAK',
                      iconColor: Colors.orange,
                    ),
                    _ProfileStat(
                      icon: Icons.flash_on,
                      value: langProgress.totalPoints.toString(),
                      label: 'XP',
                      iconColor: Colors.amber[700],
                    ),
                    _ProfileStat(
                      icon: Icons.emoji_events,
                      value: league,
                      label: 'LEAGUE',
                      iconColor: const Color(0xFFB87333),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Friends section (поки пусто)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Friends',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '+ ADD FRIENDS',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? Colors.black54, size: 32),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}