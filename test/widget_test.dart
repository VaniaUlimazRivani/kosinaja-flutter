import 'package:flutter_test/flutter_test.dart';
import 'package:kosinaja_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KosinAjaApp());
    expect(find.text('KosinAja'), findsWidgets);
  });
}
