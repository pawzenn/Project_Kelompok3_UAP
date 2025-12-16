import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.login));
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
