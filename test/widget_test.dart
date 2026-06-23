import 'package:flutter_test/flutter_test.dart';
import 'package:guruji_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GurujiApp());
    expect(find.byType(GurujiApp), findsOneWidget);
  });
}
