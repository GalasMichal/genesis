import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/app.dart';
import 'package:genesis/screens/song_detail_screen.dart';
import 'package:genesis/screens/songs_screen.dart';
import 'package:genesis/src/songs/song_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Songs-Tab zeigt Bibliothek und öffnet Detail', (tester) async {
    await tester.pumpWidget(const GenesisApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Songs').last);
    await tester.pumpAndSettle();

    expect(find.text('Bibliothek'), findsOneWidget);
    expect(find.text('Em–Am Takt'), findsOneWidget);
    expect(find.textContaining('Alle'), findsWidgets);

    await tester.tap(find.text('Em–Am Takt'));
    await tester.pumpAndSettle();

    expect(find.byType(SongDetailScreen), findsOneWidget);
    expect(find.text('Play-Along'), findsOneWidget);
    expect(find.textContaining('Quelle:'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Akkorde im Song'), findsOneWidget);
  });

  testWidgets('Kategorie-Filter und DifficultyMeter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SongsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DifficultyMeter), findsWidgets);

    await tester.tap(find.text('Polnisch'));
    await tester.pumpAndSettle();

    expect(find.text('Sto lat'), findsOneWidget);
    expect(find.text('Wlazł kotek na płotek'), findsOneWidget);
    expect(find.text('Em–Am Takt'), findsNothing);
  });

  testWidgets('Play-Along startet und Tempo-Slider reagiert', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final song = SongLibrary.emAmTakt;
    await tester.pumpWidget(
      MaterialApp(
        home: SongDetailScreen(song: song),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);
    await tester.drag(slider, const Offset(-80, 0));
    await tester.pump();

    expect(find.textContaining('Tempo'), findsOneWidget);
    expect(find.textContaining('%'), findsWidgets);

    await tester.tap(find.text('Teil A'));
    await tester.pump();

    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('Play'), findsOneWidget);
  });
}
