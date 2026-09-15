import '../chords/beginner_chords.dart';
import 'lesson.dart';

/// 10 Lektionen — eigener Text, Anfänger-Fundamentals (nichts kopiert).
abstract final class BeginnerLessons {
  static const List<Lesson> all = [
    Lesson(
      id: 'kennenlernen',
      title: 'Gitarre kennenlernen',
      summary:
          'Bevor du Töne greifst, orientierst du dich: Was ist vorne, wo sind '
          'die Saiten, und wie heißt was am Hals.',
      steps: [
        'Lege die Gitarre so, dass der Korpus auf dem rechten Oberschenkel liegt '
            '(Rechtshänder) und der Hals nach links zeigt.',
        'Die dickste Saite liegt oben (tiefe E), die dünnste unten (hohe e).',
        'Zähle von unten nach oben: 1 (e), 2 (h), 3 (g), 4 (d), 5 (a), 6 (E).',
        'Finde den Sattel (Nut) am Kopf und die Bundstäbe am Hals — das sind '
            'deine Orientierungspunkte.',
      ],
      practiceHint:
          'Tipp mit dem Daumen der Schlaghand nacheinander alle sechs Saiten an. '
          'Sag dabei laut die Nummer.',
    ),
    Lesson(
      id: 'halten',
      title: 'Richtig halten und sitzen',
      summary:
          'Gute Haltung spart Kraft und verhindert Scheppern. Ziel: entspannt '
          'sitzen, klarer Ton mit möglichst wenig Druck.',
      steps: [
        'Setz dich aufrecht hin — nicht in die Couch sinken.',
        'Der Hals zeigt leicht nach oben, nicht Richtung Boden.',
        'Greifhand von unten um den Hals: Daumen hinter dem Hals, ungefähr '
            'gegenüber dem Mittelfinger.',
        'Fingerspitzen nah hinter dem Bunddraht andrücken — nicht mitten im Bund.',
        'Schlaghand entspannt über dem Schallloch bzw. den Tonabnehmern; '
            'Schultern locker lassen.',
      ],
      practiceHint:
          'Halte die Gitarre zwei Minuten in Spielposition, ohne zu spielen. '
          'Wenn der Hals absinkt oder der Rücken rund wird: neu ausrichten.',
    ),
    Lesson(
      id: 'stimmen',
      title: 'Stimmen — Grundlage für alles',
      summary:
          'Eine verstimmte Gitarre frustriert mehr als falsche Finger. Stimme '
          'vor jeder Übungseinheit mit dem eingebauten Tuner.',
      steps: [
        'Öffne den Bereich „Stimmen“ und starte das Mikrofon.',
        'Schlage eine Saite klar an und warte, bis die Anzeige nahe an 0 Cent liegt.',
        'Standard von dick nach dünn: E–A–D–G–H–E.',
        'Kleine Wirbel-Drehungen, dann erneut prüfen — ruhiger Raum hilft.',
      ],
      opensTuner: true,
      practiceHint:
          'Stimme alle sechs Saiten. Danach noch einmal die tiefe E und die hohe e — '
          'sie verstimmen sich oft als Erste.',
    ),
    Lesson(
      id: 'erster-akkord-em',
      title: 'Erster Akkord: Em',
      summary:
          'Em (E-Moll) ist der freundlichste Einstieg: nur zwei Finger, alle '
          'Saiten klingen mit. Das farbige Griffbrett zeigt dir exakt, welcher '
          'Finger wohin gehört.',
      steps: [
        'Mittelfinger (2) auf die A-Saite im 2. Bund setzen.',
        'Ringfinger (3) auf die D-Saite im 2. Bund setzen.',
        'Die übrigen Saiten bleiben leer — nichts dämpfen.',
        'Schlage langsam von der tiefen E zur hohen e; jeder Ton soll klar sein.',
        'Scheppert etwas? Finger aufrichten oder näher an den Bund rücken.',
      ],
      chord: BeginnerChords.em,
      practiceHint:
          'Baue Em zehnmal auf und ab. Ziel: in unter fünf Sekunden einen klaren Klang.',
    ),
    Lesson(
      id: 'akkord-am',
      title: 'Zweiter Akkord: Am',
      summary:
          'Am (A-Moll) braucht drei Finger und dämpft die tiefe E-Saite (×). '
          'Verglichen mit Em klingt Am etwas „kleiner“ und melancholischer.',
      steps: [
        'Zeigefinger (1) auf die h-Saite im 1. Bund.',
        'Mittelfinger (2) auf die D-Saite im 2. Bund.',
        'Ringfinger (3) auf die g-Saite im 2. Bund.',
        'Die tiefe E (Saite 6) bleibt stumm — im Diagramm als × markiert.',
        'Prüfe, dass die hohe e leer mitklingt und nicht versehentlich abgedämpft wird.',
      ],
      chord: BeginnerChords.am,
      practiceHint:
          'Spiele Am, halte vier ruhige Schläge, dann Finger lösen und neu setzen.',
    ),
    Lesson(
      id: 'griffwechsel',
      title: 'Griffwechsel: Em ↔ Am',
      summary:
          'Musik entsteht beim Wechseln. Geschwindigkeit ist egal — saubere Töne '
          'und eine ruhige Hand sind das Ziel.',
      steps: [
        'Baue Em auf und zähle langsam „eins-zwei-drei-vier“.',
        'Wechsle zu Am und zähle wieder vier.',
        'Zurück zu Em — plane den Fingerweg kurz im Kopf, bevor die Hand fliegt.',
        'Bewege nur so viel wie nötig; kleine Wege schlagen große Sprünge.',
        'Wenn es kracht: Pause, Griff neu aufbauen, dann weiter.',
      ],
      chord: BeginnerChords.em,
      practiceHint:
          'Übe eine Minute Em↔Am ohne Metronom. Ziel heute: acht ruhige Wechsel hintereinander.',
    ),
    Lesson(
      id: 'akkord-c-g',
      title: 'C und G — die nächsten Bausteine',
      summary:
          'C und G gehören zu den meistgespielten offenen Akkorden. Übe jeden '
          'Griff für sich, bevor du wechselst — Klarheit vor Tempo.',
      steps: [
        'C: tiefe E stumm; Zeigefinger auf h (1. Bund), Mittelfinger auf D (2.), '
            'Ringfinger auf A (3.).',
        'Prüfe C Saite für Saite — besonders die hohe e soll klar klingen.',
        'G: Zeigefinger auf A (2. Bund), Mittelfinger auf E (3.), Ringfinger auf '
            'hohe e (3.).',
        'G spannt die Hand weiter — Finger einzeln setzen, dann gemeinsam andrücken.',
        'Wechsle im Griffbrett-Vorschau zwischen C und G und bilde beide nach.',
      ],
      chord: BeginnerChords.c,
      practiceHint:
          'Eine Minute nur C, eine Minute nur G. Danach im Griffbrett zwischen beiden umschalten.',
    ),
    Lesson(
      id: 'akkord-d',
      title: 'Akkord D',
      summary:
          'D braucht drei Finger auf einem engen Feld und lässt die beiden tiefen '
          'Saiten weg. Der Griff fühlt sich anfangs ungewohnt an — das legt sich.',
      steps: [
        'Saiten 6 und 5 bleiben stumm (×).',
        'Zeigefinger (1) auf die g-Saite im 2. Bund.',
        'Mittelfinger (2) auf die hohe e im 2. Bund.',
        'Ringfinger (3) auf die h-Saite im 3. Bund.',
        'Schlage nur die vier oberen Saiten an und prüfe jeden Ton einzeln.',
      ],
      chord: BeginnerChords.d,
      practiceHint:
          'Baue D achtmal neu auf. Danach vier ruhige Abschläge hintereinander ohne Scheppern.',
    ),
    Lesson(
      id: 'schlagmuster',
      title: 'Erstes Schlagmuster: nur Abschläge',
      summary:
          'Die Schlaghand macht den Groove. Für den Anfang nur Abschläge (↓) — '
          'gleichmäßig zählt mehr als laut.',
      steps: [
        'Handgelenk locker; Impuls aus dem Handgelenk, nicht aus dem ganzen Arm.',
        'Zähle „1 – 2 – 3 – 4“ und schlage auf jedem Schlag nach unten.',
        'Nimm Em: vier Abschläge, kurz Pause, wiederholen.',
        'Dieselbe Übung auf Am — Puls bleibt gleich, nur der Griff wechselt.',
        'Optional Plektrum: leicht angewinkelt halten, nicht verkrampfen.',
      ],
      chord: BeginnerChords.em,
      practiceHint:
          'Zwei Minuten Em mit Abschlägen auf 1–2–3–4. Dann dieselbe Übung auf Am.',
    ),
    Lesson(
      id: 'mini-song',
      title: 'Mini-Song: Em – Am – D – Em',
      summary:
          'Jetzt verbindest du alles zu einer einfachen, eigenen Mini-Folge. '
          'Kein Welthit — aber echte Musik aus drei Griffen und einem Puls.',
      steps: [
        'Takt 1–2: Em mit vier Abschlägen.',
        'Takt 3–4: Am mit vier Abschlägen.',
        'Takt 5–6: D mit vier Abschlägen (nur die klingenden Saiten).',
        'Takt 7–8: zurück zu Em — drei Durchläufe hintereinander.',
        'Holpert ein Wechsel? Bleib einen Takt länger, dann wieder im Vierer-Puls.',
      ],
      chord: BeginnerChords.d,
      practiceHint:
          'Spiele Em–Am–D–Em mindestens zwei Minuten. Fertig? Lektion abhaken und kurz feiern.',
    ),
  ];

  static Lesson? byId(String id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }
}
