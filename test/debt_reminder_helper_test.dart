import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense/core/utils/debt_reminder_helper.dart';

void main() {
  group('DebtReminderHelper - Egyptian Phone Normalization', () {
    test('normalizes standard 11-digit mobile starting with 0', () {
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('01012345678'), '201012345678');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('01123456789'), '201123456789');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('01234567890'), '201234567890');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('01512345678'), '201512345678');
    });

    test('normalizes 10-digit mobile without leading 0', () {
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('1012345678'), '201012345678');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('1123456789'), '201123456789');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('1234567890'), '201234567890');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('1512345678'), '201512345678');
    });

    test('normalizes mobile with +20 or 0020 prefix', () {
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('+201012345678'), '201012345678');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('00201012345678'), '201012345678');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('201012345678'), '201012345678');
    });

    test('normalizes numbers with Arabic numerals, dashes, and spaces', () {
      expect(
        DebtReminderHelper.normalizeEgyptianPhoneNumber('٠١٠١٢٣٤٥٦٧٨'),
        '201012345678',
      );
      expect(
        DebtReminderHelper.normalizeEgyptianPhoneNumber('+20 10-1234 5678'),
        '201012345678',
      );
      expect(
        DebtReminderHelper.normalizeEgyptianPhoneNumber('(010) 1234-5678'),
        '201012345678',
      );
    });

    test('handles empty or whitespace strings gracefully', () {
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber(''), '');
      expect(DebtReminderHelper.normalizeEgyptianPhoneNumber('   '), '');
    });
  });

  group('DebtReminderHelper - Arabic Duration Formatting', () {
    final now = DateTime(2026, 9, 26, 12, 0);

    test('returns "اليوم" for debts created today', () {
      final today = DateTime(2026, 9, 26, 8, 0);
      expect(DebtReminderHelper.calculateDebtAgeInDays(today, now), 0);
      expect(DebtReminderHelper.formatDebtAgeArabic(today, now), 'اليوم');
    });

    test('returns "منذ يوم" for debts created 1 day ago', () {
      final yesterday = DateTime(2026, 9, 25, 14, 0);
      expect(DebtReminderHelper.calculateDebtAgeInDays(yesterday, now), 1);
      expect(DebtReminderHelper.formatDebtAgeArabic(yesterday, now), 'منذ يوم');
    });

    test('returns "منذ يومين" for debts created 2 days ago', () {
      final twoDaysAgo = DateTime(2026, 9, 24, 10, 0);
      expect(DebtReminderHelper.calculateDebtAgeInDays(twoDaysAgo, now), 2);
      expect(DebtReminderHelper.formatDebtAgeArabic(twoDaysAgo, now), 'منذ يومين');
    });

    test('returns "منذ X أيام" for debts created 3 to 10 days ago', () {
      final eightDaysAgo = DateTime(2026, 9, 18, 10, 0);
      expect(DebtReminderHelper.calculateDebtAgeInDays(eightDaysAgo, now), 8);
      expect(DebtReminderHelper.formatDebtAgeArabic(eightDaysAgo, now), 'منذ 8 أيام');
    });

    test('returns "منذ X يوم" for debts created 11+ days ago', () {
      final sixteenDaysAgo = DateTime(2026, 9, 10, 10, 0);
      expect(DebtReminderHelper.calculateDebtAgeInDays(sixteenDaysAgo, now), 16);
      expect(DebtReminderHelper.formatDebtAgeArabic(sixteenDaysAgo, now), 'منذ 16 يوم');
    });
  });

  group('DebtReminderHelper - Reminder Message Generation', () {
    test('builds polite Egyptian reminder without "متأخر" and without due date', () {
      final message = DebtReminderHelper.buildDebtReminderMessage(
        customerName: 'أحمد علي',
        remainingAmount: 500.0,
      );

      expect(message.contains('أحمد علي'), isTrue);
      expect(message.contains('500'), isTrue);
      expect(message.contains('متأخر'), isFalse);
      expect(message.contains('تاريخ الاستحقاق'), isFalse);
      expect(message.contains('السلام عليكم'), isTrue);
      expect(message.contains('شاكرين ومقدرين'), isTrue);
    });

    test('includes due date only if explicitly provided', () {
      final dueDate = DateTime(2026, 10, 1);
      final message = DebtReminderHelper.buildDebtReminderMessage(
        customerName: 'محمد سامي',
        remainingAmount: 1250.0,
        dueDate: dueDate,
      );

      expect(message.contains('محمد سامي'), isTrue);
      expect(message.contains('1,250') || message.contains('1250'), isTrue);
      expect(message.contains('تاريخ الاستحقاق'), isTrue);
      expect(message.contains('متأخر'), isFalse);
    });
  });
}
