import 'package:flutter/material.dart';

import 'chord_shape.dart';
import 'finger_colors.dart';
import 'finger_position.dart';

/// Zeichnet ein horizontales Griffbrett (Nut links, Bünde nach rechts).
///
/// Saite 6 (tiefe E) oben, Saite 1 (hohe e) unten — klassische Diagramm-Sicht.
/// Bei [leftHanded] werden die Saiten vertikal gespiegelt.
class FretboardPainter extends CustomPainter {
  FretboardPainter({
    required this.chord,
    required this.leftHanded,
    this.dotOpacity = 1.0,
  });

  final ChordShape chord;
  final bool leftHanded;
  final double dotOpacity;

  static const int stringCount = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final frets = chord.displayFrets.clamp(3, 12);
    final layout = FretboardLayout.fromSize(size, frets: frets);

    _drawBoard(canvas, layout);
    _drawNutMarkers(canvas, layout);
    _drawFretMarkers(canvas, layout);
    _drawFingerDots(canvas, layout);
  }

  void _drawBoard(Canvas canvas, FretboardLayout layout) {
    final boardPaint = Paint()
      ..color = const Color(0xFF2A3230)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.boardRect, const Radius.circular(8)),
      boardPaint,
    );

    final stringPaint = Paint()
      ..color = const Color(0xFF9AA8A2)
      ..strokeCap = StrokeCap.round;

    for (var s = 1; s <= stringCount; s++) {
      final y = layout.stringY(s, leftHanded);
      stringPaint.strokeWidth = 1.2 + (s - 1) * 0.35;
      canvas.drawLine(
        Offset(layout.nutX, y),
        Offset(layout.endX, y),
        stringPaint,
      );
    }

    final fretPaint = Paint()
      ..color = const Color(0xFF6B7A74)
      ..strokeWidth = 1.5;

    for (var f = 1; f <= layout.frets; f++) {
      final x = layout.fretX(f);
      canvas.drawLine(
        Offset(x, layout.topY),
        Offset(x, layout.bottomY),
        fretPaint,
      );
    }

    final nutPaint = Paint()
      ..color = const Color(0xFFE8EEEB)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(layout.nutX, layout.topY),
      Offset(layout.nutX, layout.bottomY),
      nutPaint,
    );
  }

  void _drawFretMarkers(Canvas canvas, FretboardLayout layout) {
    const markerFrets = {3, 5, 7, 9};
    final paint = Paint()..color = const Color(0xFF4A5551);
    for (final fret in markerFrets) {
      if (fret > layout.frets) continue;
      final c = layout.fretCenter(fret, stringCount ~/ 2 + 0.5, leftHanded);
      canvas.drawCircle(c, 4, paint);
    }
  }

  void _drawNutMarkers(Canvas canvas, FretboardLayout layout) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var s = 1; s <= stringCount; s++) {
      final y = layout.stringY(s, leftHanded);
      final isMuted = chord.mutedStrings.contains(s);
      final isOpen = chord.openStrings.contains(s);
      if (!isMuted && !isOpen) continue;

      final label = isMuted ? '×' : '○';
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: isMuted
              ? const Color(0xFFE85D4C)
              : const Color(0xFFB8C9C1),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          layout.nutX - layout.markerPad - textPainter.width,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawFingerDots(Canvas canvas, FretboardLayout layout) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final pos in chord.positions) {
      _drawDot(canvas, layout, pos, textPainter);
    }
  }

  void _drawDot(
    Canvas canvas,
    FretboardLayout layout,
    FingerPosition pos,
    TextPainter textPainter,
  ) {
    if (pos.fret < 1 || pos.fret > layout.frets) return;
    final center = layout.fretCenter(pos.fret, pos.stringNumber.toDouble(), leftHanded);
    final color = FingerColors.forFinger(pos.finger).withValues(alpha: dotOpacity);
    final radius = layout.dotRadius;

    canvas.drawCircle(center, radius + 1.5, Paint()..color = Colors.black26);
    canvas.drawCircle(center, radius, Paint()..color = color);

    textPainter.text = TextSpan(
      text: '${pos.finger}',
      style: TextStyle(
        color: Colors.white.withValues(alpha: dotOpacity),
        fontSize: radius * 1.1,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant FretboardPainter oldDelegate) {
    return oldDelegate.chord != chord ||
        oldDelegate.leftHanded != leftHanded ||
        oldDelegate.dotOpacity != dotOpacity;
  }
}

/// Geometrie-Helfer fürs Griffbrett (auch für Hit-Tests / Tests nutzbar).
class FretboardLayout {
  FretboardLayout._({
    required this.size,
    required this.frets,
    required this.boardRect,
    required this.nutX,
    required this.endX,
    required this.topY,
    required this.bottomY,
    required this.markerPad,
    required this.dotRadius,
  });

  factory FretboardLayout.fromSize(Size size, {required int frets}) {
    final padL = size.width * 0.12;
    final padR = size.width * 0.04;
    final padV = size.height * 0.14;
    final board = Rect.fromLTRB(padL, padV, size.width - padR, size.height - padV);
    final stringSpan = board.height;
    final dotRadius = (stringSpan / 6 * 0.38).clamp(10.0, 18.0);
    return FretboardLayout._(
      size: size,
      frets: frets,
      boardRect: board,
      nutX: board.left,
      endX: board.right,
      topY: board.top,
      bottomY: board.bottom,
      markerPad: 8,
      dotRadius: dotRadius,
    );
  }

  final Size size;
  final int frets;
  final Rect boardRect;
  final double nutX;
  final double endX;
  final double topY;
  final double bottomY;
  final double markerPad;
  final double dotRadius;

  double stringY(int stringNumber, bool leftHanded) {
    assert(stringNumber >= 1 && stringNumber <= 6);
    // Visual row 0 = top. Right-handed: string 6 at top.
    final visualIndex = leftHanded ? (stringNumber - 1) : (6 - stringNumber);
    final t = visualIndex / 5;
    return topY + t * (bottomY - topY);
  }

  double fretX(int fret) {
    // fret line after fret number (right edge of that fret cell)
    final cell = (endX - nutX) / frets;
    return nutX + fret * cell;
  }

  /// Mittelpunkt der Bundzelle [fret] auf Saite [string] (1–6, oder .5 für Mitte).
  Offset fretCenter(int fret, double string, bool leftHanded) {
    final cell = (endX - nutX) / frets;
    final x = nutX + (fret - 0.5) * cell;
    final y = stringY(string.round().clamp(1, 6), leftHanded);
    // For half-string (fret markers), interpolate:
    if (string != string.roundToDouble()) {
      final yA = stringY(string.floor().clamp(1, 6), leftHanded);
      final yB = stringY(string.ceil().clamp(1, 6), leftHanded);
      return Offset(x, (yA + yB) / 2);
    }
    return Offset(x, y);
  }
}
