import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';

enum SmsParsingStatus {
  parsed,
  ignored,
  failed,
}

class ParsedSmsResult {
  final SmsParsingStatus status;
  final ProviderType? providerType;
  final OperationType? operationType;
  final double? amount;
  final double? networkFee;
  final String? phoneNumber;
  final String? myWalletPhone;
  final String? partyName;
  final String? referenceNumber;
  final double? balance;
  final DateTime? transactionDateTime;
  final String? rawBody;
  final String? errorReason;

  const ParsedSmsResult({
    required this.status,
    this.providerType,
    this.operationType,
    this.amount,
    this.networkFee,
    this.phoneNumber,
    this.myWalletPhone,
    this.partyName,
    this.referenceNumber,
    this.balance,
    this.transactionDateTime,
    this.rawBody,
    this.errorReason,
  });

  bool get isSuccessful =>
      status == SmsParsingStatus.parsed &&
      providerType != null &&
      operationType != null &&
      amount != null &&
      amount! > 0;
}
