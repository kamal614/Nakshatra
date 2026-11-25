import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nakshatra_ui/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showcase the consumer journey', (tester) async {
    await tester.pumpWidget(const NakshatraApp());
    Future<void> pause([int seconds = 3]) async {
      await tester.pumpAndSettle();
      await Future<void>.delayed(Duration(seconds: seconds));
    }

    await pause(4);
    await tester.tap(find.text('Browse astrologers'));
    await pause();
    await tester.tap(find.text('View profile').first);
    await pause(4);
    await tester.dragUntilVisible(
      find.text('Chat'),
      find.byType(Scrollable).last,
      const Offset(0, -250),
    );
    await tester.tap(find.text('Chat').last);
    await pause();
    await tester.tap(find.text('Request consultation'));
    await tester.pump();
    await Future<void>.delayed(const Duration(seconds: 4));
    await tester.pump();
    await pause();
    await tester.enterText(
      find.byType(TextField).last,
      'I would like guidance on my career.',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    await Future<void>.delayed(const Duration(seconds: 3));
    await tester.pump();
    await tester.tap(find.byTooltip('End chat'));
    await pause(2);
    await tester.tap(find.text('End session').last);
    await pause(3);
    await tester.tap(find.text('Done'));
    await pause(3);
    await tester.pageBack();
    await pause(2);
    await tester.tap(find.text('Sessions').last);
    await pause(4);
    await tester.tap(find.text('Profile').last);
    await pause(4);
  });
}
