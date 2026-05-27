import 'package:flutter_test/flutter_test.dart';
import 'package:eaze_my_cargo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EazeMyCargo());
    expect(find.byType(EazeMyCargo), findsOneWidget);
  });
}
