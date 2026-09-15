import 'finger_position.dart';

/// Ein Akkordgriff als Liste von Fingerpositionen plus leere/gedämpfte Saiten.
class ChordShape {
  const ChordShape({
    required this.id,
    required this.name,
    required this.positions,
    this.mutedStrings = const {},
    this.displayFrets = 5,
  });

  final String id;
  final String name;
  final List<FingerPosition> positions;

  /// Saiten mit „x“ (nicht anschlagen), Nummerierung 1–6.
  final Set<int> mutedStrings;

  /// Wie viele Bünde das Diagramm zeigt (ab Bund 1).
  final int displayFrets;

  /// Saiten ohne Finger und ohne Mute → leere Saite („o“).
  Set<int> get openStrings {
    final fretted = {for (final p in positions) p.stringNumber};
    return {
      for (var s = 1; s <= 6; s++)
        if (!fretted.contains(s) && !mutedStrings.contains(s)) s,
    };
  }

  /// Höchster Bund im Griff (mindestens 1).
  int get maxFret {
    if (positions.isEmpty) return 1;
    return positions.map((p) => p.fret).reduce((a, b) => a > b ? a : b);
  }

  ChordShape copyWith({
    String? id,
    String? name,
    List<FingerPosition>? positions,
    Set<int>? mutedStrings,
    int? displayFrets,
  }) {
    return ChordShape(
      id: id ?? this.id,
      name: name ?? this.name,
      positions: positions ?? this.positions,
      mutedStrings: mutedStrings ?? this.mutedStrings,
      displayFrets: displayFrets ?? this.displayFrets,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! ChordShape) return false;
    if (other.id != id ||
        other.name != name ||
        other.displayFrets != displayFrets) {
      return false;
    }
    if (other.positions.length != positions.length) return false;
    for (var i = 0; i < positions.length; i++) {
      if (other.positions[i] != positions[i]) return false;
    }
    return other.mutedStrings.length == mutedStrings.length &&
        other.mutedStrings.containsAll(mutedStrings);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    Object.hashAll(positions),
    Object.hashAll(mutedStrings),
    displayFrets,
  );
}
