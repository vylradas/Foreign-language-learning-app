import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Список ліг (назва, іконка, чи відкрита)
    final leagues = [
      {'name': 'Мідна ліга', 'icon': Icons.emoji_events, 'color': Colors.brown, 'unlocked': true},
      {'name': 'Срібна ліга', 'icon': Icons.emoji_events, 'color': Colors.grey, 'unlocked': false},
      {'name': 'Золота ліга', 'icon': Icons.emoji_events, 'color': Colors.amber, 'unlocked': false},
      {'name': 'Платинова ліга', 'icon': Icons.emoji_events, 'color': Colors.blueGrey, 'unlocked': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Верхній підпис
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            'Рейтинг',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        // Ряд відзнак (ліги)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: leagues.map((league) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  league['icon'] as IconData,
                  size: 48,
                  color: league['unlocked'] as bool
                      ? league['color'] as Color
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ),
        // Назва поточної ліги
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Мідна ліга',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.brown[700],
            ),
          ),
        ),
        // Далі можна додати список гравців, таблицю лідерів тощо
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 80, color: Colors.brown[300]),
                const SizedBox(height: 16),
                Text(
                  'Виконайте урок, щоб потрапити у таблицю лідерів!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}