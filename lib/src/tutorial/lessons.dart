import '../chords/beginner_chords.dart';
import 'lesson.dart';

/// 9 Lektionen — eigener Text, Justin-Guitar-Niveau (nichts kopiert).
abstract final class BeginnerLessons {
  static const List<Lesson> all = [
    Lesson(
      id: 'kennenlernen',
      title: 'Gitarre kennenlernen',
      body:
          'Nimm die Gitarre so in die Hand, dass der Korpus bequem auf dem '
          'rechten Oberschenkel liegt (Rechtshänder) und der Hals nach links '
          'zeigt. Die tiefe E-Saite — die dickste — liegt oben, die dünne e-Saite unten.\n\n'
          'Zähle die Saiten von unten nach oben: 1 (e), 2 (h), 3 (g), 4 (d), 5 (a), 6 (E). '
          'Merke dir nur die Reihenfolge; Töne kommen später. Der Sattel (Nut) sitzt '
          'am Kopf der Gitarre, die Bünde sind die Metallstäbe auf dem Hals.\n\n'
          'Ziel dieser Lektion: Du weißt, wo vorne und hinten ist, und kannst '
          'jede Saite mit dem Namen 1–6 benennen.',
      practiceHint:
          'Tipp mit dem Daumen der Schlaghand nacheinander alle sechs Saiten an. '
          'Sag dabei laut die Nummer.',
    ),
    Lesson(
      id: 'halten',
      title: 'Richtig halten und sitzen',
      body:
          'Setz dich aufrecht hin — nicht in die Couch sinken. Der Gitarrenhals '
          'soll leicht nach oben zeigen, nicht Richtung Boden. Die Greifhand '
          '(links bei Rechtshändern) kommt von unten um den Hals: Daumen hinter '
          'dem Hals ungefähr gegenüber dem Mittelfinger, nicht über den Hals gekrümmt.\n\n'
          'Die Fingerspitzen drücken nah hinter dem Bunddraht — nicht mitten im '
          'Bund und nicht auf dem Draht. Zu viel Kraft macht die Hand steif; '
          'zu wenig erzeugt Scheppern. Finde die kleinste Kraft, mit der der Ton klar klingt.\n\n'
          'Die Schlaghand hängt entspannt über dem Schallloch (Akustik) bzw. '
          'über den Tonabnehmern (E-Gitarre). Schultern locker lassen.',
      practiceHint:
          'Halte die Gitarre zwei Minuten in Spielposition, ohne zu spielen. '
          'Wenn der Hals absinkt oder der Rücken rund wird: neu ausrichten.',
    ),
    Lesson(
      id: 'stimmen',
      title: 'Stimmen — Grundlage für alles',
      body:
          'Eine verstimmte Gitarre frustriert mehr als falsche Finger. Stimme '
          'vor jeder Übungseinheit. In genesis nutzt du den eingebauten Tuner '
          'unter „Stimmen“: Mikrofon starten, eine Saite anschlagen, bis die '
          'Anzeige nahe an 0 Cent liegt.\n\n'
          'Standard-Stimmung von dick nach dünn: E–A–D–G–H–E. '
          'Wenn du unsicher bist, welche Saite du gerade hörst, schau auf die '
          'Saitenleiste im Tuner — sie zeigt den nächsten Treffer.\n\n'
          'Ruhiger Raum hilft. Schlage die Saite klar an und warte kurz, '
          'bevor du den Wirbel drehst. Kleine Drehungen, dann erneut prüfen.',
      opensTuner: true,
      practiceHint:
          'Stimme alle sechs Saiten. Danach noch einmal die tiefe E und die hohe e — '
          'sie verstimmen sich oft als Erste.',
    ),
    Lesson(
      id: 'erster-akkord-em',
      title: 'Erster Akkord: Em',
      body:
          'Em (E-Moll) ist der freundlichste Einstieg: nur zwei Finger, alle '
          'Saiten klingen mit. Mittelfinger (2) auf die A-Saite im 2. Bund, '
          'Ringfinger (3) auf die D-Saite im 2. Bund. Die übrigen Saiten bleiben leer.\n\n'
          'Drücke nah hinter dem Bunddraht. Schlage langsam von der tiefen E '
          'zur hohen e — jeder Ton soll klar sein. Scheppert etwas? Finger '
          'etwas aufrichten oder näher an den Bund rücken.\n\n'
          'Das farbige Griffbrett zeigt dir exakt, welcher Finger wohin gehört. '
          'Farben und Nummern bleiben in der ganzen App gleich.',
      chord: BeginnerChords.em,
      practiceHint:
          'Baue Em zehnmal auf und ab. Ziel: in unter fünf Sekunden einen klaren Klang.',
    ),
    Lesson(
      id: 'akkord-am',
      title: 'Zweiter Akkord: Am',
      body:
          'Am (A-Moll) braucht drei Finger und dämpft die tiefe E-Saite (×). '
          'Zeigefinger (1) auf die h-Saite im 1. Bund, Mittelfinger (2) auf die '
          'D-Saite im 2. Bund, Ringfinger (3) auf die g-Saite im 2. Bund.\n\n'
          'Achte darauf, dass der Zeigefinger die hohe e-Saite nicht versehentlich '
          'mitdrückt oder abdämpft — sie soll leer mitklingen. Die tiefe E lässt '
          'du weg oder dämpfst sie leicht mit dem Daumen am Halsrand.\n\n'
          'Vergleiche den Klang mit Em: Am klingt etwas „kleiner“ und melancholischer. '
          'Beide Akkorde brauchst du gleich als Nächstes zum Wechseln.',
      chord: BeginnerChords.am,
      practiceHint:
          'Spiele Am, halte vier ruhige Schläge, dann Finger lösen und neu setzen.',
    ),
    Lesson(
      id: 'akkord-c-g',
      title: 'C und G — die nächsten Bausteine',
      body:
          'C und G gehören zu den meistgespielten offenen Akkorden. '
          'Bei C bleibt die tiefe E stumm: Zeigefinger auf h im 1. Bund, '
          'Mittelfinger auf D im 2., Ringfinger auf A im 3. Bund.\n\n'
          'G spannt die Hand weiter: Mittelfinger auf E im 3. Bund, Zeigefinger '
          'auf A im 2., Ringfinger auf die hohe e im 3. Bund. Am Anfang fühlt '
          'sich G unbequem an — normal. Finger einzeln setzen, dann gemeinsam andrücken.\n\n'
          'Übe jeden Griff für sich, bevor du wechselst. Klarheit vor Tempo.',
      chord: BeginnerChords.c,
      practiceHint:
          'Eine Minute nur C, eine Minute nur G. Danach im Griffbrett zwischen beiden umschalten.',
    ),
    Lesson(
      id: 'griffwechsel',
      title: 'Griffwechsel: Em ↔ Am',
      body:
          'Musik entsteht beim Wechseln. Starte mit Em, zähle langsam „eins-zwei-drei-vier“, '
          'dann wechsle zu Am und zähle wieder vier. Zurück zu Em. '
          'Geschwindigkeit ist egal — saubere Töne und ruhige Hand sind das Ziel.\n\n'
          'Trick: Bewege nur so viel wie nötig. Beim Wechsel Em→Am bleibt oft '
          'ein Finger in der Nähe seiner neuen Position; plane den Weg kurz im Kopf, '
          'bevor die Finger fliegen.\n\n'
          'Wenn es kracht: Pause, Griff neu aufbauen, dann weiter. '
          'Fünf saubere Wechsel schlagen fünfzig hektische.',
      chord: BeginnerChords.em,
      practiceHint:
          'Übe eine Minute Em↔Am ohne Metronom. Ziel heute: acht ruhige Wechsel hintereinander.',
    ),
    Lesson(
      id: 'schlagmuster',
      title: 'Erstes Schlagmuster: nur Abschläge',
      body:
          'Die Schlaghand macht den Groove. Für den Anfang nur Abschläge (↓): '
          'Handgelenk locker, Impuls aus dem Handgelenk, nicht aus dem ganzen Arm. '
          'Zähle „1 – 2 – 3 – 4“ und schlage auf jedem Schlag nach unten über die Saiten.\n\n'
          'Nimm Em. Vier Abschläge, kurz Pause, wiederholen. Später derselbe Puls auf Am. '
          'Gleichmäßigkeit zählt mehr als Lautstärke — lieber leise und stabil.\n\n'
          'Wenn du einen Plektrum nutzt: leicht angewinkelt halten, nicht verkrampfen. '
          'Fingerpicking kommt später; zuerst der klare Abschlag.',
      chord: BeginnerChords.em,
      practiceHint:
          'Zwei Minuten Em mit Abschlägen auf 1–2–3–4. Dann dieselbe Übung auf Am.',
    ),
    Lesson(
      id: 'mini-song',
      title: 'Mini-Song: Em – Am – Em – Am',
      body:
          'Jetzt verbindest du alles: Em (vier Abschläge) → Am (vier Abschläge) → '
          'zurück, und so weiter. Das ist noch kein Welthit — aber es ist echte Musik '
          'aus zwei Griffen und einem Puls.\n\n'
          'Spiele drei Durchläufe hintereinander. Wenn ein Wechsel holpert, '
          'bleib einen Takt länger auf dem Akkord und wechsle erst, wenn du bereit bist. '
          'Danach wieder im Tempo der Vierer-Zählung.\n\n'
          'Als Nächstes im Übungs-Bereich: einzelne Töne und Griffe mit dem Mikrofon prüfen. '
          'Im Lernpfad hast du jetzt Haltung, Stimmung, zwei Moll-Akkorde, '
          'C/G als Ausblick, Wechsel und ein Schlagmuster — eine solide Basis.',
      chord: BeginnerChords.am,
      practiceHint:
          'Spiele die Folge Em–Am mindestens zwei Minuten. Fertig? Lektion abhaken und kurz feiern.',
    ),
  ];

  static Lesson? byId(String id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }
}
