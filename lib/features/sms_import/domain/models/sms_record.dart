import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/sms_import/domain/models/parsed_sms_result.dart';

enum SmsImportStatus {
  imported,
  pending,
  ignored,
  failed,
}

class SmsRecord {
  final String id;
  final String sender;
  final String rawBody;
  final DateTime receivedAt;
  final DateTime parsedAt;
  final SmsParsingStatus parsingStatus;
  final SmsImportStatus importStatus;
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
  final int? createdOperationId;
  final String? failureReason;
  final int? selectedWalletId;
  final int? selectedInstaPayAccountId;

  const SmsRecord({
    required this.id,
    required this.sender,
    required this.rawBody,
    required this.receivedAt,
    required this.parsedAt,
    required this.parsingStatus,
    required this.importStatus,
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
    this.createdOperationId,
    this.failureReason,
    this.selectedWalletId,
    this.selectedInstaPayAccountId,
  });

  SmsRecord copyWith({
    String? id,
    String? sender,
    String? rawBody,
    DateTime? receivedAt,
    DateTime? parsedAt,
    SmsParsingStatus? parsingStatus,
    SmsImportStatus? importStatus,
    ProviderType? providerType,
    OperationType? operationType,
    double? amount,
    double? networkFee,
    String? phoneNumber,
    String? myWalletPhone,
    String? partyName,
    String? referenceNumber,
    double? balance,
    DateTime? transactionDateTime,
    int? createdOperationId,
    String? failureReason,
    int? selectedWalletId,
    int? selectedInstaPayAccountId,
  }) {
    return SmsRecord(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      rawBody: rawBody ?? this.rawBody,
      receivedAt: receivedAt ?? this.receivedAt,
      parsedAt: parsedAt ?? this.parsedAt,
      parsingStatus: parsingStatus ?? this.parsingStatus,
      importStatus: importStatus ?? this.importStatus,
      providerType: providerType ?? this.providerType,
      operationType: operationType ?? this.operationType,
      amount: amount ?? this.amount,
      networkFee: networkFee ?? this.networkFee,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      myWalletPhone: myWalletPhone ?? this.myWalletPhone,
      partyName: partyName ?? this.partyName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      balance: balance ?? this.balance,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
      createdOperationId: createdOperationId ?? this.createdOperationId,
      failureReason: failureReason ?? this.failureReason,
      selectedWalletId: selectedWalletId ?? this.selectedWalletId,
      selectedInstaPayAccountId:
          selectedInstaPayAccountId ?? this.selectedInstaPayAccountId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'rawBody': rawBody,
      'receivedAt': receivedAt.toIso8601String(),
      'parsedAt': parsedAt.toIso8601String(),
      'parsingStatus': parsingStatus.name,
      'importStatus': importStatus.name,
      'providerType': providerType?.name,
      'operationType': operationType?.name,
      'amount': amount,
      'networkFee': networkFee,
      'phoneNumber': phoneNumber,
      'myWalletPhone': myWalletPhone,
      'partyName': partyName,
      'referenceNumber': referenceNumber,
      'balance': balance,
      'transactionDateTime': transactionDateTime?.toIso8601String(),
      'createdOperationId': createdOperationId,
      'failureReason': failureReason,
      'selectedWalletId': selectedWalletId,
      'selectedInstaPayAccountId': selectedInstaPayAccountId,
    };
  }

  factory SmsRecord.fromJson(Map<String, dynamic> json) {
    return SmsRecord(
      id: json['id'] as String,
      sender: json['sender'] as String? ?? '',
      rawBody: json['rawBody'] as String? ?? '',
      receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
          DateTime.now(),
      parsedAt: DateTime.tryParse(json['parsedAt'] as String? ?? '') ??
          DateTime.now(),
      parsingStatus: SmsParsingStatus.values.firstWhere(
        (e) => e.name == json['parsingStatus'],
        orElse: () => SmsParsingStatus.ignored,
      ),
      importStatus: SmsImportStatus.values.firstWhere(
        (e) => e.name == json['importStatus'],
        orElse: () => SmsImportStatus.ignored,
      ),
      providerType: json['providerType'] != null
          ? ProviderType.values.firstWhere(
              (e) => e.name == json['providerType'],
              orElse: () => ProviderType.vodafoneCash,
            )
          : null,
      operationType: json['operationType'] != null
          ? OperationType.values.firstWhere(
              (e) => e.name == json['operationType'],
              orElse: () => OperationType.deposit,
            )
          : null,
      amount: (json['amount'] as num?)?.toDouble(),
      networkFee: (json['networkFee'] as num?)?.toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      myWalletPhone: json['myWalletPhone'] as String?,
      partyName: json['partyName'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      transactionDateTime: json['transactionDateTime'] != null
          ? DateTime.tryParse(json['transactionDateTime'] as String)
          : null,
      createdOperationId: json['createdOperationId'] as int?,
      failureReason: json['failureReason'] as String?,
      selectedWalletId: json['selectedWalletId'] as int?,
      selectedInstaPayAccountId: json['selectedInstaPayAccountId'] as int?,
    );
  }
}
