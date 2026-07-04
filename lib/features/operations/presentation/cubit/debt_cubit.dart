import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_type.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/debtor_filter.dart';
import 'package:smart_expense/features/operations/domain/repositories/debt_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_state.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';

class DebtCubit extends Cubit<DebtState> {
  final DebtRepository repository;
  final CashDrawerCubit cashDrawerCubit;
DebtorFilter? _selectedFilter = DebtorFilter.outstanding;
  double totalOutstanding = 0;
  double totalOutstandingCustomerDebt = 0;
  double totalOutstandingSettlementDebt = 0;
  List<DebtEntity> unpaidDebts = [];
  List<DebtorEntity> _allDebtors = [];
Map<int, double> _debtorBalances = {};

  DebtCubit(this.repository, {required this.cashDrawerCubit}) : super(DebtInitial());

  Future<void> loadDebtors({bool silent = false}) async {
    if (!silent) {
      emit(DebtLoading());
    }
    try {
      final debtors = await repository.getAllDebtors();
      final unpaidDebts = await repository.getUnpaidDebts();
      final Map<int, double> debtorBalances = {};

      final unpaidDebtIds = unpaidDebts.map((d) => d.id).toList();
      final payments = await repository.getPaymentsForDebts(unpaidDebtIds);
      final Map<int, double> paymentsByDebt = {};
      for (final p in payments) {
        paymentsByDebt[p.debtId] = (paymentsByDebt[p.debtId] ?? 0.0) + p.amount;
      }

      for (final debtor in debtors) {
        debtorBalances[debtor.id] = 0.0;
      }
      for (final debt in unpaidDebts) {
        final paid = paymentsByDebt[debt.id] ?? 0.0;
        final remaining = debt.amount - paid;
        debtorBalances[debt.debtorId] = (debtorBalances[debt.debtorId] ?? 0.0) + remaining;
      }
      _allDebtors = debtors;
      _debtorBalances = debtorBalances;
      emit(_buildLoadedState());
    } catch (e) {
      debugPrint('loadDebtors error: $e');
      emit(DebtError(message: 'فشل تحميل المدينين'));
    }
  }

  DebtorsLoaded _buildLoadedState() {
    List<DebtorEntity> filtered = _allDebtors;

    switch (_selectedFilter) {
      case DebtorFilter.outstanding:
        filtered = _allDebtors.where(
          (d) => (_debtorBalances[d.id] ?? 0) > 0,
        ).toList();
        break;

      case DebtorFilter.paid:
        filtered = _allDebtors.where(
          (d) => (_debtorBalances[d.id] ?? 0) == 0,
        ).toList();
        break;

      case DebtorFilter.all:
      case null:
        filtered = _allDebtors;
        break;
    }

    return DebtorsLoaded(
      debtors: filtered,
      debtorBalances: _debtorBalances,
      selectedFilter: _selectedFilter,
    );
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
      final debtIds = debts.map((d) => d.id).toList();
      final payments = await repository.getPaymentsForDebts(debtIds);
      emit(DebtorDetailLoaded(debtor: debtor, debts: debts, payments: payments));
    } catch (e) {
      debugPrint('loadDebtorDetail error: $e');
      emit(DebtError(message: 'فشل تحميل تفاصيل المدين'));
    }
  }

  Future<void> loadOutstandingDebt() async {
    try {
      final unpaid = await repository.getUnpaidDebts();
      final unpaidIds = unpaid.map((d) => d.id).toList();
      final payments = await repository.getPaymentsForDebts(unpaidIds);
      final Map<int, double> paymentsByDebt = {};
      for (final p in payments) {
        paymentsByDebt[p.debtId] = (paymentsByDebt[p.debtId] ?? 0.0) + p.amount;
      }

      double total = 0;
      double customerTotal = 0;
      double settlementTotal = 0;

      for (final d in unpaid) {
        final paid = paymentsByDebt[d.id] ?? 0.0;
        final remaining = d.amount - paid;
        total += remaining;
        if (d.debtType == DebtType.customerDebt) {
          customerTotal += remaining;
        } else if (d.debtType == DebtType.settlementDebt) {
          settlementTotal += remaining;
        }
      }

      unpaidDebts = unpaid;
      totalOutstanding = total;
      totalOutstandingCustomerDebt = customerTotal;
      totalOutstandingSettlementDebt = settlementTotal;
      emit(OutstandingDebtLoaded(
        totalOutstanding: total,
        totalCustomerDebt: customerTotal,
        totalSettlementDebt: settlementTotal,
        unpaidDebts: unpaid,
      ));
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
    String? notes,
    DebtType debtType = DebtType.customerDebt,
  }) async {
    if (debtType == DebtType.customerDebt && operationType != 'deposit') {
      debugPrint('createDebtFromOperation: only deposits can create customer debt, got $operationType');
      return;
    }
    if (debtType == DebtType.settlementDebt && operationType != 'withdrawal') {
      debugPrint('createDebtFromOperation: only withdrawals can create settlement debt, got $operationType');
      return;
    }
    try {
      DebtorEntity debtor;
      DebtorEntity? existing;
      if (customerPhone != null && customerPhone.trim().isNotEmpty) {
        existing = await repository.getDebtorByPhone(customerPhone);
      }
      existing ??= await repository.getDebtorByName(customerName);

      if (existing != null) {
        debtor = existing;
      } else {
        debtor = await repository.insertDebtor(
          customerName,
          phone: (customerPhone != null && customerPhone.trim().isNotEmpty) ? customerPhone.trim() : null,
        );
      }
      await repository.insertDebt(DebtEntity(
        id: 0,
        debtorId: debtor.id,
        operationId: operationId,
        operationType: operationType,
        providerType: providerType,
        amount: amount,
        isPaid: false,
        isCashLoan: false,
        debtType: debtType,
        notes: notes,
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

  Future<void> payDebt({
    required int debtId,
    required double amount,
    String? notes,
    String paymentMethod = 'cash',
    required int debtorId,
  }) async {
    try {
      await repository.payDebt(
        debtId: debtId,
        amount: amount,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      cashDrawerCubit.refreshCashDrawer();
      await loadOutstandingDebt();
      await loadDebtorDetail(debtorId);
      sl<OperationCubit>().getOperations();
    } catch (e) {
      debugPrint('payDebt error: $e');
      rethrow;
    }
  }

  Future<void> createManualDebt({
    required String customerName,
    String? customerPhone,
    required double amount,
    String? notes,
    bool isCashLoan = false,
  }) async {
    try {
      DebtorEntity debtor;
      DebtorEntity? existing;
      if (customerPhone != null && customerPhone.trim().isNotEmpty) {
        existing = await repository.getDebtorByPhone(customerPhone);
      }
      existing ??= await repository.getDebtorByName(customerName);

      if (existing != null) {
        debtor = existing;
      } else {
        debtor = await repository.insertDebtor(
          customerName,
          phone: (customerPhone != null && customerPhone.trim().isNotEmpty) ? customerPhone.trim() : null,
          notes: null,
        );
      }
      final debt = DebtEntity(
        id: 0,
        debtorId: debtor.id,
        operationId: null,
        operationType: 'deposit',
        providerType: null,
        amount: amount,
        isPaid: false,
        isCashLoan: isCashLoan,
        notes: notes,
        createdAt: DateTime.now(),
      );
      if (isCashLoan) {
        await repository.insertCashLoanDebt(debt);
        cashDrawerCubit.refreshCashDrawer();
      } else {
        await repository.insertDebt(debt);
      }
      await loadDebtors();
      await loadOutstandingDebt();
    } catch (e) {
      debugPrint('createManualDebt error: $e');
      emit(DebtError(message: 'فشل إضافة الدين اليدوي'));
      rethrow;
    }
  }

  Future<void> editDebt({
    required DebtEntity debt,
    required DebtorEntity debtor,
    required String newName,
    required String newPhone,
    required String newNotes,
    required double newAmount,
  }) async {
    try {
      final isManual = debt.operationId == null;

      await repository.updateDebtor(DebtorEntity(
        id: debtor.id,
        name: isManual ? newName : debtor.name,
        phone: isManual ? (newPhone.isEmpty ? null : newPhone) : debtor.phone,
        notes: debtor.notes,
        createdAt: debtor.createdAt,
      ));

      if (isManual) {
        if (debt.isCashLoan && !debt.isPaid && newAmount != debt.amount) {
          await repository.updateCashLoanDebtAmount(debt.id, newAmount);
          cashDrawerCubit.refreshCashDrawer();
        }
        await repository.updateDebt(DebtEntity(
          id: debt.id,
          debtorId: debt.debtorId,
          operationId: debt.operationId,
          operationType: debt.operationType,
          providerType: debt.providerType,
          amount: newAmount,
          isPaid: debt.isPaid,
          isCashLoan: debt.isCashLoan,
          notes: newNotes.isEmpty ? null : newNotes,
          paidAt: debt.paidAt,
          createdAt: debt.createdAt,
        ));
      } else {
        await repository.updateDebt(DebtEntity(
          id: debt.id,
          debtorId: debt.debtorId,
          operationId: debt.operationId,
          operationType: debt.operationType,
          providerType: debt.providerType,
          amount: debt.amount,
          isPaid: debt.isPaid,
          isCashLoan: debt.isCashLoan,
          notes: newNotes.isEmpty ? null : newNotes,
          paidAt: debt.paidAt,
          createdAt: debt.createdAt,
        ));
      }

      await loadOutstandingDebt();
      if (debt.debtorId == debtor.id) {
        await loadDebtorDetail(debtor.id);
      } else {
        await loadDebtors();
      }
      sl<OperationCubit>().getOperations();
    } catch (e) {
      debugPrint('editDebt error: $e');
      emit(DebtError(message: 'فشل تحديث الدين'));
    }
  }

  Future<void> mergeDebtors({required int sourceDebtorId, required int targetDebtorId}) async {
    try {
      await repository.mergeDebtors(sourceDebtorId: sourceDebtorId, targetDebtorId: targetDebtorId);
      await loadDebtors();
      await loadOutstandingDebt();
    } catch (e) {
      debugPrint('mergeDebtors error: $e');
      rethrow;
    }
  }

  void filterByDebtorType(DebtorFilter? type) {
    _selectedFilter = type;
    emit(_buildLoadedState());
  }
}
