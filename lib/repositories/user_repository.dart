import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lingua_iter/main.dart';
import 'package:lingua_iter/models/user_profile.dart';

Future<UserProfile?> fetchUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return null;
  final data = doc.data()!..['id'] = user.uid; // додаємо id з auth
  final profile = UserProfile.fromJson(data);
  
  if (profile.interfaceLocale != null && profile.interfaceLocale!.isNotEmpty) {
    appLocale.value = Locale(profile.interfaceLocale!);
  }

  return profile;
}