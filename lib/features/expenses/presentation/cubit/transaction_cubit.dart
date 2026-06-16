import 'package:bloc/bloc.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:smart_expense/features/expenses/domain/entities/transaction_entity.dart';
import 'package:smart_expense/features/expenses/domain/repositories/transaction_repository.dart';
import 'package:smart_expense/features/expenses/presentation/cubit/transaction_state.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_cubit.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  List<TransactionEntity> _allTransactions = [];
  String _searchQuery = '';
  TransactionCategory? _selectedCategory;

  TransactionCubit(this.repository) : super(TransactionInitial());

  Future<void> addTransaction(TransactionEntity transaction) async {
    emit(TransactionLoading());
    try {
      await repository.addTransaction(transaction);
      await _refreshTransactions();
      await sl<AnalyticsCubit>().silentReload();
      await sl<ProfileCubit>().silentReload();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> getTransactions() async {
    emit(TransactionLoading());
    try {
      _allTransactions = await repository.getTransactions();
      emit(_buildLoadedState());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(int id) async {
    emit(TransactionLoading());
    try {
      await repository.deleteTransaction(id);
      await _refreshTransactions();
      await sl<AnalyticsCubit>().silentReload();
      await sl<ProfileCubit>().silentReload();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    emit(TransactionLoading());
    try {
      await repository.updateTransaction(transaction);
      await _refreshTransactions();
      await sl<AnalyticsCubit>().silentReload();
      await sl<ProfileCubit>().silentReload();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void search(String query) {
    _searchQuery = query;
    emit(_buildLoadedState());
  }

  void filterByCategory(TransactionCategory? category) {
    _selectedCategory = category;
    emit(_buildLoadedState());
  }

  List<TransactionEntity> _applyFilters() {
    var result = _allTransactions;

    // Apply category filter
    if (_selectedCategory != null) {
      result = result.where((t) => t.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        final note = t.note.toLowerCase();
        final categoryName = t.category.name.toLowerCase();
        return note.contains(query) || categoryName.contains(query);
      }).toList();
    }

    // Sort by date descending (newest first)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  TransactionLoaded _buildLoadedState() {
    return TransactionLoaded(
      allTransactions: _allTransactions,
      visibleTransactions: _applyFilters(),
      searchQuery: _searchQuery,
      selectedCategory: _selectedCategory,
    );
  }

  Future<void> _refreshTransactions() async {
    try {
      _allTransactions = await repository.getTransactions();
      emit(_buildLoadedState());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
