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

  ShiftDetailLoaded({
    required this.shift,
    required this.stats,
    required this.operations,
  });
}

class ShiftDetailError extends ShiftDetailState {
  final String message;

  ShiftDetailError({required this.message});
}
