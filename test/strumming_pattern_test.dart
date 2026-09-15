import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/strumming/fingerpicking_pattern.dart';
import 'package:genesis/src/strumming/pattern_catalog.dart';
import 'package:genesis/src/strumming/pattern_validator.dart';
import 'package:genesis/src/strumming/picking_finger.dart';
import 'package:genesis/src/strumming/stroke_type.dart';
import 'package:genesis/src/strumming/strumming_pattern.dart';
import 'package:genesis/src/strumming/technique_display.dart';
import 'package:genesis/theme.dart';

void main() {
  group('PatternValidator', () {
    test('Katalog: 5 Schlag- + 2 Zupfmuster, alle gültig', () {
      expect(PatternCatalog.strumming.length, 5);
      expect(PatternCatalog.fingerpicking.length, 2);
      final errors = PatternValidator.validateCatalog();
      expect(errors, isEmpty, reason: errors.join('\n'));
    });

    test('Grundschlag-Symbole und Achtel-Länge', () {
      final p = PatternCatalog.grundschlag44;
      expect(p.eighths.length, 8);
      expect(p.symbolString, contains('↓'));
      expect(p.eighths.first, StrokeType.down);
    });

    test('Walzer hat 6 Achtel (3/4)', () {
      final p = PatternCatalog.walzer34;
      expect(p.beatsPerBar, 3);
      expect(p.eighths.length, 6);
    });

    test('Arpeggio p-i-m-a und Travis sind gültig', () {
      expect(
        PatternValidator.validateFingerpicking(PatternCatalog.arpeggioPima),
        isEmpty,
      );
      expect(
        PatternValidator.validateFingerpicking(PatternCatalog.travisEinfach),
        isEmpty,
      );
      final steps = PatternCatalog.arpeggioPima.steps.whereType<PickingStep>();
      expect(steps.map((s) => s.finger), [
        PickingFinger.p,
        PickingFinger.i,
        PickingFinger.m,
        PickingFinger.a,
      ]);
    });

    test('validate meldet kaputte Muster', () {
      const badStrum = StrummingPattern(
        id: 'bad',
        title: '',
        summary: '',
        beatsPerBar: 5,
        eighths: [StrokeType.rest, StrokeType.rest],
      );
      final strumErrors = PatternValidator.validateStrumming(badStrum);
      expect(strumErrors, isNotEmpty);
      expect(strumErrors.any((e) => e.contains('beatsPerBar')), isTrue);

      const badPick = FingerpickingPattern(
        id: 'bad-pick',
        title: 'Bad',
        summary: 'x',
        beatsPerBar: 4,
        steps: [
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          PickingStep(finger: PickingFinger.p, stringNumber: 9),
        ],
      );
      final pickErrors = PatternValidator.validateFingerpicking(badPick);
      expect(pickErrors.any((e) => e.contains('außerhalb')), isTrue);
    });

    test('validatePatternId prüft Pflichtfeld', () {
      expect(PatternValidator.validatePatternId(null), isNotEmpty);
      expect(PatternValidator.validatePatternId(''), isNotEmpty);
      expect(PatternValidator.validatePatternId('gibt-es-nicht'), isNotEmpty);
      expect(
        PatternValidator.validatePatternId('grundschlag-44'),
        isEmpty,
      );
    });
  });

  group('eighthIndexAtBeat', () {
    test('mappt Beat auf Achtel-Index modulo Musterlänge', () {
      expect(eighthIndexAtBeat(0, 8), 0);
      expect(eighthIndexAtBeat(0.5, 8), 1);
      expect(eighthIndexAtBeat(1.0, 8), 2);
      expect(eighthIndexAtBeat(4.0, 8), 0); // neuer Takt
      expect(eighthIndexAtBeat(0.25, 6), 0);
      expect(eighthIndexAtBeat(1.0, 6), 2);
    });
  });

  group('TechniqueDisplay', () {
    testWidgets('zeigt Schlagmuster-Pfeile und hebt aktuellen Slot hervor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGenesisTheme(),
          home: const Scaffold(
            body: TechniqueDisplay(
              patternId: 'grundschlag-44',
              beat: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4/4-Grundschlag'), findsOneWidget);
      expect(find.text('↓'), findsWidgets);
      expect(find.textContaining('Achtel 1/8'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildGenesisTheme(),
          home: const Scaffold(
            body: TechniqueDisplay(
              patternId: 'grundschlag-44',
              beat: 1.0, // Achtel-Index 2
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Achtel 3/8'), findsOneWidget);
    });

    testWidgets('zeigt Zupf-Finger und Saiten-Hinweis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGenesisTheme(),
          home: const Scaffold(
            body: TechniqueDisplay(
              patternId: 'arpeggio-pima',
              beat: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Arpeggio'), findsOneWidget);
      expect(find.text('p'), findsWidgets);
      expect(find.textContaining('Daumen (p) zupft Saite 4'), findsOneWidget);
    });

    testWidgets('Walzer und betontes Muster rendern', (WidgetTester tester) async {
      for (final id in ['walzer-34', 'betont-44', 'travis-einfach']) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildGenesisTheme(),
            home: Scaffold(
              body: TechniqueDisplay(patternId: id, beat: 0.5),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final title = PatternCatalog.byId(id)!.title;
        expect(find.text(title), findsOneWidget);
      }
    });
  });
}
