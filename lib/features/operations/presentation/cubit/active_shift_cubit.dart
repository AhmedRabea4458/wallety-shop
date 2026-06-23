import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/features/operations/domain/entities/shift_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/active_shift_state.dart';

class ActiveShiftCubit extends Cubit<ActiveShiftState> {
  final ShiftRepository repository;

  ActiveShiftCubit(this.repository) : super(ActiveShiftInitial());

  Future<void> loadActiveShift() async {
    emit(ActiveShiftLoading());
    try {
      final active = await repository.getActiveShift();
      if (active != null) {
        emit(ActiveShiftLoaded(shift: active));
      } else {
        emit(NoActiveShift());
      }
    } on MultipleActiveShiftsException catch (e) {
      debugPrint('Multiple active shifts detected: $e. Running repair.');
      try {
        await repository.repairActiveShifts();
        final active = await repository.getActiveShift();
        if (active != null) {
          emit(ActiveShiftLoaded(shift: active));
        } else {
          emit(NoActiveShift());
        }
      } catch (repairError) {
        debugPrint('Repair failed: $repairError');
        emit(ActiveShiftError(message: 'يوجد أكثر من وردية نشطة ولم نتمكن من إصلاحها'));
      }
    } catch (e) {
      debugPrint('loadActiveShift error: $e');
      emit(ActiveShiftError(message: 'فشل تحميل الوردية'));
    }
  }

  Future<void> openShift(double openingCashDrawer) async {
    emit(ActiveShiftLoading());
    try {
      final shift = ShiftEntity(
        id: 0,
        startTime: DateTime.now(),
        openingCashDrawer: openingCashDrawer,
        createdAt: DateTime.now(),
      );
      await repository.openShift(shift);
      await loadActiveShift();
    } on ActiveShiftExistsException catch (e) {
      debugPrint('openShift error: $e');
      emit(ActiveShiftError(message: ErrorMapper.map(e)));
    } catch (e) {
      debugPrint('openShift error: $e');
      emit(ActiveShiftError(message: 'فشل فتح الوردية'));
    }
  }

  Future<void> closeShift(int shiftId, double closingBalance) async {
    emit(ActiveShiftLoading());
    try {
      await repository.closeShift(shiftId, closingBalance);
      emit(NoActiveShift());
    } catch (e) {
      debugPrint('closeShift error: $e');
      emit(ActiveShiftError(message: 'فشل إغلاق الوردية'));
    }
  }
}
