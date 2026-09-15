import 'package:flutter_test/flutter_test.dart';

import 'package:genesis/app.dart';

void main() {
  testWidgets('App-Shell zeigt Lernen und wechselt zu Stimmen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GenesisApp());

    expect(find.text('Lernen'), findsWidgets);
    expect(find.text('Tutorial-Pfad'), findsOneWidget);

    await tester.tap(find.text('Stimmen').last);
    await tester.pumpAndSettle();

    expect(find.text('Stimmen'), findsWidgets);
    expect(find.textContaining('Standard-Stimmung'), findsOneWidget);
    expect(find.text('Mikrofon starten'), findsOneWidget);
  });
}
