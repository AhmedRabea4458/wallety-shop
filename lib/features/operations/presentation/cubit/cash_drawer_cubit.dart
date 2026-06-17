import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/repositories/cash_drawer_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_state.dart';

class CashDrawerCubit extends Cubit<CashDrawerState> {
  final CashDrawerRepository repository;

  CashDrawerCubit(this.repository) : super(CashDrawerInitial());

  Future<void> getCashDrawer() async {
    emit(CashDrawerLoading());
    try {
      final cashDrawer = await repository.getCashDrawer();
      if (cashDrawer != null) {
        emit(CashDrawerLoaded(cashDrawer: cashDrawer));
      } else {
        emit( CashDrawerError(message: 'لم يتم العثور على الدرج النقدي'));
      }
    } catch (e) {
      emit(CashDrawerError(message: 'فشل تحميل الدرج النقدي'));
    }
  }

  Future<void> refreshCashDrawer() async {
    try {
      final cashDrawer = await repository.getCashDrawer();
      if (cashDrawer != null) {
        emit(CashDrawerLoaded(cashDrawer: cashDrawer));
      }
    } catch (e) {
      emit(CashDrawerError(message: 'فشل تحديث الدرج النقدي'));
    }
  }

  Future<void> updateInitialBalance(double newInitialBalance) async {
    try {
      await repository.updateInitialBalance(newInitialBalance);
      await refreshCashDrawer();
    } catch (e) {
      emit(CashDrawerError(message: 'فشل تحديث الرصيد الافتتاحي'));
    }
  }
}
