import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

abstract class OperationState {}

class OperationInitial extends OperationState {}

class OperationLoading extends OperationState {}

class OperationLoaded extends OperationState {
  final List<OperationEntity> allOperations;
  final List<OperationEntity> visibleOperations;
  final Map<int, DebtEntity> operationDebts;
  final String searchQuery;
  final int? selectedWalletId;
  final OperationType? selectedOperationType;
  final ProviderType? selectedProviderType;

  OperationLoaded({
    required this.allOperations,
    required this.visibleOperations,
    this.operationDebts = const {},
    this.searchQuery = '',
    this.selectedWalletId,
    this.selectedOperationType,
    this.selectedProviderType,
  });
}

class OperationError extends OperationState {
  final String message;

  OperationError(this.message);
}
