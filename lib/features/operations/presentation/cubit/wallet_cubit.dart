import 'package:bloc/bloc.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository;

  WalletCubit(this.repository) : super(WalletInitial());

  Future<void> getWallets() async {
    emit(WalletLoading());
    try {
      final wallets = await repository.getWallets();
      emit(WalletLoaded(wallets: wallets));
    } catch (e) {
      emit(WalletError('فشل تحميل المحافظ'));
    }
  }

  Future<void> refreshWallets() async {
    try {
      final wallets = await repository.getWallets();
      emit(WalletLoaded(wallets: wallets));
    } catch (e) {
      emit(WalletError('فشل تحديث المحافظ'));
    }
  }

  Future<WalletEntity?> getWalletById(int id) async {
    try {
      final wallet = await repository.getWalletById(id);
      return wallet;
    } catch (e) {
      return null;
    }
  }

  Future<void> addWallet(WalletEntity wallet) async {
    try {
      await repository.addWallet(wallet);
      await refreshWallets();
    } catch (e) {
      emit(WalletError('فشل إضافة المحفظة'));
    }
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    try {
      await repository.updateWallet(wallet);
      await refreshWallets();
    } catch (e) {
      emit(WalletError('فشل تحديث المحفظة'));
    }
  }

  Future<void> deleteWallet(int id) async {
    try {
      final hasOps = await repository.walletHasOperations(id);
      if (hasOps) {
        emit(WalletError('لا يمكن حذف محفظة تحتوي على عمليات'));
        return;
      }
      await repository.deleteWallet(id);
      await refreshWallets();
    } catch (e) {
      emit(WalletError('فشل حذف المحفظة'));
    }
  }
}
