import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_usage.dart';

class WalletLimitCalculator {
  static WalletUsage calculate({
    required WalletEntity wallet,
    required List<OperationEntity> operations,
    required List<WalletAdjustmentEntity> adjustments,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final weekdayOffset = (reference.weekday - DateTime.monday) % 7;
    final weekStart = today.subtract(Duration(days: weekdayOffset));
    final monthStart = DateTime(reference.year, reference.month, 1);

    double dailyUsed = 0;
    double weeklyUsed = 0;
    double monthlyUsed = 0;

    for (final operation in operations) {
      if (operation.walletId != wallet.id) continue;
      if (operation.providerType != ProviderType.vodafoneCash) continue;
      if (operation.operationType != OperationType.deposit &&
          operation.operationType != OperationType.withdrawal) {
        continue;
      }

      final opDate = DateTime(
        operation.createdAt.year,
        operation.createdAt.month,
        operation.createdAt.day,
      );
      final amount = operation.amount;

      if (opDate == today) {
        dailyUsed += amount;
      }
      if (!opDate.isBefore(weekStart)) {
        weeklyUsed += amount;
      }
      if (!opDate.isBefore(monthStart)) {
        monthlyUsed += amount;
      }
    }

    // Apply manual adjustments
    for (final adjustment in adjustments) {
      if (adjustment.walletId != wallet.id) continue;
      if (adjustment.periodType == 'daily') {
        dailyUsed += adjustment.amount;
      } else if (adjustment.periodType == 'monthly') {
        monthlyUsed += adjustment.amount;
      }
    }

    return WalletUsage(
      dailyUsed: dailyUsed,
      dailyLimit: wallet.dailyLimit,
      weeklyUsed: weeklyUsed,
      weeklyLimit: wallet.weeklyLimit,
      monthlyUsed: monthlyUsed,
      monthlyLimit: wallet.monthlyLimit,
    );
  }
}
