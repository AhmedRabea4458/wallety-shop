import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

abstract class ShiftHistoryState {}

class ShiftHistoryInitial extends ShiftHistoryState {}

class ShiftHistoryLoading extends ShiftHistoryState {}

class ShiftHistoryLoaded extends ShiftHistoryState {
  final List<ShiftEntity> shifts;
  final Map<int, ShiftStats> shiftStats;

  ShiftHistoryLoaded({required this.shifts, required this.shiftStats});
}

class ShiftHistoryError extends ShiftHistoryState {
  final String message;

  ShiftHistoryError({required this.message});
}
