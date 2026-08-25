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
  String _searchQuery = '';
  DebtType activeLiabilityType = DebtType.customerDebt;
  double totalOutstanding = 0;
  double totalOutstandingCustomerDebt = 0;
  double totalOutstandingPayable = 0;
  double totalOutstandingSettlementDebt = 0;
  double todayCustomerDebtCollected = 0;
  double todayPayablesSettled = 0;
  List<DebtEntity> unpaidDebts = [];
  List<DebtorEntity> _allDebtors = [];
  Map<int, double> _customerBalances = {};
  Map<int, double> _payableBalances = {};
  Set<int> _debtorsWithCustomerDebt = {};
  Set<int> _debtorsWithPayables = {};
  Set<int> _debtorsWithUnpaidCustomerDebt = {};
  Set<int> _debtorsWithUnpaidPayable = {};

  DebtCubit(this.repository, {required this.cashDrawerCubit}) : super(DebtInitial());

  void selectLiabilityType(DebtType type) {
    activeLiabilityType = type;
    emit(_buildLoadedState());
  }

  Future<void> loadDebtors({bool silent = false, DebtType? liabilityType}) async {
    if (liabilityType != null) {
      activeLiabilityType = liabilityType;
    }
    if (!silent) {
      emit(DebtLoading());
    }
    try {
      final debtors = await repository.getAllDebtors();
      final unpaidDebts = await repository.getUnpaidDebts();

      final unpaidDebtIds = unpaidDebts.map((d) => d.id).toList();
      final payments = await repository.getPaymentsForDebts(unpaidDebtIds);
      final Map<int, double> paymentsByDebt = {};
      for (final p in payments) {
        paymentsByDebt[p.debtId] = (paymentsByDebt[p.debtId] ?? 0.0) + p.amount;
      }

      final Map<int, double> customerBalances = {for (var d in debtors) d.id: 0.0};
      final Map<int, double> payableBalances = {for (var d in debtors) d.id: 0.0};
      final Set<int> debtorsWithCustomerDebt = {};
      final Set<int> debtorsWithPayables = {};
      final Set<int> debtorsWithUnpaidCustomerDebt = {};
      final Set<int> debtorsWithUnpaidPayable = {};

      for (final debtor in debtors) {
        final debts = await repository.getDebtsByDebtor(debtor.id);
        for (final debt in debts) {
          if (debt.debtType == DebtType.payable) {
            debtorsWithPayables.add(debtor.id);
          } else if (debt.debtType == DebtType.customerDebt || debt.debtType == DebtType.settlementDebt) {
            debtorsWithCustomerDebt.add(debtor.id);
          }
        }
      }

      for (final debt in unpaidDebts) {
        final paid = paymentsByDebt[debt.id] ?? 0.0;
        final remaining = debt.amount - paid;
        if (debt.debtType == DebtType.payable) {
          payableBalances[debt.debtorId] = (payableBalances[debt.debtorId] ?? 0.0) + remaining;
          debtorsWithUnpaidPayable.add(debt.debtorId);
        } else if (debt.debtType == DebtType.customerDebt || debt.debtType == DebtType.settlementDebt) {
          customerBalances[debt.debtorId] = (customerBalances[debt.debtorId] ?? 0.0) + remaining;
          debtorsWithUnpaidCustomerDebt.add(debt.debtorId);
        }
      }

      _allDebtors = debtors;
      _customerBalances = customerBalances;
      _payableBalances = payableBalances;
      _debtorsWithCustomerDebt = debtorsWithCustomerDebt;
      _debtorsWithPayables = debtorsWithPayables;
      _debtorsWithUnpaidCustomerDebt = debtorsWithUnpaidCustomerDebt;
      _debtorsWithUnpaidPayable = debtorsWithUnpaidPayable;
      emit(_buildLoadedState());
    } catch (e) {
      debugPrint('loadDebtors error: $e');
      emit(DebtError(message: 'فشل تحميل البيانات'));
    }
  }

  DebtorsLoaded _buildLoadedState() {
    final isPayable = activeLiabilityType == DebtType.payable;
    final activeBalances = isPayable ? _payableBalances : _customerBalances;
    final categoryDebtorIds = isPayable ? _debtorsWithPayables : _debtorsWithCustomerDebt;
    final unpaidDebtorIds = isPayable ? _debtorsWithUnpaidPayable : _debtorsWithUnpaidCustomerDebt;

    List<DebtorEntity> filtered = [];

    switch (_selectedFilter) {
      case DebtorFilter.outstanding:
        filtered = _allDebtors.where(
          (d) => categoryDebtorIds.contains(d.id) && (activeBalances[d.id] ?? 0) > 0,
        ).toList();
        break;

      case DebtorFilter.paid:
        filtered = _allDebtors.where(
          (d) => categoryDebtorIds.contains(d.id) && !unpaidDebtorIds.contains(d.id),
        ).toList();
        break;

      case DebtorFilter.all:
      case null:
        filtered = _allDebtors.where(
          (d) => categoryDebtorIds.contains(d.id),
        ).toList();
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((d) {
        final nameMatch = d.name.toLowerCase().contains(q);
        final phoneMatch = d.phone != null && d.phone!.toLowerCase().contains(q);
        return nameMatch || phoneMatch;
      }).toList();
    }

    return DebtorsLoaded(
      debtors: filtered,
      debtorBalances: activeBalances,
      selectedFilter: _selectedFilter,
      searchQuery: _searchQuery,
      activeLiabilityType: activeLiabilityType,
    );
  }

  void searchDebtors(String query) {
    _searchQuery = query;
    emit(_buildLoadedState());
  }

  Future<DebtorEntity?> getDebtorById(int id) async {
    try {
      return await repository.getDebtorById(id);
    } catch (e) {
      debugPrint('getDebtorById error: $e');
      return null;
    }
  }

  Future<void> loadDebtorDetail(
    int debtorId, {
    DebtType activeLiabilityType = DebtType.customerDebt,
  }) async {
    emit(DebtLoading());
    try {
      final debtor = await repository.getAllDebtors().then(
        (all) => all.firstWhere((d) => d.id == debtorId),
      );
      final allDebts = await repository.getDebtsByDebtor(debtorId);
      final debts = allDebts.where((d) {
        if (activeLiabilityType == DebtType.payable) {
          return d.debtType == DebtType.payable;
        } else {
          return d.debtType == DebtType.customerDebt || d.debtType == DebtType.settlementDebt;
        }
      }).toList();
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

      double customerTotal = 0;
      double payableTotal = 0;
      double settlementTotal = 0;

      for (final d in unpaid) {
        final paid = paymentsByDebt[d.id] ?? 0.0;
        final remaining = d.amount - paid;
        if (d.debtType == DebtType.customerDebt) {
          customerTotal += remaining;
        } else if (d.debtType == DebtType.payable) {
          payableTotal += remaining;
        } else if (d.debtType == DebtType.settlementDebt) {
          settlementTotal += remaining;
        }
      }

      final totalCustomerReceivables = customerTotal + settlementTotal;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      final todayPayments = await repository.getDebtPaymentsInTimeframe(todayStart, todayEnd);
      double todayCollected = 0.0;
      double todaySettled = 0.0;

      if (todayPayments.isNotEmpty) {
        final allDebts = await repository.getDebtsInTimeframe(
          DateTime.fromMillisecondsSinceEpoch(0),
          null,
        );
        final debtTypeById = {for (final d in allDebts) d.id: d.debtType};
        for (final p in todayPayments) {
          final type = debtTypeById[p.debtId];
          if (type == DebtType.payable) {
            todaySettled += p.amount;
          } else {
            // customerDebt and settlementDebt collected
            todayCollected += p.amount;
          }
        }
      }

      todayCustomerDebtCollected = todayCollected;
      todayPayablesSettled = todaySettled;

      emit(OutstandingDebtLoaded(
        totalOutstanding: totalCustomerReceivables,
        totalCustomerDebt: customerTotal,
        totalPayable: payableTotal,
        totalSettlementDebt: settlementTotal,
        unpaidDebts: unpaid,
        todayCustomerDebtCollected: todayCollected,
        todayPayablesSettled: todaySettled,
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

  Future<void> markDebtAsPaid(int debtId, {String paymentMethod = 'cash'}) async {
    try {
      await repository.markDebtAsPaid(debtId, paymentMethod: paymentMethod);
      cashDrawerCubit.refreshCashDrawer();
      await loadOutstandingDebt();
      sl<OperationCubit>().getOperations();
    } catch (e) {
      debugPrint('markDebtAsPaid error: $e');
      emit(DebtError(message: 'فشل تسوية الدين'));
    }
  }

  /// Cancels a debt that was created by mistake.
  /// Safe only when: no payments exist AND debt is not linked to an operation.
  /// For cash loans, the drawer balance is restored automatically in the DB layer.
  /// Throws [Exception] with an Arabic message if cancellation is blocked.
  Future<void> cancelDebt({
    required int debtId,
    required int debtorId,
    DebtType activeLiabilityType = DebtType.customerDebt,
  }) async {
    await repository.cancelDebt(debtId);
    // Refresh cash drawer in case it was a cash loan
    cashDrawerCubit.refreshCashDrawer();
    await loadOutstandingDebt();
    await loadDebtorDetail(debtorId, activeLiabilityType: activeLiabilityType);
    sl<OperationCubit>().getOperations();
  }

  Future<void> payDebt({
    required int debtId,
    required double amount,
    String? notes,
    String paymentMethod = 'cash',
    required int debtorId,
    DebtType activeLiabilityType = DebtType.customerDebt,
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
      await loadDebtorDetail(debtorId, activeLiabilityType: activeLiabilityType);
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
    DebtType debtType = DebtType.customerDebt,
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
        debtType: debtType,
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
        final activeType = debt.debtType == DebtType.payable ? DebtType.payable : DebtType.customerDebt;
        await loadDebtorDetail(debtor.id, activeLiabilityType: activeType);
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

  /// Pays multiple active debts for a debtor in a single atomic transaction.
  /// Debts are settled oldest-first. A partial payment is recorded for the
  /// last debt if the total amount runs out before the debt is fully cleared.
  Future<void> bulkPayDebts({
    required int debtorId,
    required double totalAmount,
    String? notes,
    String paymentMethod = 'cash',
    DebtType activeLiabilityType = DebtType.customerDebt,
  }) async {
    try {
      // Load all debts + their payments for this debtor filtered by active liability type
      final debts = await repository.getDebtsByDebtor(debtorId);
      final filteredDebts = debts.where((d) {
        if (activeLiabilityType == DebtType.payable) {
          return d.debtType == DebtType.payable;
        } else {
          return d.debtType == DebtType.customerDebt || d.debtType == DebtType.settlementDebt;
        }
      }).toList();

      final debtIds = filteredDebts.map((d) => d.id).toList();
      final payments = await repository.getPaymentsForDebts(debtIds);

      final paymentsByDebt = <int, double>{};
      for (final p in payments) {
        paymentsByDebt[p.debtId] = (paymentsByDebt[p.debtId] ?? 0.0) + p.amount;
      }

      // Active debts only, sorted oldest-first
      final activeDebts = filteredDebts
          .where((d) => !d.isPaid)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (activeDebts.isEmpty) {
        throw Exception('لا توجد ديون مستحقة');
      }

      final availableTotal = activeDebts.fold(0.0, (sum, d) {
        final paid = paymentsByDebt[d.id] ?? 0.0;
        return sum + (d.amount - paid);
      });

      if (totalAmount > availableTotal) {
        throw Exception(
          'المبلغ (${totalAmount.toStringAsFixed(0)} ج.م) أكبر من إجمالي الديون المستحقة (${availableTotal.toStringAsFixed(0)} ج.م)',
        );
      }

      await repository.bulkPayDebts(
        debtIds: activeDebts.map((d) => d.id).toList(),
        totalAmount: totalAmount,
        notes: notes,
        paymentMethod: paymentMethod,
      );

      cashDrawerCubit.refreshCashDrawer();
      await loadOutstandingDebt();
      await loadDebtorDetail(debtorId, activeLiabilityType: activeLiabilityType);
      sl<OperationCubit>().getOperations();
    } catch (e) {
      debugPrint('bulkPayDebts error: $e');
      rethrow;
    }
  }
}
