import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final Widget left;
  final Widget right;
  const TopBar({required this.left, required this.right, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: Colors.black26,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [left, right],
        ),
      ),
    );
  }
}