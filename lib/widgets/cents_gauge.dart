import 'package:flutter/material.dart';

/// Horizontale Cent-Skala mit Nadel (−50 … +50).
/// Grün im ±5-Cent-Fenster, sonst orange→rot.
class CentsGauge extends StatelessWidget {
  const CentsGauge({
    super.key,
    required this.cents,
    this.hasSignal = false,
  });

  final double cents;
  final bool hasSignal;

  static const double _range = 50;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = cents.clamp(-_range, _range);
    final inTune = hasSignal && cents.abs() <= 5;
    final Color needleColor;
    if (!hasSignal) {
      needleColor = theme.colorScheme.outline;
    } else if (inTune) {
      needleColor = const Color(0xFF3DDC97);
    } else if (cents.abs() <= 15) {
      needleColor = const Color(0xFFF0A202);
    } else {
      needleColor = const Color(0xFFE85D4C);
    }

    return Column(
      children: [
        SizedBox(
          height: 96,
          width: double.infinity,
          child: CustomPaint(
            painter: _CentsGaugePainter(
              cents: hasSignal ? clamped : 0,
              needleColor: needleColor,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              inTuneZoneColor: const Color(0xFF3DDC97).withValues(alpha: 0.22),
              labelColor: theme.colorScheme.onSurfaceVariant,
              showNeedle: hasSignal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasSignal
              ? (inTune
                    ? 'Stimmt'
                    : (cents > 0 ? 'Zu hoch' : 'Zu tief'))
              : 'Spiele eine Saite',
          style: theme.textTheme.titleMedium?.copyWith(
            color: needleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CentsGaugePainter extends CustomPainter {
  _CentsGaugePainter({
    required this.cents,
    required this.needleColor,
    required this.trackColor,
    required this.inTuneZoneColor,
    required this.labelColor,
    required this.showNeedle,
  });

  final double cents;
  final Color needleColor;
  final Color trackColor;
  final Color inTuneZoneColor;
  final Color labelColor;
  final bool showNeedle;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height * 0.62;
    final left = 16.0;
    final right = size.width - 16.0;
    final width = right - left;
    final centerX = left + width / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, cy), Offset(right, cy), trackPaint);

    // ±5 Cent Zone
    final zoneHalf = width * (5 / 100);
    final zonePaint = Paint()..color = inTuneZoneColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, cy),
          width: zoneHalf * 2,
          height: 18,
        ),
        const Radius.circular(4),
      ),
      zonePaint,
    );

    // Ticks
    final tickPaint = Paint()
      ..color = labelColor.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    for (final c in [-50, -25, 0, 25, 50]) {
      final x = centerX + (c / 50) * (width / 2);
      final h = c == 0 ? 16.0 : 10.0;
      canvas.drawLine(Offset(x, cy - h), Offset(x, cy + h), tickPaint);
    }

    // Needle
    if (showNeedle) {
      final x = centerX + (cents / 50) * (width / 2);
      final needle = Paint()
        ..color = needleColor
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, cy - 36), Offset(x, cy + 14), needle);
      canvas.drawCircle(Offset(x, cy - 36), 5, Paint()..color = needleColor);
    }
  }

  @override
  bool shouldRepaint(covariant _CentsGaugePainter oldDelegate) {
    return oldDelegate.cents != cents ||
        oldDelegate.needleColor != needleColor ||
        oldDelegate.showNeedle != showNeedle;
  }
}
