import 'package:flutter/material.dart';

/// Central color definitions for the app.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // App bar
  static const Color appBarBackground = primary;
  static const Color appBarForeground = onPrimary;

  // Surfaces
  static const Color scaffoldBackground = Color(0xFFFEF7FF);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1D1B20);
  static const Color textSecondary = Color(0xFF49454F);

  // Status
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
}
