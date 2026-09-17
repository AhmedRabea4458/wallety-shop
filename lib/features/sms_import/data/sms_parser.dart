import 'package:smart_expense/features/operations/domain/entities/operation_entity.dart';
import 'package:smart_expense/features/operations/domain/entities/provider_type.dart';
import 'package:smart_expense/features/sms_import/domain/models/parsed_sms_result.dart';

class SmsParser {
  const SmsParser();

  /// Parse incoming SMS body text.
  /// Returns a [ParsedSmsResult] with parsing status and extracted fields.
  ParsedSmsResult parse(String rawText, {DateTime? receivedAt}) {
    if (rawText.trim().isEmpty) {
      return const ParsedSmsResult(
        status: SmsParsingStatus.ignored,
        errorReason: 'Empty message body',
      );
    }

    final normalized = _normalizeText(rawText);

    // 1. InstaPay Check
    if (normalized.contains('تم إضافة تحويل لحظي')) {
      return _parseInstaPayIncoming(normalized, rawText, receivedAt);
    } else if (normalized.contains('تم تنفيذ تحويل لحظي')) {
      return _parseInstaPayOutgoing(normalized, rawText, receivedAt);
    }

    // 2. Vodafone Cash Check
    if (normalized.contains('تم استلام مبلغ')) {
      return _parseVodafoneCashIncoming(normalized, rawText, receivedAt);
    } else if (normalized.contains('تم تحويل') &&
        (normalized.contains('فودافون كاش') ||
            normalized.contains('مصاريف الخدمة') ||
            normalized.contains('لرقم') ||
            normalized.contains('رقم العملية'))) {
      return _parseVodafoneCashOutgoing(normalized, rawText, receivedAt);
    }

    // Unknown or unsupported SMS
    return ParsedSmsResult(
      status: SmsParsingStatus.ignored,
      rawBody: rawText,
      errorReason: 'Not recognized as Vodafone Cash or InstaPay transaction',
    );
  }

  /// Normalize Arabic-Indic digits to ASCII 0-9 and clean extra spaces
  static String _normalizeText(String text) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = text;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], '$i');
    }
    // Replace non-breaking spaces
    result = result.replaceAll('\u00A0', ' ');
    return result;
  }

  static double? _parseDouble(String? str) {
    if (str == null) return null;
    var cleaned = str.replaceAll(',', '').trim();
    while (cleaned.endsWith('.') || cleaned.endsWith('،') || cleaned.endsWith('؛')) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    }
    return double.tryParse(cleaned);
  }

  // -------------------------------------------------------------
  // VODAFONE CASH INCOMING
  // -------------------------------------------------------------
  ParsedSmsResult _parseVodafoneCashIncoming(
    String normalized,
    String rawBody,
    DateTime? receivedAt,
  ) {
    try {
      // Amount: تم استلام مبلغ 35000.00 جنيه
      final amountMatch = RegExp(
        r'تم\s+استلام\s+مبلغ\s+([0-9.,]+)\s*جني?ه?',
        caseSensitive: false,
      ).firstMatch(normalized);
      final amount = _parseDouble(amountMatch?.group(1));

      if (amount == null || amount <= 0) {
        return ParsedSmsResult(
          status: SmsParsingStatus.failed,
          rawBody: rawBody,
          errorReason: 'Failed to extract valid amount',
        );
      }

      // Sender phone: من 01100404969
      final phoneMatch = RegExp(
        r'من\s+([0-9]{11})',
      ).firstMatch(normalized);
      final phone = phoneMatch?.group(1);

      // Sender name: المسجل بإسم ...
      final nameMatch = RegExp(
        r'المسجل\s+بإ?سم\s+([^;\n\r]+?)(?:\s+على|\s+بتاريخ|\n|\r|;|$)',
      ).firstMatch(normalized);
      final senderName = nameMatch?.group(1)?.trim();

      // Recipient wallet: على رقم محفظتك 01069163385
      final walletMatch = RegExp(
        r'على\s+رقم\s+محفظتك\s+([0-9]{11})',
      ).firstMatch(normalized);
      final myWalletPhone = walletMatch?.group(1);

      // Balance: رصيدك الحالي: 35104.21 جنيه
      final balanceMatch = RegExp(
        r'رصيد.*?الحال[يي]\s*[:\s]*([0-9.,]+)',
      ).firstMatch(normalized);
      final balance = _parseDouble(balanceMatch?.group(1));

      // Operation Number: رقم العملية: 023669021826
      final refMatch = RegExp(
        r'رقم\s+العملية\s*[:\s]*([0-9]+)',
      ).firstMatch(normalized);
      final ref = refMatch?.group(1);

      // Date & Time: بتاريخ 17:03 26-09-13
      final date = _parseVodafoneDate(normalized, receivedAt);

      return ParsedSmsResult(
        status: SmsParsingStatus.parsed,
        providerType: ProviderType.vodafoneCash,
        // INCOMING: العميل أرسل فلوس للمحل → سحب (withdrawal) يزيد رصيد المحفظة
        operationType: OperationType.withdrawal,
        amount: amount,
        networkFee: 0.0,
        phoneNumber: phone,
        myWalletPhone: myWalletPhone,
        partyName: senderName,
        referenceNumber: ref,
        balance: balance,
        transactionDateTime: date,
        rawBody: rawBody,
      );
    } catch (e) {
      return ParsedSmsResult(
        status: SmsParsingStatus.failed,
        rawBody: rawBody,
        errorReason: 'Error parsing Vodafone Cash Incoming: $e',
      );
    }
  }

  // -------------------------------------------------------------
  // VODAFONE CASH OUTGOING
  // -------------------------------------------------------------
  ParsedSmsResult _parseVodafoneCashOutgoing(
    String normalized,
    String rawBody,
    DateTime? receivedAt,
  ) {
    try {
      // Amount: تم تحويل 5000 جنيه
      final amountMatch = RegExp(
        r'تم\s+تحويل\s+([0-9.,]+)\s*جني?ه?',
        caseSensitive: false,
      ).firstMatch(normalized);
      final amount = _parseDouble(amountMatch?.group(1));

      if (amount == null || amount <= 0) {
        return ParsedSmsResult(
          status: SmsParsingStatus.failed,
          rawBody: rawBody,
          errorReason: 'Failed to extract valid amount',
        );
      }

      // Recipient phone: لرقم 01037192909
      final phoneMatch = RegExp(
        r'لرقم\s+([0-9]{11})',
      ).firstMatch(normalized);
      final phone = phoneMatch?.group(1);

      // Network fee: مصاريف الخدمة 1 جنيه
      final feeMatch = RegExp(
        r'مصاريف\s+الخدمة\s+([0-9.,]+)\s*جني?ه?',
      ).firstMatch(normalized);
      final networkFee = _parseDouble(feeMatch?.group(1)) ?? 0.0;

      // Balance: رصيد حسابك فى فودافون كاش الحالي 24.71
      final balanceMatch = RegExp(
        r'رصيد.*?الحال[يي]\s*[:\s]*([0-9.,]+)',
      ).firstMatch(normalized);
      final balance = _parseDouble(balanceMatch?.group(1));

      // Operation Number: رقم العملية 023682228634
      final refMatch = RegExp(
        r'رقم\s+العملية\s*[:\s]*([0-9]+)',
      ).firstMatch(normalized);
      final ref = refMatch?.group(1);

      // Date & Time: تاريخ العملية 22:56 26-09-13
      final date = _parseVodafoneDate(normalized, receivedAt);

      return ParsedSmsResult(
        status: SmsParsingStatus.parsed,
        providerType: ProviderType.vodafoneCash,
        // OUTGOING: المحل أرسل فلوس للعميل → إيداع (deposit) يقلل رصيد المحفظة
        operationType: OperationType.deposit,
        amount: amount,
        networkFee: networkFee,
        phoneNumber: phone,
        referenceNumber: ref,
        balance: balance,
        transactionDateTime: date,
        rawBody: rawBody,
      );
    } catch (e) {
      return ParsedSmsResult(
        status: SmsParsingStatus.failed,
        rawBody: rawBody,
        errorReason: 'Error parsing Vodafone Cash Outgoing: $e',
      );
    }
  }

  // -------------------------------------------------------------
  // INSTAPAY INCOMING
  // -------------------------------------------------------------
  ParsedSmsResult _parseInstaPayIncoming(
    String normalized,
    String rawBody,
    DateTime? receivedAt,
  ) {
    try {
      // Amount: بمبلغ 100.00 جم
      final amountMatch = RegExp(
        r'بمبلغ\s+([0-9.,]+)\s*(?:جم|جنيه)',
      ).firstMatch(normalized);
      final amount = _parseDouble(amountMatch?.group(1));

      if (amount == null || amount <= 0) {
        return ParsedSmsResult(
          status: SmsParsingStatus.failed,
          rawBody: rawBody,
          errorReason: 'Failed to extract valid amount',
        );
      }

      // Sender Name: من احمد محمد عبدالحميد محمد
      final nameMatch = RegExp(
        r'من\s+([^\n\r]+?)(?:\s+رقم\s+مرجعي|\n|\r|$)',
      ).firstMatch(normalized);
      final senderName = nameMatch?.group(1)?.trim();

      // Reference Number: رقم مرجعي 480397057893
      final refMatch = RegExp(
        r'رقم\s+مرجعي\s*[:\s]*([0-9]+)',
      ).firstMatch(normalized);
      final ref = refMatch?.group(1);

      // Date & Time: يوم 07-28 الساعة 20:24
      final date = _parseInstaPayDate(normalized, receivedAt);

      return ParsedSmsResult(
        status: SmsParsingStatus.parsed,
        providerType: ProviderType.instaPay,
        // INCOMING: العميل أرسل فلوس للمحل → سحب (withdrawal) يزيد رصيد الحساب
        operationType: OperationType.withdrawal,
        amount: amount,
        networkFee: 0.0,
        partyName: senderName,
        referenceNumber: ref,
        transactionDateTime: date,
        rawBody: rawBody,
      );
    } catch (e) {
      return ParsedSmsResult(
        status: SmsParsingStatus.failed,
        rawBody: rawBody,
        errorReason: 'Error parsing InstaPay Incoming: $e',
      );
    }
  }

  // -------------------------------------------------------------
  // INSTAPAY OUTGOING
  // -------------------------------------------------------------
  ParsedSmsResult _parseInstaPayOutgoing(
    String normalized,
    String rawBody,
    DateTime? receivedAt,
  ) {
    try {
      // Amount: بمبلغ 200.00 جم
      final amountMatch = RegExp(
        r'بمبلغ\s+([0-9.,]+)\s*(?:جم|جنيه)',
      ).firstMatch(normalized);
      final amount = _parseDouble(amountMatch?.group(1));

      if (amount == null || amount <= 0) {
        return ParsedSmsResult(
          status: SmsParsingStatus.failed,
          rawBody: rawBody,
          errorReason: 'Failed to extract valid amount',
        );
      }

      // Receiver Name: إلى MOHAMED E**** H****
      final nameMatch = RegExp(
        r'إلى\s+([^\n\r]+?)(?:\s+رقم\s+مرجعي|\n|\r|$)',
      ).firstMatch(normalized);
      final receiverName = nameMatch?.group(1)?.trim();

      // Reference Number: رقم مرجعي 886170697508
      final refMatch = RegExp(
        r'رقم\s+مرجعي\s*[:\s]*([0-9]+)',
      ).firstMatch(normalized);
      final ref = refMatch?.group(1);

      // Date & Time: يوم 07-25 الساعة 00:17
      final date = _parseInstaPayDate(normalized, receivedAt);

      return ParsedSmsResult(
        status: SmsParsingStatus.parsed,
        providerType: ProviderType.instaPay,
        // OUTGOING: المحل أرسل فلوس للعميل → إيداع (deposit) يقلل رصيد الحساب
        operationType: OperationType.deposit,
        amount: amount,
        networkFee: 0.0,
        partyName: receiverName,
        referenceNumber: ref,
        transactionDateTime: date,
        rawBody: rawBody,
      );
    } catch (e) {
      return ParsedSmsResult(
        status: SmsParsingStatus.failed,
        rawBody: rawBody,
        errorReason: 'Error parsing InstaPay Outgoing: $e',
      );
    }
  }

  // -------------------------------------------------------------
  // DATE PARSING HELPERS
  // -------------------------------------------------------------
  DateTime? _parseVodafoneDate(String text, DateTime? fallback) {
    try {
      // Formats like: "17:03 26-09-13" or "26-09-13 17:03"
      final match1 = RegExp(
        r'([0-9]{1,2}:[0-9]{2})\s+([0-9]{2,4}-[0-9]{2}-[0-9]{2})',
      ).firstMatch(text);
      if (match1 != null) {
        return _buildDateTime(datePart: match1.group(2)!, timePart: match1.group(1)!);
      }

      final match2 = RegExp(
        r'([0-9]{2,4}-[0-9]{2}-[0-9]{2})\s+([0-9]{1,2}:[0-9]{2})',
      ).firstMatch(text);
      if (match2 != null) {
        return _buildDateTime(datePart: match2.group(1)!, timePart: match2.group(2)!);
      }
    } catch (_) {}
    return fallback;
  }

  DateTime? _parseInstaPayDate(String text, DateTime? fallback) {
    try {
      // Format: يوم 07-28 الساعة 20:24
      final match = RegExp(
        r'يوم\s+([0-9]{1,2}-[0-9]{1,2})\s+الساعة\s+([0-9]{1,2}:[0-9]{2})',
      ).firstMatch(text);

      if (match != null) {
        final datePart = match.group(1)!; // e.g. 07-28
        final timePart = match.group(2)!; // e.g. 20:24

        final dateSegments = datePart.split('-');
        final month = int.parse(dateSegments[0]);
        final day = int.parse(dateSegments[1]);

        final timeSegments = timePart.split(':');
        final hour = int.parse(timeSegments[0]);
        final minute = int.parse(timeSegments[1]);

        final now = fallback ?? DateTime.now();
        int year = now.year;
        // If current month is Jan and message month is Dec, it might be previous year
        if (now.month == 1 && month == 12) {
          year -= 1;
        }

        return DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}
    return fallback;
  }

  DateTime _buildDateTime({required String datePart, required String timePart}) {
    final dateSegments = datePart.split('-');
    int year;
    int month;
    int day;

    if (dateSegments[0].length == 4) {
      // YYYY-MM-DD
      year = int.parse(dateSegments[0]);
      month = int.parse(dateSegments[1]);
      day = int.parse(dateSegments[2]);
    } else {
      // YY-MM-DD (e.g. 26-09-13 -> 2026-09-13)
      final rawYear = int.parse(dateSegments[0]);
      year = rawYear < 100 ? 2000 + rawYear : rawYear;
      month = int.parse(dateSegments[1]);
      day = int.parse(dateSegments[2]);
    }

    final timeSegments = timePart.split(':');
    final hour = int.parse(timeSegments[0]);
    final minute = int.parse(timeSegments[1]);

    return DateTime(year, month, day, hour, minute);
  }
}
