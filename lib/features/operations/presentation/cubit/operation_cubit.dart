import 'package:bloc/bloc.dart';
import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_state.dart';

class OperationCubit extends Cubit<OperationState> {
  final OperationRepository repository;

  List<OperationEntity> _allOperations = [];
  String _searchQuery = '';
  int? _selectedWalletId;
  OperationType? _selectedOperationType;
  ProviderType? _selectedProviderType;

  OperationCubit(this.repository) : super(OperationInitial());

  Future<void> getOperations() async {
    emit(OperationLoading());
    try {
      _allOperations = await repository.getOperations();
      emit(_buildLoadedState());
    } catch (e) {
      emit(OperationError('فشل تحميل العمليات'));
    }
  }

  Future<void> addOperation(OperationEntity operation) async {
    emit(OperationLoading());
    try {
      await repository.addOperation(operation);
      await _refreshOperations();
    } on InsufficientBalanceException catch (e) {
      emit(OperationError(e.toString()));
    } on InsufficientCashDrawerBalanceException catch (e) {
      emit(OperationError(e.toString()));
    } catch (e) {
      emit(OperationError('فشل إضافة العملية'));
    }
  }

  Future<void> updateOperation(OperationEntity operation) async {
    emit(OperationLoading());
    try {
      await repository.updateOperation(operation);
      await _refreshOperations();
    } on InsufficientBalanceException catch (e) {
      emit(OperationError(e.toString()));
    } on InsufficientCashDrawerBalanceException catch (e) {
      emit(OperationError(e.toString()));
    } catch (e) {
      emit(OperationError('فشل تحديث العملية'));
    }
  }

  Future<void> deleteOperation(int id) async {
    emit(OperationLoading());
    try {
      await repository.deleteOperation(id);
      await _refreshOperations();
    } on InsufficientBalanceException catch (e) {
      emit(OperationError(e.toString()));
    } on InsufficientCashDrawerBalanceException catch (e) {
      emit(OperationError(e.toString()));
    } catch (e) {
      emit(OperationError('فشل حذف العملية'));
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
      searchQuery: _searchQuery,
      selectedWalletId: _selectedWalletId,
      selectedOperationType: _selectedOperationType,
      selectedProviderType: _selectedProviderType,
    );
  }

  Future<void> _refreshOperations() async {
    try {
      _allOperations = await repository.getOperations();
      emit(_buildLoadedState());
    } catch (e) {
      emit(OperationError('فشل تحديث العمليات'));
    }
  }
}
