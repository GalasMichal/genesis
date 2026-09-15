/// Finger der Zupfhand (klassische Notation).
///
/// p = Daumen (pulgar), i = Zeigefinger (índice),
/// m = Mittelfinger (medio), a = Ringfinger (anular).
enum PickingFinger {
  p,
  i,
  m,
  a,
}

extension PickingFingerLabel on PickingFinger {
  String get symbol => name;

  String get labelDe => switch (this) {
        PickingFinger.p => 'Daumen (p)',
        PickingFinger.i => 'Zeigefinger (i)',
        PickingFinger.m => 'Mittelfinger (m)',
        PickingFinger.a => 'Ringfinger (a)',
      };
}
