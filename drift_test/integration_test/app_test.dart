// ============================================================================
// END-TO-END INTEGRATION TEST
// ============================================================================
// This test launches the real app and exercises every screen using the
// explicit buttons in the UI:
//   1. Add a wallet
//   2. View wallet detail
//   3. Add a transaction
//   4. Edit the wallet
//   5. Delete the wallet
//
// Run it with:
//   flutter test integration_test/app_test.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:drift_test/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end wallet flow', () {
    testWidgets('add, view, edit and delete a wallet', (tester) async {
      // Launch the real app.
      app.main();

      // Wait for the first Stream event to arrive.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ----------------------------------------------------------------------
      // Clean up wallets left from previous test runs
      // ----------------------------------------------------------------------
      // The real database file persists between runs, so remove any existing
      // wallets before we start the main test flow.
      while (find.text('No wallets yet. Tap + to add one.').evaluate().isEmpty) {
        await tester.tap(find.widgetWithText(TextButton, 'Delete').first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // ----------------------------------------------------------------------
      // 1. ADD WALLET
      // ----------------------------------------------------------------------
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

      // Verify the wallet appears in the list.
      expect(find.text('Teaching Wallet'), findsOneWidget);
      expect(find.textContaining('Balance: \$100.00'), findsOneWidget);

      // ----------------------------------------------------------------------
      // 2. VIEW WALLET DETAIL AND ADD TRANSACTION
      // ----------------------------------------------------------------------
      await tester.tap(find.widgetWithText(TextButton, 'View'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // We are now on the detail screen.
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

      // Verify the transaction appears.
      expect(find.text('Demo expense'), findsOneWidget);
      expect(find.text('\$-25.50'), findsOneWidget);

      // Go back to the wallets list.
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ----------------------------------------------------------------------
      // 3. EDIT WALLET
      // ----------------------------------------------------------------------
      await tester.tap(find.widgetWithText(TextButton, 'Edit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Wallet name',
      ), 'Updated Wallet');

      await tester.tap(find.text('Update Wallet'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Updated Wallet'), findsOneWidget);
      expect(find.text('Teaching Wallet'), findsNothing);

      // ----------------------------------------------------------------------
      // 4. DELETE WALLET
      // ----------------------------------------------------------------------
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The wallet should be gone and the empty state shown.
      expect(find.text('Updated Wallet'), findsNothing);
      expect(find.text('No wallets yet. Tap + to add one.'), findsOneWidget);
    });
  });
}
