import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/repositories/debt_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/instapay_account_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_detail_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/shift_stats.dart';

class ShiftDetailCubit extends Cubit<ShiftDetailState> {
  final ShiftRepository repository;
  final WalletRepository walletRepository;
  final InstaPayAccountRepository instaPayRepository;
  final DebtRepository debtRepository;

  ShiftDetailCubit({
    required this.repository,
    required this.walletRepository,
    required this.instaPayRepository,
    required this.debtRepository,
  }) : super(ShiftDetailInitial());

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

      // Load ALL debts for type lookup (payments may settle older debts)
      final allDebts = await repository.getDebtsInTimeframe(
        DateTime.fromMillisecondsSinceEpoch(0),
        null,
      );
      final allDebtsById = {for (final d in allDebts) d.id: d};
      final debtTypeById = {for (final d in allDebts) d.id: d.debtType};

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

      // Load debtor names for timeline display
      final debtorIds = debts.map((d) => d.debtorId).toSet()
        ..addAll(payments.map((p) {
          final debt = allDebtsById[p.debtId];
          return debt?.debtorId;
        }).whereType<int>());

      final Map<int, String> debtorNames = {};
      for (final id in debtorIds) {
        final debtor = await debtRepository.getDebtorById(id);
        if (debtor != null) {
          debtorNames[id] = debtor.name;
        }
      }

      // Load global balance snapshots (read-only)
      final wallets = await walletRepository.getWallets();
      final activeWallets = wallets.where((w) => !w.isArchived).toList();
      final totalWalletBalance = activeWallets.fold(0.0, (sum, w) => sum + w.balance);

      final instaPayAccounts = await instaPayRepository.getAll();
      final totalInstaPayBalance = instaPayAccounts.fold(0.0, (sum, a) => sum + a.balance);

      // Outstanding debt totals (global read-only)
      final unpaidDebts = await debtRepository.getUnpaidDebts();
      final unpaidIds = unpaidDebts.map((d) => d.id).toList();
      final debtPayments = await debtRepository.getPaymentsForDebts(unpaidIds);
      final Map<int, double> paidByDebt = {};
      for (final p in debtPayments) {
        paidByDebt[p.debtId] = (paidByDebt[p.debtId] ?? 0.0) + p.amount;
      }
      double totalOutstandingCustomerDebt = 0;
      double totalOutstandingPayable = 0;
      for (final d in unpaidDebts) {
        final remaining = d.amount - (paidByDebt[d.id] ?? 0.0);
        if (d.debtType == DebtType.payable) {
          totalOutstandingPayable += remaining;
        } else {
          totalOutstandingCustomerDebt += remaining;
        }
      }

      emit(ShiftDetailLoaded(
        shift: shift,
        stats: stats,
        operations: ops,
        shiftDebts: debts,
        shiftPayments: payments,
        debtorNames: debtorNames,
        allDebtsById: allDebtsById,
        totalWalletBalance: totalWalletBalance,
        totalInstaPayBalance: totalInstaPayBalance,
        totalOutstandingCustomerDebt: totalOutstandingCustomerDebt,
        totalOutstandingPayable: totalOutstandingPayable,
      ));
    } catch (e) {
      debugPrint('loadShiftDetail error: $e');
      emit(ShiftDetailError(message: 'فشل تحميل تفاصيل الوردية'));
    }
  }
}

