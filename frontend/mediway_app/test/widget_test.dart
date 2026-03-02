import 'package:flutter_test/flutter_test.dart';
import 'package:mediway_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MediWayApp());
    expect(find.byType(MediWayApp), findsOneWidget);
  });
}