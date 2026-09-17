import 'package:flutter/foundation.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/errors/exceptions.dart';
import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/operations/domain/entities/wallet_entity.dart';
import 'package:smart_expense/features/operations/domain/repositories/instapay_account_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/operation_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/shift_repository.dart';
import 'package:smart_expense/features/operations/domain/repositories/wallet_repository.dart';
import 'package:smart_expense/features/operations/presentation/cubit/cash_drawer_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/debt_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/operation_cubit.dart';
import 'package:smart_expense/features/operations/presentation/cubit/wallet_cubit.dart';
import 'package:smart_expense/features/sms_import/data/sms_parser.dart';
import 'package:smart_expense/features/sms_import/data/sms_storage_service.dart';
import 'package:smart_expense/features/sms_import/domain/models/parsed_sms_result.dart';
import 'package:smart_expense/features/sms_import/domain/models/sms_record.dart';

class SmsImportProcessor {
  final SmsParser parser;
  final SmsStorageService storage;

  SmsImportProcessor({
    this.parser = const SmsParser(),
    SmsStorageService? storage,
  }) : storage = storage ?? SmsStorageService.instance;

  /// Process incoming SMS message end-to-end
  Future<SmsRecord?> processIncomingSms({
    required String sender,
    required String body,
    DateTime? receivedAt,
  }) async {
    final now = receivedAt ?? DateTime.now();
    final fingerprint = SmsStorageService.generateFingerprint(sender, body, now);

    try {
      // 1. Parse SMS
      final parseResult = parser.parse(body, receivedAt: now);

      // If ignored, do not store or store as ignored
      if (parseResult.status == SmsParsingStatus.ignored) {
        debugPrint('SmsImportProcessor: Message ignored (not a financial SMS).');
        return null;
      }

      final recordId = (parseResult.referenceNumber != null &&
              parseResult.referenceNumber!.isNotEmpty)
          ? parseResult.referenceNumber!
          : fingerprint;

      // 2. Prevent Duplicates
      final isDuplicate = await storage.isDuplicate(
        referenceNumber: parseResult.referenceNumber,
        fingerprint: fingerprint,
      );

      if (isDuplicate) {
        debugPrint('SmsImportProcessor: Duplicate SMS detected ($recordId). Skipping.');
        return null;
      }

      // If failed parsing
      if (!parseResult.isSuccessful) {
        final failedRecord = SmsRecord(
          id: recordId,
          sender: sender,
          rawBody: body,
          receivedAt: now,
          parsedAt: DateTime.now(),
          parsingStatus: SmsParsingStatus.failed,
          importStatus: SmsImportStatus.failed,
          failureReason: parseResult.errorReason ?? 'فشل في استخراج تفاصيل العملية',
          referenceNumber: parseResult.referenceNumber,
        );
        await storage.saveRecord(failedRecord);
        return failedRecord;
      }

      // 3. Resolve Active Shift
      final shiftRepo = sl<ShiftRepository>();
      final activeShift = await shiftRepo.getActiveShift();
      if (activeShift == null) {
        final pendingRecord = _createBaseRecord(
          id: recordId,
          sender: sender,
          body: body,
          now: now,
          parseResult: parseResult,
          importStatus: SmsImportStatus.pending,
          failureReason: 'في انتظار فتح وردية نشطة للاستيراد',
        );
        await storage.saveRecord(pendingRecord);
        return pendingRecord;
      }

      // 4. Resolve Wallet / InstaPay Account
      int? resolvedWalletId;
      int? resolvedInstaPayAccountId;
      String? missingAccountReason;

      if (parseResult.providerType == ProviderType.vodafoneCash) {
        final walletRepo = sl<WalletRepository>();
        final allWallets = await walletRepo.getWallets();
        final activeWallets = allWallets.where((w) => !w.isArchived).toList();

        WalletEntity? matched;
        if (parseResult.myWalletPhone != null &&
            parseResult.myWalletPhone!.isNotEmpty) {
          matched = activeWallets.cast<WalletEntity?>().firstWhere(
                (w) => w?.phoneNumber == parseResult.myWalletPhone,
                orElse: () => null,
              );
        }

        if (matched == null) {
          if (activeWallets.length == 1) {
            matched = activeWallets.first;
          } else {
            final vfWallets = activeWallets.where((w) =>
                w.name.toLowerCase().contains('vodafone') ||
                w.name.contains('فودافون')).toList();
            if (vfWallets.length == 1) {
              matched = vfWallets.first;
            }
          }
        }

        if (matched != null) {
          resolvedWalletId = matched.id;
        } else {
          missingAccountReason = 'يرجى تحديد المحفظة يدويًا للمراجعة والاستيراد';
        }
      } else if (parseResult.providerType == ProviderType.instaPay) {
        final instaPayRepo = sl<InstaPayAccountRepository>();
        final allAccounts = await instaPayRepo.getAll();
        if (allAccounts.length == 1) {
          resolvedInstaPayAccountId = allAccounts.first.id;
        } else if (allAccounts.isEmpty) {
          missingAccountReason = 'لا يوجد أي حساب InstaPay مسجل في التطبيق';
        } else {
          missingAccountReason = 'يرجى اختيار حساب InstaPay يدويًا للمراجعة والاستيراد';
        }

        // Wallet fallback for InstaPay
        final walletRepo = sl<WalletRepository>();
        final allWallets = await walletRepo.getWallets();
        final activeWallets = allWallets.where((w) => !w.isArchived).toList();
        resolvedWalletId = activeWallets.isNotEmpty ? activeWallets.first.id : 0;
      }

      if (missingAccountReason != null) {
        final pendingRecord = _createBaseRecord(
          id: recordId,
          sender: sender,
          body: body,
          now: now,
          parseResult: parseResult,
          importStatus: SmsImportStatus.pending,
          failureReason: missingAccountReason,
          selectedWalletId: resolvedWalletId,
          selectedInstaPayAccountId: resolvedInstaPayAccountId,
        );
        await storage.saveRecord(pendingRecord);
        return pendingRecord;
      }

      // 5. Create Operation via OperationRepository
      final operationEntity = OperationEntity(
        id: 0,
        walletId: resolvedWalletId ?? 0,
        operationType: parseResult.operationType!,
        providerType: parseResult.providerType!,
        amount: parseResult.amount!,
        commission: 0.0,
        networkFee: parseResult.networkFee ?? 0.0,
        shiftId: activeShift.id,
        instaPayAccountId: resolvedInstaPayAccountId,
        phoneNumber: parseResult.phoneNumber,
        notes: 'استيراد SMS تلقائي (مرجع: ${parseResult.referenceNumber ?? "-"})',
        createdAt: parseResult.transactionDateTime ?? now,
      );

      final opRepo = sl<OperationRepository>();
      final createdOpId = await opRepo.addOperation(operationEntity);

      // Refresh related Cubits
      _refreshCubits();

      final importedRecord = _createBaseRecord(
        id: recordId,
        sender: sender,
        body: body,
        now: now,
        parseResult: parseResult,
        importStatus: SmsImportStatus.imported,
        selectedWalletId: resolvedWalletId,
        selectedInstaPayAccountId: resolvedInstaPayAccountId,
      ).copyWith(createdOperationId: createdOpId);

      await storage.saveRecord(importedRecord);
      debugPrint('SmsImportProcessor: Operation #$createdOpId created successfully for SMS $recordId');
      return importedRecord;
    } on InsufficientBalanceException {
      debugPrint('SmsImportProcessor: Insufficient wallet balance');
      final record = _createBaseRecord(
        id: fingerprint,
        sender: sender,
        body: body,
        now: now,
        parseResult: parser.parse(body, receivedAt: now),
        importStatus: SmsImportStatus.pending,
        failureReason: 'رصيد المحفظة غير كافٍ - اضغط للمراجعة',
      );
      await storage.saveRecord(record);
      return record;
    } on InsufficientCashDrawerBalanceException {
      debugPrint('SmsImportProcessor: Insufficient cash drawer balance');
      final record = _createBaseRecord(
        id: fingerprint,
        sender: sender,
        body: body,
        now: now,
        parseResult: parser.parse(body, receivedAt: now),
        importStatus: SmsImportStatus.pending,
        failureReason: 'رصيد درج النقدية غير كافٍ - اضغط للمراجعة لتسجيل مستحق أو تسوية الدرج',
      );
      await storage.saveRecord(record);
      return record;
    } catch (e) {
      debugPrint('SmsImportProcessor error: $e');
      final record = _createFailedRecord(
        id: fingerprint,
        sender: sender,
        body: body,
        now: now,
        reason: 'حدث خطأ أثناء استيراد العملية: $e',
      );
      await storage.saveRecord(record);
      return record;
    }
  }

  /// Re-processes all pending SMS records after a shift is opened
  Future<int> retryPendingRecords() async {
    try {
      final shiftRepo = sl<ShiftRepository>();
      final activeShift = await shiftRepo.getActiveShift();
      if (activeShift == null) {
        debugPrint('retryPendingRecords: No active shift, skipping.');
        return 0;
      }

      final allRecords = await storage.loadRecords();
      final pending = allRecords.where((r) => r.importStatus == SmsImportStatus.pending).toList();
      if (pending.isEmpty) return 0;

      int importedCount = 0;
      final opRepo = sl<OperationRepository>();
      final existingOps = await opRepo.getOperations();

      for (final record in pending) {
        try {
          // If already has operation id linked, just mark as imported
          if (record.createdOperationId != null && record.createdOperationId! > 0) {
            await storage.updateRecord(record.copyWith(
              importStatus: SmsImportStatus.imported,
              failureReason: null,
            ));
            continue;
          }

          // Check if reference number already exists in operations to prevent duplicates
          if (record.referenceNumber != null && record.referenceNumber!.trim().isNotEmpty) {
            final ref = record.referenceNumber!.trim();
            final matchedOp = existingOps.cast<OperationEntity?>().firstWhere(
                  (o) => o?.notes != null && o!.notes!.contains(ref),
                  orElse: () => null,
                );
            if (matchedOp != null) {
              await storage.updateRecord(record.copyWith(
                importStatus: SmsImportStatus.imported,
                createdOperationId: matchedOp.id,
                failureReason: null,
              ));
              continue;
            }
          }

          if (record.amount == null || record.amount! <= 0 || record.operationType == null) {
            continue;
          }

          // Resolve Wallet / Account
          int? resolvedWalletId = record.selectedWalletId;
          int? resolvedInstaPayAccountId = record.selectedInstaPayAccountId;
          String? missingAccountReason;

          if (record.providerType == ProviderType.vodafoneCash) {
            if (resolvedWalletId == null || resolvedWalletId <= 0) {
              final walletRepo = sl<WalletRepository>();
              final allWallets = await walletRepo.getWallets();
              final activeWallets = allWallets.where((w) => !w.isArchived).toList();

              WalletEntity? matched;
              if (record.myWalletPhone != null && record.myWalletPhone!.isNotEmpty) {
                matched = activeWallets.cast<WalletEntity?>().firstWhere(
                      (w) => w?.phoneNumber == record.myWalletPhone,
                      orElse: () => null,
                    );
              }
              if (matched == null) {
                if (activeWallets.length == 1) {
                  matched = activeWallets.first;
                } else {
                  final vfWallets = activeWallets.where((w) =>
                      w.name.toLowerCase().contains('vodafone') ||
                      w.name.contains('فودافون')).toList();
                  if (vfWallets.length == 1) {
                    matched = vfWallets.first;
                  }
                }
              }
              if (matched != null) {
                resolvedWalletId = matched.id;
              } else {
                missingAccountReason = 'يرجى تحديد المحفظة يدويًا للمراجعة والاستيراد';
              }
            }
          } else if (record.providerType == ProviderType.instaPay) {
            if (resolvedInstaPayAccountId == null) {
              final instaPayRepo = sl<InstaPayAccountRepository>();
              final allAccounts = await instaPayRepo.getAll();
              if (allAccounts.length == 1) {
                resolvedInstaPayAccountId = allAccounts.first.id;
              } else if (allAccounts.isEmpty) {
                missingAccountReason = 'لا يوجد أي حساب InstaPay مسجل في التطبيق';
              } else {
                missingAccountReason = 'يرجى اختيار حساب InstaPay يدويًا للمراجعة والاستيراد';
              }
            }

            if (resolvedWalletId == null || resolvedWalletId <= 0) {
              final walletRepo = sl<WalletRepository>();
              final allWallets = await walletRepo.getWallets();
              final activeWallets = allWallets.where((w) => !w.isArchived).toList();
              resolvedWalletId = activeWallets.isNotEmpty ? activeWallets.first.id : 0;
            }
          }

          if (missingAccountReason != null) {
            // Shift is open now! Update reason from "waiting for shift" to "needs account selection"
            await storage.updateRecord(record.copyWith(
              failureReason: missingAccountReason,
              selectedWalletId: resolvedWalletId,
              selectedInstaPayAccountId: resolvedInstaPayAccountId,
            ));
            continue;
          }

          // Attempt automatic import
          final opEntity = OperationEntity(
            id: 0,
            walletId: resolvedWalletId ?? 0,
            operationType: record.operationType!,
            providerType: record.providerType ?? ProviderType.vodafoneCash,
            amount: record.amount!,
            commission: 0.0,
            networkFee: record.networkFee ?? 0.0,
            shiftId: activeShift.id,
            instaPayAccountId: resolvedInstaPayAccountId,
            phoneNumber: record.phoneNumber,
            notes: 'استيراد SMS تلقائي (مرجع: ${record.referenceNumber ?? "-"})',
            createdAt: record.transactionDateTime ?? record.receivedAt,
          );

          final createdId = await opRepo.addOperation(opEntity);
          importedCount++;

          await storage.updateRecord(record.copyWith(
            importStatus: SmsImportStatus.imported,
            createdOperationId: createdId,
            failureReason: null,
            selectedWalletId: resolvedWalletId,
            selectedInstaPayAccountId: resolvedInstaPayAccountId,
          ));
        } on InsufficientCashDrawerBalanceException {
          // Keep pending for review so the user can import as payable
          await storage.updateRecord(record.copyWith(
            failureReason: 'رصيد درج النقدية غير كافٍ - اضغط للمراجعة لتسجيل مستحق أو تسوية الدرج',
          ));
        } on InsufficientBalanceException {
          await storage.updateRecord(record.copyWith(
            failureReason: 'رصيد المحفظة غير كافٍ لإتمام العملية',
          ));
        } catch (e) {
          debugPrint('retryPendingRecords for record ${record.id} error: $e');
        }
      }

      if (importedCount > 0) {
        _refreshCubits();
      }

      return importedCount;
    } catch (e) {
      debugPrint('retryPendingRecords top-level error: $e');
      return 0;
    }
  }

  /// Manually confirm and import a pending SMS record using EXACTLY the same
  /// business logic, models, validations, and Cubits as AddOperationPage.
  Future<int> importPendingRecord(
    SmsRecord record, {
    int? walletId,
    int? instaPayAccountId,
    double commission = 0.0,
    bool isDebt = false,
    bool isCreatePayable = false,
    double paidNow = 0.0,
    String? customerName,
    String? customerPhone,
  }) async {
    final shiftRepo = sl<ShiftRepository>();
    final activeShift = await shiftRepo.getActiveShift();
    if (activeShift == null) {
      throw Exception('يجب فتح وردية أولاً قبل إضافة عملية');
    }

    final targetWalletId = walletId ?? record.selectedWalletId ?? 0;
    final targetInstaPayId =
        instaPayAccountId ?? record.selectedInstaPayAccountId;

    if (record.providerType == ProviderType.vodafoneCash && targetWalletId <= 0) {
      throw Exception('يرجى اختيار المحفظة');
    }

    if (record.providerType == ProviderType.instaPay && targetInstaPayId == null) {
      throw Exception('يرجى اختيار حساب InstaPay');
    }

    final amount = record.amount ?? 0.0;
    if (amount <= 0) {
      throw Exception('يرجى إدخال مبلغ صحيح');
    }

    if (commission < 0) {
      throw Exception('لا يمكن أن تكون العمولة سالبة');
    }

    final opType = record.operationType ?? OperationType.deposit;
    final provType = record.providerType ?? ProviderType.vodafoneCash;

    final entity = OperationEntity(
      id: 0,
      walletId: targetWalletId,
      operationType: opType,
      providerType: provType,
      amount: amount,
      commission: commission,
      networkFee: provType == ProviderType.vodafoneCash ? (record.networkFee ?? 0.0) : 0.0,
      shiftId: activeShift.id,
      instaPayAccountId: provType == ProviderType.instaPay ? targetInstaPayId : null,
      phoneNumber: record.phoneNumber ?? '',
      notes: 'استيراد SMS (مرجع: ${record.referenceNumber ?? "-"})',
      createdAt: record.transactionDateTime ?? record.receivedAt,
    );

    final opCubit = sl<OperationCubit>();
    final debtCubit = sl<DebtCubit>();
    int createdOpId;

    if (opType == OperationType.withdrawal) {
      if (isCreatePayable) {
        final name = customerName?.trim() ?? '';
        if (name.isEmpty) {
          throw Exception('اسم المستحق له مطلوب');
        }
        if (paidNow <= 0) {
          createdOpId = await opCubit.addFullWithdrawalPayable(
            entity,
            customerName: name,
            customerPhone: customerPhone?.trim().isNotEmpty == true
                ? customerPhone!.trim()
                : null,
          );
        } else {
          createdOpId = await opCubit.addPartialWithdrawal(
            entity,
            customerName: name,
            customerPhone: customerPhone?.trim().isNotEmpty == true
                ? customerPhone!.trim()
                : null,
            paidNow: paidNow,
          );
        }
      } else {
        createdOpId = await opCubit.addOperation(entity, isDebt: false);
      }
    } else {
      // Deposit
      if (isDebt) {
        final name = customerName?.trim() ?? '';
        if (name.isEmpty) {
          throw Exception('اسم العميل مطلوب لتسجيل الآجل');
        }
        createdOpId = await opCubit.addOperation(entity, isDebt: true);
        await debtCubit.createDebtFromOperation(
          operationId: createdOpId,
          customerName: name,
          customerPhone: customerPhone?.trim().isNotEmpty == true
              ? customerPhone!.trim()
              : null,
          operationType: opType.name,
          providerType: provType.name,
          amount: amount + commission,
          notes: entity.notes,
        );
        await opCubit.getOperations();
      } else {
        createdOpId = await opCubit.addOperation(entity, isDebt: false);
      }
    }

    if (isCreatePayable || isDebt) {
      try {
        debtCubit.loadDebtors(silent: true);
      } catch (_) {}
    }
    _refreshCubits();

    final updated = record.copyWith(
      importStatus: SmsImportStatus.imported,
      createdOperationId: createdOpId,
      failureReason: null,
      selectedWalletId: targetWalletId,
      selectedInstaPayAccountId: targetInstaPayId,
    );

    await storage.updateRecord(updated);
    return createdOpId;
  }

  void _refreshCubits() {
    if (sl.isRegistered<OperationCubit>()) {
      try { sl<OperationCubit>().getOperations(); } catch (_) {}
    }
    if (sl.isRegistered<CashDrawerCubit>()) {
      try { sl<CashDrawerCubit>().refreshCashDrawer(); } catch (_) {}
    }
    if (sl.isRegistered<WalletCubit>()) {
      try { sl<WalletCubit>().getWallets(); } catch (_) {}
    }
  }

  SmsRecord _createBaseRecord({
    required String id,
    required String sender,
    required String body,
    required DateTime now,
    required ParsedSmsResult parseResult,
    required SmsImportStatus importStatus,
    String? failureReason,
    int? selectedWalletId,
    int? selectedInstaPayAccountId,
  }) {
    return SmsRecord(
      id: id,
      sender: sender,
      rawBody: body,
      receivedAt: now,
      parsedAt: DateTime.now(),
      parsingStatus: parseResult.status,
      importStatus: importStatus,
      providerType: parseResult.providerType,
      operationType: parseResult.operationType,
      amount: parseResult.amount,
      networkFee: parseResult.networkFee,
      phoneNumber: parseResult.phoneNumber,
      myWalletPhone: parseResult.myWalletPhone,
      partyName: parseResult.partyName,
      referenceNumber: parseResult.referenceNumber,
      balance: parseResult.balance,
      transactionDateTime: parseResult.transactionDateTime,
      failureReason: failureReason,
      selectedWalletId: selectedWalletId,
      selectedInstaPayAccountId: selectedInstaPayAccountId,
    );
  }

  SmsRecord _createFailedRecord({
    required String id,
    required String sender,
    required String body,
    required DateTime now,
    required String reason,
  }) {
    return SmsRecord(
      id: id,
      sender: sender,
      rawBody: body,
      receivedAt: now,
      parsedAt: DateTime.now(),
      parsingStatus: SmsParsingStatus.failed,
      importStatus: SmsImportStatus.failed,
      failureReason: reason,
    );
  }
}
