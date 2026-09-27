import 'package:flutter/material.dart';

class AppColorTheme {
  const AppColorTheme({required this.name, required this.seedColor});

  final String name;
  final Color seedColor;
}

const List<AppColorTheme> defaultColorThemes = [
  AppColorTheme(name: 'Indigo', seedColor: Color(0xFF4F46E5)),
  AppColorTheme(name: 'Blue', seedColor: Color(0xFF2563EB)),
  AppColorTheme(name: 'Teal', seedColor: Color(0xFF0D9488)),
  AppColorTheme(name: 'Green', seedColor: Color(0xFF16A34A)),
  AppColorTheme(name: 'Amber', seedColor: Color(0xFFD97706)),
  AppColorTheme(name: 'Red', seedColor: Color(0xFFDC2626)),
  AppColorTheme(name: 'Pink', seedColor: Color(0xFFDB2777)),
  AppColorTheme(name: 'Purple', seedColor: Color(0xFF9333EA)),
];
