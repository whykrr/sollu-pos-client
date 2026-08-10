---
name: sollu-flutter-rules
description: Standards and design guidelines for creating the Sollu Flutter (Dart) Android app, ensuring UI/UX consistency with the Laravel/Vue web app.
---

# Sollu Flutter App Guidelines

This skill provides guidelines for developing the Sollu Flutter Android application. The goal is to ensure a unified design language, color palette, typography, and component styling between the existing Laravel/Vue web app and the Flutter mobile app.

## 🎨 Color Palette

The Flutter app MUST use the same color palette defined in the web app. Use these Hex colors to define your Flutter `Color` constants or `ColorScheme`.

### Primary (Navy Blue - Elegant & Deep)
- `primary`: `#1e40af` (Main)
- `primaryLight`: `#3b82f6`
- `primaryLighter`: `#60a5fa`
- `primaryDark`: `#1e3a8a`
- `primaryDarker`: `#172554`

### Secondary (Turquoise - Bright, Elegant)
- `secondary`: `#06b6d4`
- `secondaryLight`: `#67e8f9`
- `secondaryLighter`: `#a5f3fc`
- `secondaryDark`: `#0891b2`
- `secondaryDarker`: `#0e7490`

### Neutrals (Professional Slate)
- `background` / `neutralLight`: `#f8fafc`
- `surface` / `neutralLighter`: `#ffffff`
- `neutral`: `#cbd5e1`
- `neutralDark`: `#475569`
- `neutralDarker`: `#1e293b`
- `neutralMuted`: `#94a3b8`

### Semantic Colors
- `danger`: `#ef4444`
- `warning`: `#f59e0b`
- `success`: `#10b981`
- `info`: `#0ea5e9`

### Flutter Color Setup Example
```dart
class SolluColors {
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  
  static const Color secondary = Color(0xFF06B6D4);
  
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF94A3B8);
}
```

## 🔤 Typography

The application uses **Plus Jakarta Sans** for all text hierarchies (headings, body, and buttons) to ensure high readability and a clean, modern aesthetic suitable for POS environments.

- Integrate the `google_fonts` package.
- Set the default text theme to `GoogleFonts.plusJakartaSansTextTheme()`.
- Avoid mixing multiple font families unless specifically requested by design.

## 💠 Component Styling

### 1. Buttons
- **Shape**: Rounded corners. Use `RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))` for smaller buttons, or up to `20` for larger primary buttons if needed.
- **Elevation**: Flat by default, `elevation: 0`.
- **Primary Button**: `SolluColors.primary` background with bold white text.
- **Secondary/Action Button**: Flat with light slate background `Color(0xFFE2E8F0).withValues(alpha: 0.5)`, muted text/icons (`SolluColors.textMuted`), no borders.

### 2. Cards, Dialogs, & Containers
- **Background**: `SolluColors.surface` (White) or `Color(0xFFF8FAFC)` for app background. No complex gradients.
- **BorderRadius**: 20px (`BorderRadius.circular(20)`) for all major containers, cards, and dialogs.
- **Shadows**: Extremely soft ambient shadow replacing default Material elevation. Always use: `BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: Offset(0, 5))`.
- **Border**: Avoid heavy borders. If needed, use a very light `SolluColors.neutral`.

### 3. Inputs & Forms
- **Border**: 1px solid `SolluColors.neutral`.
- **Focus Ring**: `SolluColors.primary` 2px border.
- **BorderRadius**: 12px.
- **Background**: White (`Colors.white`).

### 4. Navigation
- Use a `BottomNavigationBar` or a clean drawer sidebar (`NavigationDrawer`).
- Active items should be highlighted with `SolluColors.primary` and potentially a light background tint (`primary.withOpacity(0.1)`).
- Icons should be clean and solid (consider using `font_awesome_flutter` since the web uses FontAwesome solid).

## 🚀 General Flutter Development Rules

1. **State Management**: (Define your preferred state management here, e.g., Provider, Riverpod, Bloc, GetX).
2. **Architecture**: Keep UI components separate from business logic.
3. **API Integration**: The Flutter app will communicate with the Laravel backend via REST or GraphQL. Ensure models map exactly to the Laravel API responses.
4. **Consistency**: Whenever building a new screen in Flutter, look at the equivalent screen in the Vue app. Match the spacing, hierarchy, and visual weight.
