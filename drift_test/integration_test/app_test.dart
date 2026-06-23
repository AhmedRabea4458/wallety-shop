import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:drift_test/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end wallet flow', () {
    testWidgets('add, view, edit and delete a wallet', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Clean up wallets left from previous runs.
      while (find.text('No wallets yet. Tap + to add one.').evaluate().isEmpty) {
        await tester.tap(find.widgetWithText(TextButton, 'Delete').first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Add wallet.
      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Wallet name',
      ), 'Teaching Wallet');

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Starting balance',
      ), '100.00');

      await tester.tap(find.text('Save Wallet'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Teaching Wallet'), findsOneWidget);
      expect(find.textContaining('Balance: \$100.00'), findsOneWidget);

      // View detail and add transaction.
      await tester.tap(find.widgetWithText(TextButton, 'View'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Teaching Wallet'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Note',
      ), 'Demo expense');

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Amount',
      ), '-25.50');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Demo expense'), findsOneWidget);
      expect(find.text('\$-25.50'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Edit wallet.
      await tester.tap(find.widgetWithText(TextButton, 'Edit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Wallet name',
      ), 'Updated Wallet');

      await tester.tap(find.text('Update Wallet'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Updated Wallet'), findsOneWidget);
      expect(find.text('Teaching Wallet'), findsNothing);

      // Delete wallet.
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Updated Wallet'), findsNothing);
      expect(find.text('No wallets yet. Tap + to add one.'), findsOneWidget);
    });
  });
}
