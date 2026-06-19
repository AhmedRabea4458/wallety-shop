import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/debt_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';

class DebtCubit extends Cubit<DebtState> {
  final DebtRepository repository;
  final CashDrawerCubit cashDrawerCubit;

  double totalOutstanding = 0;
  List<DebtEntity> unpaidDebts = [];

  DebtCubit(this.repository, {required this.cashDrawerCubit}) : super(DebtInitial());

  Future<void> loadDebtors() async {
    emit(DebtLoading());
    try {
      final debtors = await repository.getAllDebtors();
      emit(DebtorsLoaded(debtors: debtors));
    } catch (e) {
      debugPrint('loadDebtors error: $e');
      emit(DebtError(message: 'فشل تحميل المدينين'));
    }
  }

  Future<DebtorEntity?> getDebtorById(int id) async {
    try {
      return await repository.getDebtorById(id);
    } catch (e) {
      debugPrint('getDebtorById error: $e');
      return null;
    }
  }

  Future<void> loadDebtorDetail(int debtorId) async {
    emit(DebtLoading());
    try {
      final debtor = await repository.getAllDebtors().then(
        (all) => all.firstWhere((d) => d.id == debtorId),
      );
      final debts = await repository.getDebtsByDebtor(debtorId);
      emit(DebtorDetailLoaded(debtor: debtor, debts: debts));
    } catch (e) {
      debugPrint('loadDebtorDetail error: $e');
      emit(DebtError(message: 'فشل تحميل تفاصيل المدين'));
    }
  }

  Future<void> loadOutstandingDebt() async {
    try {
      final unpaid = await repository.getUnpaidDebts();
      final total = unpaid.fold(0.0, (sum, d) => sum + d.amount);
      unpaidDebts = unpaid;
      totalOutstanding = total;
      emit(OutstandingDebtLoaded(totalOutstanding: total, unpaidDebts: unpaid));
    } catch (e) {
      debugPrint('loadOutstandingDebt error: $e');
    }
  }

  Future<void> createDebtFromOperation({
    required int operationId,
    required String customerName,
    String? customerPhone,
    required String operationType,
    required String providerType,
    required double amount,
  }) async {
    if (operationType != 'deposit') {
      debugPrint('createDebtFromOperation: only deposits can create debt, got $operationType');
      return;
    }
    try {
      DebtorEntity debtor;
      final existing = await repository.getDebtorByPhone(customerPhone ?? '');
      if (existing != null) {
        debtor = existing;
      } else {
        debtor = await repository.insertDebtor(customerName, phone: customerPhone);
      }
      await repository.insertDebt(DebtEntity(
        id: 0,
        debtorId: debtor.id,
        operationId: operationId,
        operationType: operationType,
        providerType: providerType,
        amount: amount,
        isPaid: false,
        createdAt: DateTime.now(),
      ));
      await loadOutstandingDebt();
    } catch (e) {
      debugPrint('createDebtFromOperation error: $e');
    }
  }

  Future<void> markDebtAsPaid(int debtId) async {
    try {
      await repository.markDebtAsPaid(debtId);
      cashDrawerCubit.refreshCashDrawer();
      await loadOutstandingDebt();
      sl<OperationCubit>().getOperations();
    } catch (e) {
      debugPrint('markDebtAsPaid error: $e');
      emit(DebtError(message: 'فشل تسوية الدين'));
    }
  }

  Future<void> createManualDebt({
    required String customerName,
    String? customerPhone,
    required double amount,
    String? notes,
  }) async {
    try {
      DebtorEntity debtor;
      final existing = await repository.getDebtorByPhone(customerPhone ?? '');
      if (existing != null) {
        debtor = existing;
      } else {
        debtor = await repository.insertDebtor(customerName, phone: customerPhone, notes: notes);
      }
      await repository.insertDebt(DebtEntity(
        id: 0,
        debtorId: debtor.id,
        operationId: null,
        operationType: 'deposit',
        providerType: null,
        amount: amount,
        isPaid: false,
        createdAt: DateTime.now(),
      ));
      await loadDebtors();
      await loadOutstandingDebt();
    } catch (e) {
      debugPrint('createManualDebt error: $e');
      emit(DebtError(message: 'فشل إضافة الدين اليدوي'));
    }
  }
}
