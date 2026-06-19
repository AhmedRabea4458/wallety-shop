import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';

abstract class ActiveShiftState {}

class ActiveShiftInitial extends ActiveShiftState {}

class ActiveShiftLoading extends ActiveShiftState {}

class NoActiveShift extends ActiveShiftState {}

class ActiveShiftLoaded extends ActiveShiftState {
  final ShiftEntity shift;

  ActiveShiftLoaded({required this.shift});
}

class ActiveShiftError extends ActiveShiftState {
  final String message;

  ActiveShiftError({required this.message});
}
