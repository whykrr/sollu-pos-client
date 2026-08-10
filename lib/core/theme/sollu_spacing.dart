import 'package:flutter/material.dart';

/// Standar Padding dan Spacing Ergonomis & Nyaman untuk Sollu POS
class SolluSpacing {
  // Padding Dasar (8-pt grid system)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // EdgeInsets Standar Nyaman
  static const EdgeInsets containerPadding = EdgeInsets.all(xxl); // 24px untuk dialog & kontainer utama
  static const EdgeInsets cardPadding = EdgeInsets.all(lg); // 16px untuk kartu
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: xl, vertical: md + 2); // 20px h, 14px v
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md + 2); // 16px h, 14px v
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm); // 12px h, 8px v
  static const EdgeInsets dialogPadding = EdgeInsets.all(xxl); // 24px
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xxxl, vertical: xl); // 32px h, 20px v

  // Radius Standar (Sollu Rules: 8px - 16px rounded corners)
  static final BorderRadius radiusSm = BorderRadius.circular(8);
  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusLg = BorderRadius.circular(16);
  static final BorderRadius radiusPill = BorderRadius.circular(30);
}
