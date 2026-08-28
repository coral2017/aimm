import 'package:flutter/material.dart';

/// App color palette matching Figma luxury champagne/bronze design
class AppColors {
  AppColors._();

  // Primary Bronze / Champagne Gold
  static const Color primary = Color(0xFF947148);
  static const Color primaryDark = Color(0xFF7A5C38);
  static const Color primaryLight = Color(0xFFC5B4A0);
  static const Color primarySubtle = Color(0xFFF7F3EE);
  static const Color primaryGlow = Color(0x33947148);

  // Gradient for Power Button & Highlight Cards
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA6855B),
      Color(0xFF8B683F),
    ],
  );

  static const LinearGradient inactiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4C8BC),
      Color(0xFFB8A99A),
    ],
  );

  // Neutral Colors
  static const Color background = Color(0xFFF8F8F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color capsuleBackground = Color(0xFFF0EEE9);
  static const Color capsuleBorder = Color(0xFFE5E0D6);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFFB0B0B5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);

  // UI Element Colors
  static const Color divider = Color(0xFFF0F0F2);
  static const Color sliderTrackInactive = Color(0xFFEFECE6);
  static const Color shadow = Color(0x0C000000);
}
