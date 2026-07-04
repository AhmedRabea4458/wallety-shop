import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_payment_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_filter.dart';

abstract class DebtState {}

class DebtInitial extends DebtState {}

class DebtLoading extends DebtState {}

class DebtorsLoaded extends DebtState {
  final List<DebtorEntity> debtors;
  final Map<int, double> debtorBalances;
  final DebtorFilter? selectedFilter;

  DebtorsLoaded({required this.debtors, required this.debtorBalances, this.selectedFilter});
}

class DebtorDetailLoaded extends DebtState {
  final DebtorEntity debtor;
  final List<DebtEntity> debts;
  final List<DebtPaymentEntity> payments;

  DebtorDetailLoaded({required this.debtor, required this.debts, this.payments = const []});
}

class OutstandingDebtLoaded extends DebtState {
  final double totalOutstanding;
  final double totalCustomerDebt;
  final double totalSettlementDebt;
  final List<DebtEntity> unpaidDebts;

  OutstandingDebtLoaded({
    required this.totalOutstanding,
    required this.totalCustomerDebt,
    required this.totalSettlementDebt,
    required this.unpaidDebts,
  });
}

class DebtError extends DebtState {
  final String message;

  DebtError({required this.message});
}
