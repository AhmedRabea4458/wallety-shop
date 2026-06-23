import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/features/operations/domain/entities/debt_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/repositories/debt_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';

class OperationCubit extends Cubit<OperationState> {
  final OperationRepository repository;
  final DebtRepository debtRepository;

  List<OperationEntity> _allOperations = [];
  Map<int, DebtEntity> _operationDebts = {};
  String _searchQuery = '';
  int? _selectedWalletId;
  OperationType? _selectedOperationType;
  ProviderType? _selectedProviderType;

  OperationCubit(this.repository, {required this.debtRepository}) : super(OperationInitial());

  Future<void> getOperations() async {
    emit(OperationLoading());
    try {
      final results = await Future.wait([
        repository.getOperations(),
        debtRepository.getOperationDebts(),
      ]);
      _allOperations = results[0] as List<OperationEntity>;
      _operationDebts = results[1] as Map<int, DebtEntity>;
      emit(_buildLoadedState());
    } catch (e) {
      debugPrint('getOperations error: $e');
      emit(OperationError('فشل تحميل العمليات'));
    }
  }

  Future<int> addOperation(OperationEntity operation, {bool isDebt = false}) async {
    final hadData = state is OperationLoaded;
    if (!hadData) emit(OperationLoading());
    try {
      final id = await repository.addOperation(operation, isDebt: isDebt);
      debugPrint('addOperation: inserted op type=${operation.operationType.name}');
      await _refreshOperations();
      return id;
    } on InsufficientBalanceException {
      if (!hadData) emit(OperationError('فشل إضافة العملية'));
      rethrow;
    } on InsufficientCashDrawerBalanceException {
      if (!hadData) emit(OperationError('فشل إضافة العملية'));
      rethrow;
    } on OperationLinkedToDebtException {
      if (!hadData) emit(OperationError('فشل إضافة العملية'));
      rethrow;
    } catch (e) {
      debugPrint('addOperation error: $e');
      if (!hadData) emit(OperationError('فشل إضافة العملية'));
      rethrow;
    }
  }

  Future<int?> getActiveShiftId() async {
    try {
      final ops = await repository.getOperations();
      // Return the shiftId of the most recently created operation as the active shift
      if (ops.isNotEmpty) {
        return ops.first.shiftId;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOperation(OperationEntity operation) async {
    final hadData = state is OperationLoaded;
    if (!hadData) emit(OperationLoading());
    try {
      await repository.updateOperation(operation);
      debugPrint('updateOperation: updated op id=${operation.id}');
      await _refreshOperations();
    } on InsufficientBalanceException {
      if (!hadData) emit(OperationError('فشل تحديث العملية'));
      rethrow;
    } on InsufficientCashDrawerBalanceException {
      if (!hadData) emit(OperationError('فشل تحديث العملية'));
      rethrow;
    } on OperationLinkedToDebtException {
      if (!hadData) emit(OperationError('فشل تحديث العملية'));
      rethrow;
    } catch (e) {
      debugPrint('updateOperation error: $e');
      if (!hadData) emit(OperationError('فشل تحديث العملية'));
      rethrow;
    }
  }

  Future<void> deleteOperation(int id) async {
    final hadData = state is OperationLoaded;
    if (!hadData) emit(OperationLoading());
    try {
      await repository.deleteOperation(id);
      debugPrint('deleteOperation: deleted op id=$id');
      await _refreshOperations();
    } on InsufficientBalanceException {
      if (!hadData) emit(OperationError('فشل حذف العملية'));
      rethrow;
    } on InsufficientCashDrawerBalanceException {
      if (!hadData) emit(OperationError('فشل حذف العملية'));
      rethrow;
    } on OperationLinkedToDebtException {
      if (!hadData) emit(OperationError('فشل حذف العملية'));
      rethrow;
    } catch (e) {
      debugPrint('deleteOperation error: $e');
      if (!hadData) emit(OperationError('فشل حذف العملية'));
      rethrow;
    }
  }

  void search(String query) {
    _searchQuery = query;
    emit(_buildLoadedState());
  }

  void filterByWallet(int? walletId) {
    _selectedWalletId = walletId;
    emit(_buildLoadedState());
  }

  void filterByOperationType(OperationType? type) {
    _selectedOperationType = type;
    emit(_buildLoadedState());
  }

  void filterByProvider(ProviderType? provider) {
    _selectedProviderType = provider;
    emit(_buildLoadedState());
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedWalletId = null;
    _selectedOperationType = null;
    _selectedProviderType = null;
    emit(_buildLoadedState());
  }

  List<OperationEntity> _applyFilters() {
    var result = _allOperations;

    if (_selectedWalletId != null) {
      result = result.where((o) => o.walletId == _selectedWalletId).toList();
    }

    if (_selectedOperationType != null) {
      result = result.where((o) => o.operationType == _selectedOperationType).toList();
    }

    if (_selectedProviderType != null) {
      result = result.where((o) => o.providerType == _selectedProviderType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((o) {
        final notes = o.notes?.toLowerCase() ?? '';
        final phone = o.phoneNumber?.toLowerCase() ?? '';
        return notes.contains(query) || phone.contains(query);
      }).toList();
    }

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  OperationLoaded _buildLoadedState() {
    return OperationLoaded(
      allOperations: _allOperations,
      visibleOperations: _applyFilters(),
      operationDebts: _operationDebts,
      searchQuery: _searchQuery,
      selectedWalletId: _selectedWalletId,
      selectedOperationType: _selectedOperationType,
      selectedProviderType: _selectedProviderType,
    );
  }

  DebtEntity? getDebtForOperation(int operationId) {
    return _operationDebts[operationId];
  }

  Future<void> _refreshOperations() async {
    try {
      final results = await Future.wait([
        repository.getOperations(),
        debtRepository.getOperationDebts(),
      ]);
      _allOperations = results[0] as List<OperationEntity>;
      _operationDebts = results[1] as Map<int, DebtEntity>;
      emit(_buildLoadedState());
    } catch (e) {
      debugPrint('_refreshOperations error: $e');
    }
  }
}
