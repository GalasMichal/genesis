import 'fingerpicking_pattern.dart';
import 'pattern_catalog.dart';
import 'stroke_type.dart';
import 'strumming_pattern.dart';
import 'technique_pattern.dart';

/// Validiert Schlag-/Zupfmuster und Song-Zuweisungen.
abstract final class PatternValidator {
  /// Prüft ein Schlagmuster; leere Liste = gültig.
  static List<String> validateStrumming(StrummingPattern pattern) {
    final errors = <String>[];
    final prefix = pattern.id.isEmpty ? '(ohne-id)' : pattern.id;

    if (pattern.id.trim().isEmpty) {
      errors.add('$prefix: id fehlt');
    }
    if (pattern.title.trim().isEmpty) {
      errors.add('$prefix: Titel fehlt');
    }
    if (pattern.beatsPerBar != 3 && pattern.beatsPerBar != 4) {
      errors.add(
        '$prefix: beatsPerBar ${pattern.beatsPerBar} muss 3 oder 4 sein',
      );
    }
    if (pattern.eighths.length != pattern.expectedEighthCount) {
      errors.add(
        '$prefix: ${pattern.eighths.length} Achtel, erwartet '
        '${pattern.expectedEighthCount}',
      );
    }
    if (pattern.eighths.isNotEmpty &&
        pattern.eighths.every((s) => s == StrokeType.rest)) {
      errors.add('$prefix: Muster enthält nur Pausen');
    }

    return errors;
  }

  /// Prüft ein Fingerpicking-Muster.
  static List<String> validateFingerpicking(FingerpickingPattern pattern) {
    final errors = <String>[];
    final prefix = pattern.id.isEmpty ? '(ohne-id)' : pattern.id;

    if (pattern.id.trim().isEmpty) {
      errors.add('$prefix: id fehlt');
    }
    if (pattern.title.trim().isEmpty) {
      errors.add('$prefix: Titel fehlt');
    }
    if (pattern.beatsPerBar != 3 && pattern.beatsPerBar != 4) {
      errors.add(
        '$prefix: beatsPerBar ${pattern.beatsPerBar} muss 3 oder 4 sein',
      );
    }
    if (pattern.steps.length != pattern.expectedEighthCount) {
      errors.add(
        '$prefix: ${pattern.steps.length} Achtel, erwartet '
        '${pattern.expectedEighthCount}',
      );
    }

    var hasNote = false;
    for (var i = 0; i < pattern.steps.length; i++) {
      final step = pattern.steps[i];
      if (step == null) continue;
      hasNote = true;
      if (step.stringNumber < 1 || step.stringNumber > 6) {
        errors.add(
          '$prefix: Step[$i] Saite ${step.stringNumber} außerhalb 1–6',
        );
      }
    }
    if (pattern.steps.isNotEmpty && !hasNote) {
      errors.add('$prefix: Muster enthält nur Pausen');
    }

    return errors;
  }

  static List<String> validateTechnique(TechniquePattern technique) {
    return switch (technique) {
      StrumTechnique(:final pattern) => validateStrumming(pattern),
      PickTechnique(:final pattern) => validateFingerpicking(pattern),
    };
  }

  /// Alle Katalog-Muster.
  static List<String> validateCatalog() {
    final errors = <String>[];
    final ids = <String>{};
    for (final t in PatternCatalog.all) {
      errors.addAll(validateTechnique(t));
      if (!ids.add(t.id)) {
        errors.add('${t.id}: doppelte Muster-ID');
      }
    }
    return errors;
  }

  /// Prüft, dass [patternId] im Katalog existiert (für Songs).
  static List<String> validatePatternId(String? patternId, {String? songId}) {
    final prefix = songId ?? '(song)';
    if (patternId == null || patternId.trim().isEmpty) {
      return ['$prefix: Technik-Muster fehlt (patternId)'];
    }
    if (PatternCatalog.byId(patternId) == null) {
      return ['$prefix: unbekanntes Technik-Muster "$patternId"'];
    }
    return [];
  }
}
