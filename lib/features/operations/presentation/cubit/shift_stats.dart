import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

class ShiftStats {
  final int totalOperations;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalCommissions;
  final double totalNetworkFees;
  final double netProfit;
  final int instaPayCount;

  const ShiftStats({
    required this.totalOperations,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalCommissions,
    required this.totalNetworkFees,
    required this.netProfit,
    required this.instaPayCount,
  });

  factory ShiftStats.fromOperations(List<OperationEntity> ops) {
    double deposits = 0;
    double withdrawals = 0;
    double commissions = 0;
    double networkFees = 0;
    int instaPayCount = 0;
    for (final o in ops) {
      if (o.operationType == OperationType.deposit) {
        deposits += o.amount;
      } else {
        withdrawals += o.amount;
      }
      commissions += o.commission;
      networkFees += o.networkFee;
      if (o.providerType == ProviderType.instaPay) instaPayCount++;
    }
    return ShiftStats(
      totalOperations: ops.length,
      totalDeposits: deposits,
      totalWithdrawals: withdrawals,
      totalCommissions: commissions,
      totalNetworkFees: networkFees,
      netProfit: commissions - networkFees,
      instaPayCount: instaPayCount,
    );
  }
}
