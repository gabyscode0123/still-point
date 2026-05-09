import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillpoint/main.dart';

void main() {
  testWidgets('Stillpoint shows the dashboard and add entry sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StillpointApp());

    expect(
      find.text(
        'Your wellness score reflects patterns from your last 14 check-ins.',
      ),
      findsOneWidget,
    );
    expect(find.text('Mood & Stress Pattern'), findsOneWidget);
    expect(find.text('Last 14 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Add daily entry'));
    await tester.pumpAndSettle();

    expect(find.text('Log Today'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Reflections'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See More'));
    await tester.pumpAndSettle();

    expect(find.text('All Check-ins'), findsOneWidget);
  });
}
