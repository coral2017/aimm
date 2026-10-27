import 'package:flutter/material.dart';

/// Global theme configuration
class AppThemeConfig {
  AppThemeConfig._();

  /// Set to true to use the new Figma dark luxury theme (node 0:2).
  /// Set to false to instantly revert to the original light theme.
  static const bool useDarkTheme = true;
}

/// App color palette supporting both light and dark luxury themes
class AppColors {
  AppColors._();

  // Primary Bronze / Champagne Gold
  static const Color primary = AppThemeConfig.useDarkTheme
      ? Color(0xFFE5A95C) // Warm luxury amber gold
      : Color(0xFF947148);

  static const Color primaryDark = AppThemeConfig.useDarkTheme
      ? Color(0xFFC8832E)
      : Color(0xFF7A5C38);

  static const Color primaryLight = AppThemeConfig.useDarkTheme
      ? Color(0xFFF3C07B)
      : Color(0xFFC5B4A0);

  static const Color primarySubtle = AppThemeConfig.useDarkTheme
      ? Color(0xFF242C3A)
      : Color(0xFFF7F3EE);

  static const Color primaryGlow = AppThemeConfig.useDarkTheme
      ? Color(0x40E5A95C)
      : Color(0x33947148);

  // Gradient for Power Button & Highlight Cards
  static const LinearGradient primaryGradient = AppThemeConfig.useDarkTheme
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0B973),
            Color(0xFFC98634),
          ],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA6855B),
            Color(0xFF8B683F),
          ],
        );

  static const LinearGradient inactiveGradient = AppThemeConfig.useDarkTheme
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF333D4F),
            Color(0xFF242B38),
          ],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4C8BC),
            Color(0xFFB8A99A),
          ],
        );

  // Neutral Colors
  static const Color background = AppThemeConfig.useDarkTheme
      ? Color(0xFF0F131A) // Deep dark obsidian navy
      : Color(0xFFF8F8F9);

  static const Color cardBackground = AppThemeConfig.useDarkTheme
      ? Color(0xFF1C2330) // Dark slate card
      : Color(0xFFFFFFFF);

  static const Color cardBorder = AppThemeConfig.useDarkTheme
      ? Color(0xFF474D5A) // Exact Figma border-[#474d5a]
      : Colors.transparent;

  static const Color capsuleBackground = AppThemeConfig.useDarkTheme
      ? Color(0xFF272936) // Exact Figma bg-[#272936]
      : Color(0xFFF0EEE9);

  static const Color capsuleBorder = AppThemeConfig.useDarkTheme
      ? Color(0xFF474D5A) // Exact Figma border-[#474d5a]
      : Color(0xFFE5E0D6);

  // Dial & Slider specific colors
  static const Color dialOrbit = AppThemeConfig.useDarkTheme
      ? Color(0xFF2B3445)
      : Color(0xFFF2EEE9);

  static const Color waterBarTrack = AppThemeConfig.useDarkTheme
      ? Color(0xFF222938)
      : Color(0xFFF0EEE9);

  static const Color sliderTrackInactive = AppThemeConfig.useDarkTheme
      ? Color(0xFF0E1116) // Exact Figma bg-[#0e1116]
      : Color(0xFFEFECE6);

  static const Color sliderTrackActive = AppThemeConfig.useDarkTheme
      ? Color(0x59D69F5B) // Exact Figma bg-[#d69f5b] opacity-30
      : Color(0xFF947148);

  static const Color sliderThumb = AppThemeConfig.useDarkTheme
      ? Color(0xFFD69F5B) // Exact Figma circle fill="#D69F5B"
      : Color(0xFF947148);

  static const Color sliderButton = AppThemeConfig.useDarkTheme
      ? Color(0xFF272936) // Exact Figma circle fill="#272936"
      : Color(0xFFF6F4F0);

  static const Color navBackground = AppThemeConfig.useDarkTheme
      ? Color(0xFF10141D)
      : Colors.white;

  static const Color navBorder = AppThemeConfig.useDarkTheme
      ? Color(0xFF1C222E)
      : Color(0xFFF0EFEA);

  // Text Colors
  static const Color textPrimary = AppThemeConfig.useDarkTheme
      ? Color(0xFFFFFFFF)
      : Color(0xFF1F1F1F);

  static const Color textSecondary = AppThemeConfig.useDarkTheme
      ? Color(0xFFB7BCC5) // Exact Figma text-[#b7bcc5] for secondary labels & icons
      : Color(0xFF8E8E93);

  static const Color textMuted = AppThemeConfig.useDarkTheme
      ? Color(0xFF505A69)
      : Color(0xFFB0B0B5);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);

  // UI Element Colors
  static const Color divider = AppThemeConfig.useDarkTheme
      ? Color(0xFF212836)
      : Color(0xFFF0F0F2);

  static const Color shadow = AppThemeConfig.useDarkTheme
      ? Color(0x18000000)
      : Color(0x0C000000);
}
