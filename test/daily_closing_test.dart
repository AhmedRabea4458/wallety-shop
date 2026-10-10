import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense/features/operations/domain/entities/daily_closing_entity.dart';

void main() {
  group('DailyClosingEntity Calculations', () {
    test('calculates net closing balance correctly with standard numbers', () {
      const closing = DailyClosingEntity(
        cashDrawerBalance: 5000.0,
        activeWalletsBalance: 12000.0,
        activeInstaPayBalance: 3000.0,
        customerReceivables: 4500.0,
        outstandingPayables: 2000.0,
      );

      expect(closing.digitalBalance, 15000.0);
      expect(closing.totalAssets, 24500.0);
      expect(closing.netClosingBalance, 22500.0);
      expect(closing.isEmpty, false);
    });

    test('handles zero balances gracefully', () {
      const closing = DailyClosingEntity(
        cashDrawerBalance: 0.0,
        activeWalletsBalance: 0.0,
        activeInstaPayBalance: 0.0,
        customerReceivables: 0.0,
        outstandingPayables: 0.0,
      );

      expect(closing.digitalBalance, 0.0);
      expect(closing.totalAssets, 0.0);
      expect(closing.netClosingBalance, 0.0);
      expect(closing.isEmpty, true);
    });

    test('handles negative net closing position when payables exceed assets', () {
      const closing = DailyClosingEntity(
        cashDrawerBalance: 1000.0,
        activeWalletsBalance: 2000.0,
        activeInstaPayBalance: 0.0,
        customerReceivables: 500.0,
        outstandingPayables: 5000.0,
      );

      expect(closing.digitalBalance, 2000.0);
      expect(closing.totalAssets, 3500.0);
      expect(closing.netClosingBalance, -1500.0);
      expect(closing.isEmpty, false);
    });

    test('calculates decimal precision correctly', () {
      const closing = DailyClosingEntity(
        cashDrawerBalance: 1520.75,
        activeWalletsBalance: 3450.50,
        activeInstaPayBalance: 1029.25,
        customerReceivables: 800.00,
        outstandingPayables: 300.50,
      );

      // 1520.75 + 3450.50 + 1029.25 + 800.00 - 300.50 = 6500.00
      expect(closing.netClosingBalance, closeTo(6500.0, 0.001));
    });
  });
}
