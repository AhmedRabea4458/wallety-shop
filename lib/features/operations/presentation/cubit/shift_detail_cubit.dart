import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

class ShiftDetailCubit extends Cubit<ShiftDetailState> {
  final ShiftRepository repository;

  ShiftDetailCubit(this.repository) : super(ShiftDetailInitial());

  Future<void> loadShiftDetail(int shiftId) async {
    emit(ShiftDetailLoading());
    try {
      final shift = await repository.getShiftById(shiftId);
      if (shift == null) {
        emit(ShiftDetailError(message: 'الوردية غير موجودة'));
        return;
      }
      final ops = await repository.getOperationsByShiftId(shiftId);
      var stats = ShiftStats.fromOperations(ops);

      // Load liability data for this shift's timeframe
      final shiftStart = shift.startTime;
      final shiftEnd = shift.endTime;

      final debts = await repository.getDebtsInTimeframe(shiftStart, shiftEnd);
      final payments = await repository.getDebtPaymentsInTimeframe(shiftStart, shiftEnd);

      // Categorise debts created during this shift
      double customerDebtsCreated = 0;
      int customerDebtsCreatedCount = 0;
      double payablesCreated = 0;
      int payablesCreatedCount = 0;

      for (final d in debts) {
        if (d.debtType == DebtType.payable) {
          payablesCreated += d.amount;
          payablesCreatedCount++;
        } else {
          customerDebtsCreated += d.amount;
          customerDebtsCreatedCount++;
        }
      }

      // To categorise payments we need the debt type of the linked debt
      // We map debtIds from debts we just loaded (within timeframe) – but
      // payments might also settle older debts. We reload all debts for lookup.
      final allShiftDebts = await repository.getDebtsInTimeframe(
        DateTime.fromMillisecondsSinceEpoch(0),
        null,
      );
      final debtTypeById = {for (final d in allShiftDebts) d.id: d.debtType};

      double customerDebtCollected = 0;
      int customerDebtCollectedCount = 0;
      double payablesSettled = 0;
      int payablesSettledCount = 0;

      for (final p in payments) {
        final debtType = debtTypeById[p.debtId];
        if (debtType == DebtType.payable) {
          payablesSettled += p.amount;
          payablesSettledCount++;
        } else {
          customerDebtCollected += p.amount;
          customerDebtCollectedCount++;
        }
      }

      stats = stats.copyWithLiabilities(
        customerDebtsCreated: customerDebtsCreated,
        customerDebtsCreatedCount: customerDebtsCreatedCount,
        payablesCreated: payablesCreated,
        payablesCreatedCount: payablesCreatedCount,
        customerDebtCollected: customerDebtCollected,
        customerDebtCollectedCount: customerDebtCollectedCount,
        payablesSettled: payablesSettled,
        payablesSettledCount: payablesSettledCount,
      );

      emit(ShiftDetailLoaded(shift: shift, stats: stats, operations: ops));
    } catch (e) {
      debugPrint('loadShiftDetail error: $e');
      emit(ShiftDetailError(message: 'فشل تحميل تفاصيل الوردية'));
    }
  }
}
