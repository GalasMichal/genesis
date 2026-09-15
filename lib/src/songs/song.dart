import 'song_category.dart';

/// Herkunftshinweis — Pflichtfeld für urheberrechtssichere Inhalte.
class SongSource {
  const SongSource({
    required this.kind,
    required this.note,
  });

  /// `eigen` oder `gemeinfrei`.
  final SongSourceKind kind;

  /// Kurze Begründung (UI + Audit).
  final String note;

  String get label => kind == SongSourceKind.original ? 'Eigen' : 'Gemeinfrei';
}

enum SongSourceKind { original, publicDomain }

/// Ein Abschnitt zum Loopen (Beat-Bereich, inklusiv start / exklusiv end).
class SongSection {
  const SongSection({
    required this.id,
    required this.label,
    required this.startBeat,
    required this.endBeat,
  });

  final String id;
  final String label;

  /// Start in Beats ab Songbeginn (≥ 0).
  final double startBeat;

  /// Ende in Beats (muss > [startBeat] sein).
  final double endBeat;
}

/// Ein Akkord-Ereignis auf der Beat-Timeline.
///
/// ## Genesis Song-Format (Dokumentation)
///
/// Einfaches internes Format — bewusst kein MusicXML/MIDI:
///
/// ```
/// Song
///   id, title, category, difficulty (1–5), bpm (Standard-Tempo)
///   source: { kind: eigen|gemeinfrei, note: "…" }
///   sections[]: optional { id, label, startBeat, endBeat }
///   events[]: { beat, chordId }
/// ```
///
/// - **beat**: Position in Beats ab 0. Muss **streng monoton steigen**.
/// - **chordId**: ID aus [BeginnerChords] (z. B. `em`, `c`, `g`).
/// - **bpm**: Standard-Tempo in Viertel/Minute; Play-Along skaliert 50–100 %.
/// - Dauer eines Events = bis zum nächsten Event bzw. Songende
///   (`events.last.beat + defaultHoldBeats`).
///
/// Keine Songtexte geschützter Werke — nur Akkordfolgen für Übungen.
class SongEvent {
  const SongEvent({
    required this.beat,
    required this.chordId,
  });

  /// Absolute Beat-Position (≥ 0, monoton steigend im Song).
  final double beat;

  /// Akkord-ID aus dem Anfänger-Datensatz.
  final String chordId;
}

/// Ein Song in der Bibliothek.
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.bpm,
    required this.source,
    required this.events,
    this.summary = '',
    this.sections = const [],
    this.defaultHoldBeats = 4,
  });

  final String id;
  final String title;
  final SongCategory category;

  /// 1 (sehr leicht) … 5 (anspruchsvoll für Anfänger).
  final int difficulty;

  /// Standard-Tempo in BPM (Viertelnoten).
  final int bpm;

  final SongSource source;
  final String summary;
  final List<SongEvent> events;
  final List<SongSection> sections;

  /// Beats, die der letzte Akkord gehalten wird.
  final double defaultHoldBeats;

  /// Gesamtlänge in Beats.
  double get durationBeats {
    if (events.isEmpty) return 0;
    return events.last.beat + defaultHoldBeats;
  }

  /// Dauer eines Events in Beats (bis nächstes bzw. Songende).
  double eventDurationBeats(int index) {
    if (index < 0 || index >= events.length) return 0;
    if (index + 1 < events.length) {
      return events[index + 1].beat - events[index].beat;
    }
    return defaultHoldBeats;
  }

  /// Index des Events bei [beat] (oder −1 wenn vor dem ersten).
  int eventIndexAtBeat(double beat) {
    if (events.isEmpty) return -1;
    if (beat < events.first.beat) return -1;
    var idx = 0;
    for (var i = 0; i < events.length; i++) {
      if (events[i].beat <= beat) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }
}
