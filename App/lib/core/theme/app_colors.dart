import 'package:flutter/material.dart';

class AppColors {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primary = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFF59E0B);

  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
}