/// Schlagrichtung / Ereignis in Achtel-Auflösung.
///
/// Darstellung in der UI: ↓ (runter), ↑ (hoch), – (Pause), × (gedämpft).
enum StrokeType {
  down,
  up,
  rest,
  muted,
}

extension StrokeTypeLabel on StrokeType {
  /// Kurzes Symbol für Timeline und Tests.
  String get symbol => switch (this) {
        StrokeType.down => '↓',
        StrokeType.up => '↑',
        StrokeType.rest => '–',
        StrokeType.muted => '×',
      };

  String get labelDe => switch (this) {
        StrokeType.down => 'Abschlag',
        StrokeType.up => 'Aufschlag',
        StrokeType.rest => 'Pause',
        StrokeType.muted => 'Gedämpft',
      };
}
