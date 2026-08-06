import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

class ShiftStats {
  final int totalOperations;
  final int depositCount;
  final int withdrawalCount;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalCommissions;
  final double totalNetworkFees;
  final double netProfit;
  final int instaPayCount;

  // Liability stats
  final double customerDebtsCreated;
  final int customerDebtsCreatedCount;
  final double payablesCreated;
  final int payablesCreatedCount;
  final double customerDebtCollected;
  final int customerDebtCollectedCount;
  final double payablesSettled;
  final int payablesSettledCount;

  const ShiftStats({
    required this.totalOperations,
    required this.depositCount,
    required this.withdrawalCount,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalCommissions,
    required this.totalNetworkFees,
    required this.netProfit,
    required this.instaPayCount,
    this.customerDebtsCreated = 0,
    this.customerDebtsCreatedCount = 0,
    this.payablesCreated = 0,
    this.payablesCreatedCount = 0,
    this.customerDebtCollected = 0,
    this.customerDebtCollectedCount = 0,
    this.payablesSettled = 0,
    this.payablesSettledCount = 0,
  });

  double get netCashMovement =>
      totalDeposits + totalCommissions + customerDebtCollected -
      totalWithdrawals - totalNetworkFees - payablesSettled;

  factory ShiftStats.fromOperations(List<OperationEntity> ops) {
    double deposits = 0;
    double withdrawals = 0;
    double commissions = 0;
    double networkFees = 0;
    int instaPayCount = 0;
    int depositCount = 0;
    int withdrawalCount = 0;
    for (final o in ops) {
      if (o.operationType == OperationType.deposit) {
        deposits += o.amount;
        depositCount++;
      } else {
        withdrawals += o.amount;
        withdrawalCount++;
      }
      commissions += o.commission;
      networkFees += o.networkFee;
      if (o.providerType == ProviderType.instaPay) instaPayCount++;
    }
    return ShiftStats(
      totalOperations: ops.length,
      depositCount: depositCount,
      withdrawalCount: withdrawalCount,
      totalDeposits: deposits,
      totalWithdrawals: withdrawals,
      totalCommissions: commissions,
      totalNetworkFees: networkFees,
      netProfit: commissions - networkFees,
      instaPayCount: instaPayCount,
    );
  }

  ShiftStats copyWithLiabilities({
    required double customerDebtsCreated,
    required int customerDebtsCreatedCount,
    required double payablesCreated,
    required int payablesCreatedCount,
    required double customerDebtCollected,
    required int customerDebtCollectedCount,
    required double payablesSettled,
    required int payablesSettledCount,
  }) {
    return ShiftStats(
      totalOperations: totalOperations,
      depositCount: depositCount,
      withdrawalCount: withdrawalCount,
      totalDeposits: totalDeposits,
      totalWithdrawals: totalWithdrawals,
      totalCommissions: totalCommissions,
      totalNetworkFees: totalNetworkFees,
      netProfit: netProfit,
      instaPayCount: instaPayCount,
      customerDebtsCreated: customerDebtsCreated,
      customerDebtsCreatedCount: customerDebtsCreatedCount,
      payablesCreated: payablesCreated,
      payablesCreatedCount: payablesCreatedCount,
      customerDebtCollected: customerDebtCollected,
      customerDebtCollectedCount: customerDebtCollectedCount,
      payablesSettled: payablesSettled,
      payablesSettledCount: payablesSettledCount,
    );
  }
}
