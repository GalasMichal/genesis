import 'package:flutter/material.dart';

/// Konsistente Finger-Farbpalette (1 = Zeigefinger … 4 = kleiner Finger).
abstract final class FingerColors {
  static const Color index = Color(0xFFE85D4C); // 1 Zeigefinger
  static const Color middle = Color(0xFFE8B84C); // 2 Mittelfinger
  static const Color ring = Color(0xFF4C9AE8); // 3 Ringfinger
  static const Color pinky = Color(0xFF6BCB77); // 4 kleiner Finger

  static const List<Color> all = [index, middle, ring, pinky];

  /// [finger] muss 1–4 sein.
  static Color forFinger(int finger) {
    assert(finger >= 1 && finger <= 4, 'Finger muss 1–4 sein, war $finger');
    return all[finger - 1];
  }

  static String labelForFinger(int finger) {
    switch (finger) {
      case 1:
        return 'Zeigefinger';
      case 2:
        return 'Mittelfinger';
      case 3:
        return 'Ringfinger';
      case 4:
        return 'Kleiner Finger';
      default:
        return 'Finger $finger';
    }
  }
}
