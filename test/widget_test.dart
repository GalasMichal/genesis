import 'package:flutter_test/flutter_test.dart';

import 'package:genesis/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App-Shell zeigt Lernen und wechselt zu Stimmen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GenesisApp());
    await tester.pumpAndSettle();

    expect(find.text('Lernen'), findsWidgets);
    expect(find.text('Dein Fortschritt'), findsOneWidget);
    expect(find.text('Anfänger-Pfad'), findsOneWidget);

    await tester.tap(find.text('Stimmen').last);
    await tester.pumpAndSettle();

    expect(find.text('Stimmen'), findsWidgets);
    expect(find.textContaining('Standard-Stimmung'), findsOneWidget);
    expect(find.text('Mikrofon starten'), findsOneWidget);
  });
}
