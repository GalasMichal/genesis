# genesis

Gitarren-Lern-App für Anfänger — mobile-first, schlicht und ehrlich.

Mit dem Mikrofon prüft die App, ob du richtig spielst. Ein Tutorial-Pfad, ein
Griffbrett und eine Songbibliothek (eigener und gemeinfreier Content) folgen
Schritt für Schritt.

Dieses Repo enthält das **P0-Grundgerüst**: Flutter-Projekt mit Bottom
Navigation (Lernen, Üben, Songs, Stimmen) und Platzhalter-Screens.

## Voraussetzung

- [Flutter](https://docs.flutter.dev/get-started/install) auf dem **stable**-Kanal

Prüfen:

```bash
flutter --version
```

## Lokal starten

Abhängigkeiten holen (einmalig im Projektordner):

```bash
flutter pub get
```

Im Browser:

```bash
flutter run -d chrome
```

Auf einem verbundenen Gerät oder Emulator:

```bash
flutter devices
flutter run -d <gerät-id>
```

## Checks

```bash
flutter analyze
flutter test
flutter build web --release
```

## Struktur

```
lib/
  main.dart          # Einstieg
  app.dart           # Shell + Navigation
  theme.dart         # Material 3, Dark Theme
  screens/           # Lernen, Üben, Songs, Stimmen
```
