import 'song.dart';
import 'song_category.dart';

/// Fertige Songbibliothek — nur Eigencontent + geprüft gemeinfreie Stücke.
///
/// Akkordfolgen sind eigene, vereinfachte Übungs-Arrangements (keine
/// geschützten Tabs/Songtexte). Melodien der Traditionals/Volkslieder/Klassik
/// sind gemeinfrei; der Quellen-Vermerk dokumentiert das je Song.
abstract final class SongLibrary {
  static const List<Song> all = [
    // Einsteiger-Übungen (eigen)
    emAmTakt,
    cGWechsel,
    gDEmDrei,
    // Englische Traditionals (gemeinfrei)
    amazingGrace,
    houseOfTheRisingSun,
    ohSusanna,
    scarboroughFair,
    // Polnische Volkslieder (gemeinfrei)
    stoLat,
    wlazlKotek,
    szlaDzieweczka,
    // Klassik (gemeinfrei)
    odeAnDieFreude,
    // Eigene Pop/Rock-Strumming-Songs
    neonspur,
    nachtschicht,
    kuestenwind,
  ];

  static Song? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  static List<Song> byCategory(SongCategory? category) {
    if (category == null) return List.unmodifiable(all);
    return all.where((s) => s.category == category).toList(growable: false);
  }

  /// Einzigartige Akkord-IDs in Auftrittsreihenfolge.
  static List<String> uniqueChordIds(Song song) {
    final seen = <String>{};
    final out = <String>[];
    for (final e in song.events) {
      if (seen.add(e.chordId)) out.add(e.chordId);
    }
    return out;
  }

  // ─── Einsteiger (eigen, 2–3 Akkorde) ─────────────────────────

  static const emAmTakt = Song(
    id: 'em-am-takt',
    title: 'Em–Am Takt',
    category: SongCategory.beginnerExercises,
    difficulty: 1,
    bpm: 70,
    summary: 'Zwei Takte Em, zwei Takte Am — ruhiger Wechsel ohne Hektik.',
    source: SongSource(
      kind: SongSourceKind.original,
      note: 'eigen — eigene Übungs-Komposition für genesis (kein bestehendes Lied).',
    ),
    sections: [
      SongSection(id: 'a', label: 'Teil A', startBeat: 0, endBeat: 8),
      SongSection(id: 'b', label: 'Teil B', startBeat: 8, endBeat: 16),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'em'),
      SongEvent(beat: 4, chordId: 'am'),
      SongEvent(beat: 8, chordId: 'em'),
      SongEvent(beat: 12, chordId: 'am'),
    ],
  );

  static const cGWechsel = Song(
    id: 'c-g-wechsel',
    title: 'C–G Wechsel',
    category: SongCategory.beginnerExercises,
    difficulty: 2,
    bpm: 72,
    summary: 'Klassischer C↔G-Wechsel — Grundlage vieler Lieder.',
    source: SongSource(
      kind: SongSourceKind.original,
      note: 'eigen — eigene Griffwechsel-Übung; keine Melodie aus fremden Werken.',
    ),
    sections: [
      SongSection(
        id: 'langsamer',
        label: 'Langsamer Teil',
        startBeat: 0,
        endBeat: 8,
      ),
      SongSection(
        id: 'doppelt',
        label: 'Doppelter Wechsel',
        startBeat: 8,
        endBeat: 16,
      ),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'c'),
      SongEvent(beat: 4, chordId: 'g'),
      SongEvent(beat: 8, chordId: 'c'),
      SongEvent(beat: 10, chordId: 'g'),
      SongEvent(beat: 12, chordId: 'c'),
      SongEvent(beat: 14, chordId: 'g'),
    ],
  );

  static const gDEmDrei = Song(
    id: 'g-d-em-drei',
    title: 'G–D–Em Drei',
    category: SongCategory.beginnerExercises,
    difficulty: 2,
    bpm: 76,
    summary: 'Drei offene Akkorde im ruhigen Wechsel — Einstieg in G-Dur.',
    source: SongSource(
      kind: SongSourceKind.original,
      note: 'eigen — eigene Drei-Akkord-Übung für genesis.',
    ),
    sections: [
      SongSection(id: 'runde1', label: 'Runde 1', startBeat: 0, endBeat: 12),
      SongSection(id: 'runde2', label: 'Runde 2', startBeat: 12, endBeat: 24),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'g'),
      SongEvent(beat: 4, chordId: 'd'),
      SongEvent(beat: 8, chordId: 'em'),
      SongEvent(beat: 12, chordId: 'g'),
      SongEvent(beat: 16, chordId: 'd'),
      SongEvent(beat: 20, chordId: 'em'),
    ],
  );

  // ─── Englische Traditionals (gemeinfrei) ─────────────────────

  static const amazingGrace = Song(
    id: 'amazing-grace',
    title: 'Amazing Grace',
    category: SongCategory.englishTraditionals,
    difficulty: 2,
    bpm: 72,
    summary: 'Hymne in G-Dur — G, C und D im ruhigen 4/4.',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Traditional/19. Jh. — Melodie „New Britain“ (traditionell), '
          'Text John Newton 1779. Eigenes vereinfachtes Akkord-Arrangement ohne Songtext.',
    ),
    sections: [
      SongSection(id: 'strophe', label: 'Strophe', startBeat: 0, endBeat: 16),
      SongSection(id: 'wieder', label: 'Wiederholung', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'g'),
      SongEvent(beat: 4, chordId: 'c'),
      SongEvent(beat: 8, chordId: 'g'),
      SongEvent(beat: 12, chordId: 'd'),
      SongEvent(beat: 16, chordId: 'g'),
      SongEvent(beat: 20, chordId: 'c'),
      SongEvent(beat: 24, chordId: 'g'),
      SongEvent(beat: 28, chordId: 'd'),
    ],
  );

  static const houseOfTheRisingSun = Song(
    id: 'house-of-the-rising-sun',
    title: 'House of the Rising Sun',
    category: SongCategory.englishTraditionals,
    difficulty: 3,
    bpm: 84,
    summary:
        'Amerikanisches Traditional — Am–C–D–E7 (eigenes Anfänger-Arrangement).',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Traditional — amerikanisches Volkslied (Melodie und '
          'Grundstoff vor 1920er). Kein Animals-/Cover-Arrangement; eigenes '
          'vereinfachtes Akkord-Arrangement ohne Songtext.',
    ),
    sections: [
      SongSection(id: 'verse', label: 'Strophe', startBeat: 0, endBeat: 16),
      SongSection(id: 'turn', label: 'Wendung', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'am'),
      SongEvent(beat: 4, chordId: 'c'),
      SongEvent(beat: 8, chordId: 'd'),
      SongEvent(beat: 12, chordId: 'e7'),
      SongEvent(beat: 16, chordId: 'am'),
      SongEvent(beat: 20, chordId: 'c'),
      SongEvent(beat: 24, chordId: 'e7'),
      SongEvent(beat: 28, chordId: 'am'),
    ],
  );

  static const ohSusanna = Song(
    id: 'oh-susanna',
    title: 'Oh! Susanna',
    category: SongCategory.englishTraditionals,
    difficulty: 2,
    bpm: 100,
    summary: 'Stephen Foster — fröhliches C–G–G7-Strumming.',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Stephen Foster (1848; † 1864, Schutzfrist abgelaufen). '
          'Eigenes Akkord-Arrangement ohne Songtext.',
    ),
    sections: [
      SongSection(id: 'a', label: 'Teil A', startBeat: 0, endBeat: 16),
      SongSection(id: 'b', label: 'Teil B', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'c'),
      SongEvent(beat: 4, chordId: 'g'),
      SongEvent(beat: 8, chordId: 'c'),
      SongEvent(beat: 12, chordId: 'g7'),
      SongEvent(beat: 16, chordId: 'c'),
      SongEvent(beat: 20, chordId: 'g'),
      SongEvent(beat: 24, chordId: 'g7'),
      SongEvent(beat: 28, chordId: 'c'),
    ],
  );

  static const scarboroughFair = Song(
    id: 'scarborough-fair',
    title: 'Scarborough Fair',
    category: SongCategory.englishTraditionals,
    difficulty: 3,
    bpm: 78,
    summary: 'Englische Ballade — Am und Em im modalen Wechsel.',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Traditional/englische Ballade (Child Ballad-Tradition, '
          'Melodie vor 19. Jh.). Eigenes vereinfachtes Akkord-Arrangement '
          'ohne Songtext; keine geschützten Modern-Arrangements.',
    ),
    sections: [
      SongSection(id: 'verse', label: 'Strophe', startBeat: 0, endBeat: 16),
      SongSection(id: 'reply', label: 'Antwort', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'am'),
      SongEvent(beat: 4, chordId: 'g'),
      SongEvent(beat: 8, chordId: 'am'),
      SongEvent(beat: 12, chordId: 'em'),
      SongEvent(beat: 16, chordId: 'am'),
      SongEvent(beat: 20, chordId: 'c'),
      SongEvent(beat: 24, chordId: 'g'),
      SongEvent(beat: 28, chordId: 'am'),
    ],
  );

  // ─── Polnische Volkslieder (gemeinfrei) ──────────────────────

  static const stoLat = Song(
    id: 'sto-lat',
    title: 'Sto lat',
    category: SongCategory.polishFolk,
    difficulty: 1,
    bpm: 96,
    summary: 'Polnisches Geburtstagslied — G, C und D, sehr zugänglich.',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Traditional — polnisches Volkslied/Geburtstagstradition '
          '(Melodie anonym, 19. Jh./Traditional). Eigenes Akkord-Arrangement '
          'ohne Songtext.',
    ),
    sections: [
      SongSection(id: 'a', label: 'Teil A', startBeat: 0, endBeat: 16),
      SongSection(id: 'b', label: 'Teil B', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'g'),
      SongEvent(beat: 4, chordId: 'c'),
      SongEvent(beat: 8, chordId: 'g'),
      SongEvent(beat: 12, chordId: 'd'),
      SongEvent(beat: 16, chordId: 'g'),
      SongEvent(beat: 20, chordId: 'c'),
      SongEvent(beat: 24, chordId: 'd'),
      SongEvent(beat: 28, chordId: 'g'),
    ],
  );

  static const wlazlKotek = Song(
    id: 'wlazl-kotek',
    title: 'Wlazł kotek na płotek',
    category: SongCategory.polishFolk,
    difficulty: 1,
    bpm: 88,
    summary: 'Polnisches Kinderlied — C und G im ruhigen Wechsel.',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Traditional — polnisches Kinderlied (Melodie anonym/'
          'Volkstradition). Eigenes Anfänger-Arrangement ohne Songtext.',
    ),
    sections: [
      SongSection(id: 'strophe', label: 'Strophe', startBeat: 0, endBeat: 16),
      SongSection(id: 'wieder', label: 'Wiederholung', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'c'),
      SongEvent(beat: 4, chordId: 'g'),
      SongEvent(beat: 8, chordId: 'c'),
      SongEvent(beat: 12, chordId: 'g'),
      SongEvent(beat: 16, chordId: 'c'),
      SongEvent(beat: 20, chordId: 'g'),
      SongEvent(beat: 24, chordId: 'c'),
      SongEvent(beat: 28, chordId: 'g'),
    ],
  );

  static const szlaDzieweczka = Song(
    id: 'szla-dzieweczka',
    title: 'Szła dzieweczka do laseczka',
    category: SongCategory.polishFolk,
    difficulty: 2,
    bpm: 92,
    summary: 'Polnisches Volkslied — G–D–Em–C im flüssigen Strumming.',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Traditional — polnisches Volkslied (Melodie anonym, '
          '19. Jh./Volkstradition). Eigenes Akkord-Arrangement ohne Songtext.',
    ),
    sections: [
      SongSection(id: 'a', label: 'Teil A', startBeat: 0, endBeat: 16),
      SongSection(id: 'b', label: 'Teil B', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'g'),
      SongEvent(beat: 4, chordId: 'd'),
      SongEvent(beat: 8, chordId: 'em'),
      SongEvent(beat: 12, chordId: 'c'),
      SongEvent(beat: 16, chordId: 'g'),
      SongEvent(beat: 20, chordId: 'd'),
      SongEvent(beat: 24, chordId: 'c'),
      SongEvent(beat: 28, chordId: 'g'),
    ],
  );

  // ─── Klassik ──────────────────────────────────────────────────

  static const odeAnDieFreude = Song(
    id: 'ode-an-die-freude',
    title: 'Ode an die Freude',
    category: SongCategory.classical,
    difficulty: 3,
    bpm: 100,
    summary: 'Beethovens Melodie als Anfänger-Akkordfolge (G–D–Em–C).',
    source: SongSource(
      kind: SongSourceKind.publicDomain,
      note:
          'gemeinfrei: Ludwig van Beethoven, 9. Sinfonie (1824) — Melodie '
          'gemeinfrei (Tod 1827, Schutzfrist abgelaufen). Eigenes vereinfachtes '
          'Akkord-Arrangement ohne Partitur-Kopie.',
    ),
    sections: [
      SongSection(id: 'thema', label: 'Thema', startBeat: 0, endBeat: 16),
      SongSection(id: 'antwort', label: 'Antwort', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'g'),
      SongEvent(beat: 4, chordId: 'd'),
      SongEvent(beat: 8, chordId: 'em'),
      SongEvent(beat: 12, chordId: 'c'),
      SongEvent(beat: 16, chordId: 'g'),
      SongEvent(beat: 20, chordId: 'd'),
      SongEvent(beat: 24, chordId: 'c'),
      SongEvent(beat: 28, chordId: 'g'),
    ],
  );

  // ─── Eigene Pop/Rock-Strumming-Originale ──────────────────────

  static const neonspur = Song(
    id: 'neonspur',
    title: 'Neonspur',
    category: SongCategory.originalPopRock,
    difficulty: 3,
    bpm: 108,
    summary:
        'Eigenes Pop-Strumming: C–G–Am–Em — klassischer Vier-Akkord-Drive.',
    source: SongSource(
      kind: SongSourceKind.original,
      note: 'eigen — originale Akkordfolge und Komposition für genesis.',
    ),
    sections: [
      SongSection(id: 'verse', label: 'Strophe', startBeat: 0, endBeat: 16),
      SongSection(id: 'chorus', label: 'Refrain', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'c'),
      SongEvent(beat: 4, chordId: 'g'),
      SongEvent(beat: 8, chordId: 'am'),
      SongEvent(beat: 12, chordId: 'em'),
      SongEvent(beat: 16, chordId: 'c'),
      SongEvent(beat: 20, chordId: 'g'),
      SongEvent(beat: 24, chordId: 'am'),
      SongEvent(beat: 28, chordId: 'em'),
    ],
  );

  static const nachtschicht = Song(
    id: 'nachtschicht',
    title: 'Nachtschicht',
    category: SongCategory.originalPopRock,
    difficulty: 4,
    bpm: 116,
    summary: 'Eigenes Rock-Strumming: Em–C–G–D — etwas zügigeres Tempo.',
    source: SongSource(
      kind: SongSourceKind.original,
      note: 'eigen — originale Rock-Akkordfolge für genesis (kein Cover).',
    ),
    sections: [
      SongSection(id: 'riff', label: 'Riff', startBeat: 0, endBeat: 16),
      SongSection(id: 'bridge', label: 'Bridge', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'em'),
      SongEvent(beat: 4, chordId: 'c'),
      SongEvent(beat: 8, chordId: 'g'),
      SongEvent(beat: 12, chordId: 'd'),
      SongEvent(beat: 16, chordId: 'em'),
      SongEvent(beat: 20, chordId: 'c'),
      SongEvent(beat: 24, chordId: 'd'),
      SongEvent(beat: 28, chordId: 'em'),
    ],
  );

  static const kuestenwind = Song(
    id: 'kuestenwind',
    title: 'Küstenwind',
    category: SongCategory.originalPopRock,
    difficulty: 3,
    bpm: 102,
    summary: 'Eigenes Pop-Rock-Stück: G–D–Em–C (I–V–vi–IV) im Strumming.',
    source: SongSource(
      kind: SongSourceKind.original,
      note: 'eigen — originale Pop/Rock-Komposition für genesis.',
    ),
    sections: [
      SongSection(id: 'verse', label: 'Strophe', startBeat: 0, endBeat: 16),
      SongSection(id: 'chorus', label: 'Refrain', startBeat: 16, endBeat: 32),
    ],
    events: [
      SongEvent(beat: 0, chordId: 'g'),
      SongEvent(beat: 4, chordId: 'd'),
      SongEvent(beat: 8, chordId: 'em'),
      SongEvent(beat: 12, chordId: 'c'),
      SongEvent(beat: 16, chordId: 'g'),
      SongEvent(beat: 20, chordId: 'd'),
      SongEvent(beat: 24, chordId: 'em'),
      SongEvent(beat: 28, chordId: 'c'),
    ],
  );
}
