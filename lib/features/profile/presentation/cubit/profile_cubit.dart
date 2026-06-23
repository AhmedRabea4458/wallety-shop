import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_expense/core/errors/error_mapper.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';
import 'package:smart_expense/features/profile/domain/entities/profile_stats.dart';
import 'package:smart_expense/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final OperationRepository repository;

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> getProfileStats() async {
    emit(ProfileLoading());
    try {
      final operations = await repository.getOperations();
      final stats = _calculateStats(operations);
      emit(ProfileLoaded(
        stats: stats,
      ));
    } catch (e) {
      emit(ProfileError(ErrorMapper.map(e)));
    }
  }

  Future<void> silentReload() async {
    try {
      final operations = await repository.getOperations();
      final stats = _calculateStats(operations);
      emit(ProfileLoaded(
        stats: stats,
      ));
    } catch (e) {
      emit(ProfileError(ErrorMapper.map(e)));
    }
  }

  Future<void> exportToCsv() async {
    try {
      final operations = await repository.getOperations();

      final buffer = StringBuffer();
      buffer.writeln('id,walletId,operationType,providerType,amount,commission,networkFee,phoneNumber,notes,createdAt');

      for (final operation in operations) {
        final date = DateFormat('yyyy-MM-dd HH:mm').format(operation.createdAt);
        final type = operation.operationType.name;
        final provider = operation.providerType.name;
        final sanitizedNote = (operation.notes ?? '')
            .replaceAll(',', ' ')
            .replaceAll('"', '""');
        final sanitizedPhone = (operation.phoneNumber ?? '')
            .replaceAll(',', ' ')
            .replaceAll('"', '""');
        buffer.writeln(
          '${operation.id},'
          '${operation.walletId},'
          '$type,'
          '$provider,'
          '${operation.amount},'
          '${operation.commission},'
          '${operation.networkFee},'
          '"$sanitizedPhone",'
          '"$sanitizedNote",'
          '$date',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/wallety_operations.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Wallety - Operations Export',
      );
    } catch (e) {
      rethrow;
    }
  }

  ProfileStats _calculateStats(List<OperationEntity> operations) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final monthlyOperations = operations.where(
      (operation) =>
          operation.createdAt.isAfter(monthStart) ||
          operation.createdAt.isAtSameMomentAs(monthStart),
    );

    final monthlyDeposit = monthlyOperations
        .where((o) => o.operationType == OperationType.deposit)
        .fold<double>(0, (sum, o) => sum + o.amount);

    final monthlyWithdrawal = monthlyOperations
        .where((o) => o.operationType == OperationType.withdrawal)
        .fold<double>(0, (sum, o) => sum + o.amount);

    final monthlyCommission = monthlyOperations
        .fold<double>(0, (sum, o) => sum + o.commission);

    final monthlyNetworkFee = monthlyOperations
        .fold<double>(0, (sum, o) => sum + o.networkFee);

    final monthlyNetProfit = monthlyCommission - monthlyNetworkFee;

    final vodafoneOps = monthlyOperations
        .where((o) => o.providerType == ProviderType.vodafoneCash);
    final instaPayOps = monthlyOperations
        .where((o) => o.providerType == ProviderType.instaPay);

    return ProfileStats(
      totalTransactions: monthlyOperations.length,
      totalDeposits: monthlyDeposit,
      totalWithdrawals: monthlyWithdrawal,
      commission: monthlyCommission,
      networkFee: monthlyNetworkFee,
      netProfit: monthlyNetProfit,
      vodafoneCash: ProviderStats(
        operationCount: vodafoneOps.length,
        totalAmount: vodafoneOps.fold<double>(0, (sum, o) => sum + o.amount),
        totalCommission: vodafoneOps.fold<double>(0, (sum, o) => sum + o.commission),
        totalNetworkFee: vodafoneOps.fold<double>(0, (sum, o) => sum + o.networkFee),
      ),
      instaPay: ProviderStats(
        operationCount: instaPayOps.length,
        totalAmount: instaPayOps.fold<double>(0, (sum, o) => sum + o.amount),
        totalCommission: instaPayOps.fold<double>(0, (sum, o) => sum + o.commission),
        totalNetworkFee: instaPayOps.fold<double>(0, (sum, o) => sum + o.networkFee),
      ),
    );
  }
}
