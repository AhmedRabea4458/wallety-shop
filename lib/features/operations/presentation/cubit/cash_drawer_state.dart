import 'package:smart_expense/features/operations/domain/entities/cash_drawer_entity.dart';

abstract class CashDrawerState {}

class CashDrawerInitial extends CashDrawerState {}

class CashDrawerLoading extends CashDrawerState {}

class CashDrawerLoaded extends CashDrawerState {
  final CashDrawerEntity cashDrawer;

  CashDrawerLoaded({required this.cashDrawer});
}

class CashDrawerError extends CashDrawerState {
  final String message;

  CashDrawerError({required this.message});
}
