import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      debugPrint('getWallets error: $e');
      emit(WalletError('فشل تحميل المحافظ'));
    }
  }

  Future<void> refreshWallets() async {
    try {
      final wallets = await repository.getWallets();
      emit(WalletLoaded(wallets: wallets));
    } catch (e) {
      debugPrint('refreshWallets error: $e');
      emit(WalletError('فشل تحديث المحافظ'));
    }
  }

  Future<WalletEntity?> getWalletById(int id) async {
    try {
      return await repository.getWalletById(id);
    } catch (e) {
      debugPrint('getWalletById error: $e');
      return null;
    }
  }

  Future<void> addWallet(WalletEntity wallet) async {
    try {
      await repository.addWallet(wallet);
      debugPrint('addWallet: inserted ${wallet.name}');
      await refreshWallets();
    } catch (e) {
      debugPrint('addWallet error: $e');
      emit(WalletError('فشل إضافة المحفظة'));
      rethrow;
    }
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    try {
      await repository.updateWallet(wallet);
      debugPrint('updateWallet: updated ${wallet.name}');
      await refreshWallets();
    } catch (e) {
      debugPrint('updateWallet error: $e');
      emit(WalletError('فشل تحديث المحفظة'));
      rethrow;
    }
  }

  Future<void> deleteWallet(int id) async {
    try {
      final hasOps = await repository.walletHasOperations(id);
      if (hasOps) {
        emit(WalletError('لا يمكن حذف محفظة تحتوي على عمليات'));
        throw Exception('wallet_has_operations');
      }
      await repository.deleteWallet(id);
      debugPrint('deleteWallet: deleted id=$id');
      await refreshWallets();
    } catch (e) {
      debugPrint('deleteWallet error: $e');
      if (!e.toString().contains('wallet_has_operations')) {
        emit(WalletError('فشل حذف المحفظة'));
      }
      rethrow;
    }
  }
}
