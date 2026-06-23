import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/entities/instapay_account_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/instapay_account_repository.dart';

abstract class InstaPayAccountState {}

class InstaPayAccountInitial extends InstaPayAccountState {}

class InstaPayAccountLoading extends InstaPayAccountState {}

class InstaPayAccountLoaded extends InstaPayAccountState {
  final List<InstaPayAccountEntity> accounts;
  InstaPayAccountLoaded({required this.accounts});
}

class InstaPayAccountError extends InstaPayAccountState {
  final String message;
  InstaPayAccountError(this.message);
}

class InstaPayAccountCubit extends Cubit<InstaPayAccountState> {
  final InstaPayAccountRepository repository;

  InstaPayAccountCubit(this.repository) : super(InstaPayAccountInitial());

  Future<void> loadAccounts() async {
    emit(InstaPayAccountLoading());
    try {
      final accounts = await repository.getAll();
      emit(InstaPayAccountLoaded(accounts: accounts));
    } catch (e) {
      emit(InstaPayAccountError('فشل تحميل حسابات InstaPay'));
    }
  }

  Future<void> addAccount(String name) async {
    await repository.insert(name);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await repository.delete(id);
    await loadAccounts();
  }

  Future<void> updateAccount(InstaPayAccountEntity account) async {
    await repository.update(account);
    await loadAccounts();
  }
}
