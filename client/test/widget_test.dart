import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jeong/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: JeongApp()),
    );
    await tester.pumpAndSettle();

    // Onboarding page should show
    expect(find.text('Skip'), findsOneWidget);
  });
}
