import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_adjustment_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_adjustment_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_adjustment_state.dart';

class WalletAdjustmentCubit extends Cubit<WalletAdjustmentState> {
  final WalletAdjustmentRepository repository;

  WalletAdjustmentCubit(this.repository) : super(WalletAdjustmentInitial());

  Future<void> loadAllAdjustments() async {
    emit(WalletAdjustmentLoading());
    try {
      final adjustments = await repository.getAllAdjustments();
      emit(WalletAdjustmentLoaded(adjustments: adjustments));
    } catch (e) {
      emit(WalletAdjustmentError(message: 'فشل تحميل التعديلات'));
    }
  }

  Future<void> refreshAllAdjustments() async {
    try {
      final adjustments = await repository.getAllAdjustments();
      emit(WalletAdjustmentLoaded(adjustments: adjustments));
    } catch (e) {
      emit(WalletAdjustmentError(message: 'فشل تحديث التعديلات'));
    }
  }

  Future<void> addAdjustment(WalletAdjustmentEntity adjustment) async {
    try {
      await repository.addWalletAdjustment(adjustment);
      await refreshAllAdjustments();
    } catch (e) {
      emit(WalletAdjustmentError(message: 'فشل إضافة التعديل'));
    }
  }
}
