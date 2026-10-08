import 'package:flutter/material.dart';

class SolluColors {
  // Primary (Navy Blue) - Adjusted for higher contrast and elegance
  static const Color primary = Color(0xFF1E3A8A); // Darker blue for sharp white text contrast
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF93C5FD);
  static const Color primaryDark = Color(0xFF172554);
  static const Color primaryDarker = Color(0xFF0F172A);

  // Secondary (Teal/Turquoise) - Adjusted to avoid gamut ambiguity on old monitors
  static const Color secondary = Color(0xFF0F766E); // Deep Teal
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color secondaryLighter = Color(0xFF5EEAD4);
  static const Color secondaryDark = Color(0xFF115E59);
  static const Color secondaryDarker = Color(0xFF134E4A);

  // Backgrounds - Stronger contrast against surface white
  static const Color background = Color(0xFFF1F5F9); // Slate 100
  static const Color surface = Color(0xFFFFFFFF);

  // Neutrals and Text - WCAG compliant
  static const Color neutral = Color(0xFFCBD5E1);
  static const Color neutralDark = Color(0xFF64748B); // Slate 500
  static const Color neutralDarker = Color(0xFF334155); // Slate 700
  static const Color neutralMuted = Color(0xFF94A3B8); // Slate 400 (use sparingly on light bg)
  
  static const Color textDark = Color(0xFF0F172A); // Slate 900 - very high contrast
  static const Color textMuted = Color(0xFF475569); // Slate 600 - safe secondary text contrast

  // Semantic Colors
  static const Color danger = Color(0xFFDC2626); // Red 600 (better contrast than 400)
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color info = Color(0xFF0284C7); // Sky 600
}
