import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

abstract class ShiftDetailState {}

class ShiftDetailInitial extends ShiftDetailState {}

class ShiftDetailLoading extends ShiftDetailState {}

class ShiftDetailLoaded extends ShiftDetailState {
  final ShiftEntity shift;
  final ShiftStats stats;
  final List<OperationEntity> operations;

  /// Debts created during this shift's timeframe
  final List<DebtEntity> shiftDebts;

  /// Debt payments made during this shift's timeframe
  final List<DebtPaymentEntity> shiftPayments;

  /// Map of debtorId → debtor name for display in timeline
  final Map<int, String> debtorNames;

  /// Map of debtId → debt entity (all debts, for type lookup on payments)
  final Map<int, DebtEntity> allDebtsById;

  /// Current total wallet balances (global read-only snapshot)
  final double totalWalletBalance;

  /// Current total InstaPay balances (global read-only snapshot)
  final double totalInstaPayBalance;

  /// Current total outstanding customer debt (global read-only snapshot)
  final double totalOutstandingCustomerDebt;

  /// Current total outstanding payables (global read-only snapshot)
  final double totalOutstandingPayable;

  ShiftDetailLoaded({
    required this.shift,
    required this.stats,
    required this.operations,
    this.shiftDebts = const [],
    this.shiftPayments = const [],
    this.debtorNames = const {},
    this.allDebtsById = const {},
    this.totalWalletBalance = 0,
    this.totalInstaPayBalance = 0,
    this.totalOutstandingCustomerDebt = 0,
    this.totalOutstandingPayable = 0,
  });
}

class ShiftDetailError extends ShiftDetailState {
  final String message;

  ShiftDetailError({required this.message});
}
