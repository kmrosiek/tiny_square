import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_square/main.dart';
import 'package:tiny_square/core/di/injection.dart';

void main() {
  setUpAll(() {
    setupDependencies();
  });

  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
