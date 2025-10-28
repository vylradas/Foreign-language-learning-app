import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lingua_iter/main.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String currentLocale;
  final void Function(String)? onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.currentLocale,
    this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _name;
  late String _email;
  late String _locale;

  @override
  void initState() {
    super.initState();
    _name = widget.userName;
    _email = widget.userEmail;
    _locale = widget.currentLocale;
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': _name,
            'interfaceLocale': _locale,});
    }
    Navigator.of(context).pop();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося видалити обліковий запис')),
      );
    }
  }

  void _showLocalePicker() async {
    final locales = [
      {'code': 'en', 'label': 'English'},
      {'code': 'uk', 'label': 'Українська'},
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in locales)
            ListTile(
              title: Text(locale['label']!),
              onTap: () => Navigator.pop(context, locale['code']),
            ),
        ],
      ),
    );
    if (selected != null && selected != _locale) {
      setState(() => _locale = selected);
      appLocale.value = Locale(selected); 
      print('LOCALE CHANGED TO: $selected');
      widget.onLocaleChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context)?.settings ?? 'Settings',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color.fromARGB(255, 15, 17, 34)),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Аватар
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  // backgroundImage: NetworkImage(...),
                  child: Icon(Icons.person, size: 48, color: Colors.blue),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Name
          _SettingsField(
            label: AppLocalizations.of(context)?.your_name ?? 'Your name',
            initialValue: _name,
            maxLength: 30,
            onChanged: (val) => setState(() => _name = val),
          ),
          const SizedBox(height: 16),
          // Email (disabled)
          _SettingsField(
            label: 'Email',
            initialValue: _email,
            enabled: false,
            suffixIcon: Icon(Icons.lock, size: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Content language
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.flag, color: Colors.deepPurple),
              title: Text(AppLocalizations.of(context)?.content_language ?? 'Content language',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text(
                _locale == 'uk' ? 'Українська' : 'English',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: _showLocalePicker,
            ),
          ),
          const SizedBox(height: 32),
          // Вихід
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _signOut,
              child: const Text('Вихід', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          // Видалити акаунт
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _deleteAccount,
              child: const Text('Видалити обліковий запис', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final String initialValue;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const _SettingsField({
    required this.label,
    required this.initialValue,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          maxLength: maxLength,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}