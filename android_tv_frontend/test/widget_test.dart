import 'package:flutter_test/flutter_test.dart';
import 'package:android_tv_frontend/main.dart';

void main() {
  testWidgets('Home shows Weather + Fitness title', (WidgetTester tester) async {
    await tester.pumpWidget(const TVDashboardApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Weather + Fitness'), findsOneWidget);
  });

  testWidgets('Has Weather and Fitness section headers', (WidgetTester tester) async {
    await tester.pumpWidget(const TVDashboardApp());
    await tester.pumpAndSettle();
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);
  });
}
