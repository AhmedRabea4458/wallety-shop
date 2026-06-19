import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';

abstract class DebtState {}

class DebtInitial extends DebtState {}

class DebtLoading extends DebtState {}

class DebtorsLoaded extends DebtState {
  final List<DebtorEntity> debtors;

  DebtorsLoaded({required this.debtors});
}

class DebtorDetailLoaded extends DebtState {
  final DebtorEntity debtor;
  final List<DebtEntity> debts;

  DebtorDetailLoaded({required this.debtor, required this.debts});
}

class OutstandingDebtLoaded extends DebtState {
  final double totalOutstanding;
  final List<DebtEntity> unpaidDebts;

  OutstandingDebtLoaded({required this.totalOutstanding, required this.unpaidDebts});
}

class DebtError extends DebtState {
  final String message;

  DebtError({required this.message});
}
