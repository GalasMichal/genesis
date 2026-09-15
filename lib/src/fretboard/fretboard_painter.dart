import 'package:flutter/material.dart';

import 'barre.dart';
import 'chord_shape.dart';
import 'finger_colors.dart';
import 'finger_position.dart';
import 'fretboard_view_mode.dart';

/// Zeichnet Griffbrett oder Akkord-Diagramm per CustomPainter.
class FretboardPainter extends CustomPainter {
  FretboardPainter({
    required this.chord,
    required this.leftHanded,
    required this.viewMode,
    this.dotOpacity = 1.0,
  });

  final ChordShape chord;
  final bool leftHanded;
  final FretboardViewMode viewMode;
  final double dotOpacity;

  static const int stringCount = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final frets = chord.displayFrets.clamp(3, 12);
    if (viewMode == FretboardViewMode.chordDiagram) {
      _paintChordDiagram(canvas, size, frets);
    } else {
      _paintHorizontal(canvas, size, frets);
    }
  }

  // ── Horizontales Griffbrett ──────────────────────────────────────────

  void _paintHorizontal(Canvas canvas, Size size, int frets) {
    final layout = HorizontalLayout.fromSize(size, frets: frets);
    _drawHorizontalBoard(canvas, layout);
    _drawHorizontalNutMarkers(canvas, layout);
    _drawHorizontalFretMarkers(canvas, layout);
    _drawHorizontalBarre(canvas, layout);
    _drawHorizontalFingerDots(canvas, layout);
  }

  void _drawHorizontalBoard(Canvas canvas, HorizontalLayout layout) {
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

  void _drawHorizontalFretMarkers(Canvas canvas, HorizontalLayout layout) {
    const markerFrets = {3, 5, 7, 9};
    final paint = Paint()..color = const Color(0xFF4A5551);
    for (final fret in markerFrets) {
      if (fret > layout.frets) continue;
      final c = layout.fretCenter(fret, stringCount / 2 + 0.5, leftHanded);
      canvas.drawCircle(c, 4, paint);
    }
  }

  void _drawHorizontalNutMarkers(Canvas canvas, HorizontalLayout layout) {
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

  void _drawHorizontalBarre(Canvas canvas, HorizontalLayout layout) {
    final barre = chord.barre;
    if (barre == null || barre.fret < 1 || barre.fret > layout.frets) return;

    final yA = layout.stringY(barre.lowString, leftHanded);
    final yB = layout.stringY(barre.highString, leftHanded);
    final center = layout.fretCenter(
      barre.fret,
      (barre.lowString + barre.highString) / 2,
      leftHanded,
    );
    final top = yA < yB ? yA : yB;
    final bottom = yA > yB ? yA : yB;
    final radius = layout.dotRadius;
    final rect = RRect.fromLTRBR(
      center.dx - radius,
      top - radius * 0.55,
      center.dx + radius,
      bottom + radius * 0.55,
      Radius.circular(radius),
    );
    final color = FingerColors.forFinger(barre.finger).withValues(alpha: dotOpacity);
    canvas.drawRRect(rect, Paint()..color = color);
    _paintFingerLabel(
      canvas,
      Offset(center.dx, (top + bottom) / 2),
      barre.finger,
      radius * 1.1,
    );
  }

  void _drawHorizontalFingerDots(Canvas canvas, HorizontalLayout layout) {
    for (final pos in chord.positions) {
      if (chord.barre != null &&
          chord.barre!.fret == pos.fret &&
          chord.barre!.covers(pos.stringNumber)) {
        continue;
      }
      if (pos.fret < 1 || pos.fret > layout.frets) continue;
      final center = layout.fretCenter(
        pos.fret,
        pos.stringNumber.toDouble(),
        leftHanded,
      );
      _drawDot(canvas, center, pos, layout.dotRadius);
    }
  }

  // ── Vertikales Akkord-Diagramm ───────────────────────────────────────

  void _paintChordDiagram(Canvas canvas, Size size, int frets) {
    final layout = ChordDiagramLayout.fromSize(size, frets: frets);
    _drawDiagramGrid(canvas, layout);
    _drawDiagramNutMarkers(canvas, layout);
    _drawDiagramBarre(canvas, layout);
    _drawDiagramFingerDots(canvas, layout);
  }

  void _drawDiagramGrid(Canvas canvas, ChordDiagramLayout layout) {
    final boardPaint = Paint()
      ..color = const Color(0xFF2A3230)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.boardRect, const Radius.circular(8)),
      boardPaint,
    );

    final stringPaint = Paint()
      ..color = const Color(0xFF9AA8A2)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var s = 1; s <= stringCount; s++) {
      final x = layout.stringX(s, leftHanded);
      canvas.drawLine(
        Offset(x, layout.nutY),
        Offset(x, layout.endY),
        stringPaint,
      );
    }

    final fretPaint = Paint()
      ..color = const Color(0xFF6B7A74)
      ..strokeWidth = 1.5;

    for (var f = 1; f <= layout.frets; f++) {
      final y = layout.fretY(f);
      canvas.drawLine(
        Offset(layout.leftX, y),
        Offset(layout.rightX, y),
        fretPaint,
      );
    }

    final nutPaint = Paint()
      ..color = const Color(0xFFE8EEEB)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(layout.leftX, layout.nutY),
      Offset(layout.rightX, layout.nutY),
      nutPaint,
    );

    // Bund-Marker als kleine Punkte in der Diagramm-Mitte
    const markerFrets = {3, 5};
    final markerPaint = Paint()..color = const Color(0xFF4A5551);
    for (final fret in markerFrets) {
      if (fret > layout.frets) continue;
      final c = layout.fretCenter(fret, 3.5, leftHanded);
      canvas.drawCircle(c, 3.5, markerPaint);
    }
  }

  void _drawDiagramNutMarkers(Canvas canvas, ChordDiagramLayout layout) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var s = 1; s <= stringCount; s++) {
      final x = layout.stringX(s, leftHanded);
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
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          layout.nutY - layout.markerPad - textPainter.height,
        ),
      );
    }
  }

  void _drawDiagramBarre(Canvas canvas, ChordDiagramLayout layout) {
    final barre = chord.barre;
    if (barre == null || barre.fret < 1 || barre.fret > layout.frets) return;

    final xA = layout.stringX(barre.lowString, leftHanded);
    final xB = layout.stringX(barre.highString, leftHanded);
    final center = layout.fretCenter(
      barre.fret,
      (barre.lowString + barre.highString) / 2,
      leftHanded,
    );
    final left = xA < xB ? xA : xB;
    final right = xA > xB ? xA : xB;
    final radius = layout.dotRadius;
    final rect = RRect.fromLTRBR(
      left - radius * 0.55,
      center.dy - radius,
      right + radius * 0.55,
      center.dy + radius,
      Radius.circular(radius),
    );
    final color = FingerColors.forFinger(barre.finger).withValues(alpha: dotOpacity);
    canvas.drawRRect(rect, Paint()..color = color);
    _paintFingerLabel(
      canvas,
      Offset((left + right) / 2, center.dy),
      barre.finger,
      radius * 1.1,
    );
  }

  void _drawDiagramFingerDots(Canvas canvas, ChordDiagramLayout layout) {
    for (final pos in chord.positions) {
      if (chord.barre != null &&
          chord.barre!.fret == pos.fret &&
          chord.barre!.covers(pos.stringNumber)) {
        continue;
      }
      if (pos.fret < 1 || pos.fret > layout.frets) continue;
      final center = layout.fretCenter(
        pos.fret,
        pos.stringNumber.toDouble(),
        leftHanded,
      );
      _drawDot(canvas, center, pos, layout.dotRadius);
    }
  }

  // ── Gemeinsame Helfer ────────────────────────────────────────────────

  void _drawDot(
    Canvas canvas,
    Offset center,
    FingerPosition pos,
    double radius,
  ) {
    final color = FingerColors.forFinger(pos.finger).withValues(alpha: dotOpacity);
    canvas.drawCircle(center, radius + 1.5, Paint()..color = Colors.black26);
    canvas.drawCircle(center, radius, Paint()..color = color);
    _paintFingerLabel(canvas, center, pos.finger, radius * 1.1);
  }

  void _paintFingerLabel(
    Canvas canvas,
    Offset center,
    int finger,
    double fontSize,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '$finger',
      style: TextStyle(
        color: Colors.white.withValues(alpha: dotOpacity),
        fontSize: fontSize,
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
        oldDelegate.viewMode != viewMode ||
        oldDelegate.dotOpacity != dotOpacity;
  }
}

/// Geometrie fürs horizontale Griffbrett.
class HorizontalLayout {
  HorizontalLayout._({
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

  factory HorizontalLayout.fromSize(Size size, {required int frets}) {
    final padL = size.width * 0.12;
    final padR = size.width * 0.04;
    final padV = size.height * 0.14;
    final board = Rect.fromLTRB(
      padL,
      padV,
      size.width - padR,
      size.height - padV,
    );
    final stringSpan = board.height;
    final dotRadius = (stringSpan / 6 * 0.38).clamp(10.0, 18.0);
    return HorizontalLayout._(
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
    final visualIndex = leftHanded ? (stringNumber - 1) : (6 - stringNumber);
    final t = visualIndex / 5;
    return topY + t * (bottomY - topY);
  }

  double fretX(int fret) {
    final cell = (endX - nutX) / frets;
    return nutX + fret * cell;
  }

  Offset fretCenter(int fret, double string, bool leftHanded) {
    final cell = (endX - nutX) / frets;
    final x = nutX + (fret - 0.5) * cell;
    if (string != string.roundToDouble()) {
      final yA = stringY(string.floor().clamp(1, 6), leftHanded);
      final yB = stringY(string.ceil().clamp(1, 6), leftHanded);
      return Offset(x, (yA + yB) / 2);
    }
    return Offset(x, stringY(string.round().clamp(1, 6), leftHanded));
  }
}

/// Alias für bestehende Tests / API.
typedef FretboardLayout = HorizontalLayout;

/// Geometrie fürs vertikale Akkord-Diagramm (Nut oben).
class ChordDiagramLayout {
  ChordDiagramLayout._({
    required this.size,
    required this.frets,
    required this.boardRect,
    required this.nutY,
    required this.endY,
    required this.leftX,
    required this.rightX,
    required this.markerPad,
    required this.dotRadius,
  });

  factory ChordDiagramLayout.fromSize(Size size, {required int frets}) {
    final padH = size.width * 0.12;
    final padTop = size.height * 0.18;
    final padBottom = size.height * 0.08;
    final board = Rect.fromLTRB(
      padH,
      padTop,
      size.width - padH,
      size.height - padBottom,
    );
    final stringSpan = board.width;
    final dotRadius = (stringSpan / 6 * 0.36).clamp(10.0, 20.0);
    return ChordDiagramLayout._(
      size: size,
      frets: frets,
      boardRect: board,
      nutY: board.top,
      endY: board.bottom,
      leftX: board.left,
      rightX: board.right,
      markerPad: 6,
      dotRadius: dotRadius,
    );
  }

  final Size size;
  final int frets;
  final Rect boardRect;
  final double nutY;
  final double endY;
  final double leftX;
  final double rightX;
  final double markerPad;
  final double dotRadius;

  /// Rechtshänder: Saite 6 links, Saite 1 rechts (klassisches Chord-Chart).
  double stringX(int stringNumber, bool leftHanded) {
    assert(stringNumber >= 1 && stringNumber <= 6);
    final visualIndex = leftHanded ? (stringNumber - 1) : (6 - stringNumber);
    final t = visualIndex / 5;
    return leftX + t * (rightX - leftX);
  }

  double fretY(int fret) {
    final cell = (endY - nutY) / frets;
    return nutY + fret * cell;
  }

  Offset fretCenter(int fret, double string, bool leftHanded) {
    final cell = (endY - nutY) / frets;
    final y = nutY + (fret - 0.5) * cell;
    if (string != string.roundToDouble()) {
      final xA = stringX(string.floor().clamp(1, 6), leftHanded);
      final xB = stringX(string.ceil().clamp(1, 6), leftHanded);
      return Offset((xA + xB) / 2, y);
    }
    return Offset(stringX(string.round().clamp(1, 6), leftHanded), y);
  }
}

/// Re-export für Aufrufer, die Barré am Painter brauchen.
typedef FretboardBarre = Barre;
