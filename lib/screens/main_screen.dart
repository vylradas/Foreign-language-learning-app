import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lingua_iter/repositories/user_repository.dart';
import 'package:lingua_iter/models/user_profile.dart';
import 'package:lingua_iter/screens/leaderboar_screen.dart';
import 'package:lingua_iter/screens/learn_screen.dart';
import 'package:lingua_iter/screens/profile_screen.dart';
import 'package:lingua_iter/screens/review_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Помилка завантаження профілю: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Профіль не знайдено')),
          );
        }
        final userProfile = snapshot.data!;
        final List<Widget> _screens = [
          LearnScreen(userProfile: userProfile),
          ReviewScreen(),
          LeaderboardScreen(),
          ProfileScreen(),
        ];
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Навчання'),
              BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Повторення'),
              BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Рейтинг'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профіль'),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}