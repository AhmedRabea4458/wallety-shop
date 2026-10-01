import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_expense/core/utils/arabic_numerals.dart';
import 'package:smart_expense/core/utils/date_formatter.dart';

class DebtReminderHelper {
  DebtReminderHelper._();

  /// Normalizes phone number to international Egyptian format (e.g. 2010xxxxxxxx)
  /// for WhatsApp wa.me links.
  static String normalizeEgyptianPhoneNumber(String raw) {
    if (raw.trim().isEmpty) return '';

    // Convert Arabic/Eastern numerals to Western numerals
    String cleaned = arabicToWesternNumerals(raw);

    // Remove all non-digit characters except leading +
    cleaned = cleaned.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.startsWith('00')) {
      cleaned = cleaned.substring(2);
    }

    // Standard Egyptian 12-digit format starting with 20
    if (cleaned.startsWith('20') && cleaned.length == 12) {
      return cleaned;
    }

    // 11-digit format starting with 0 (e.g. 01012345678, 011..., 012..., 015...)
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return '20${cleaned.substring(1)}';
    }

    // 10-digit format without leading 0 (e.g. 1012345678, 11..., 12..., 15...)
    if (cleaned.length == 10 &&
        (cleaned.startsWith('10') ||
            cleaned.startsWith('11') ||
            cleaned.startsWith('12') ||
            cleaned.startsWith('15'))) {
      return '20$cleaned';
    }

    // If it already starts with 20
    if (cleaned.startsWith('20')) {
      return cleaned;
    }

    // If it starts with 0
    if (cleaned.startsWith('0')) {
      return '20${cleaned.substring(1)}';
    }

    // Return sanitized digits
    return cleaned;
  }

  /// Sanitizes phone number for the device dialer.
  static String getDialerPhoneNumber(String raw) {
    if (raw.trim().isEmpty) return '';
    String cleaned = arabicToWesternNumerals(raw);
    cleaned = cleaned.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned;
  }

  /// Calculates the age of a debt in calendar days from [createdAt] to [now].
  static int calculateDebtAgeInDays(DateTime createdAt, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final createdDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );
    final today = DateTime(current.year, current.month, current.day);
    final diff = today.difference(createdDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Formats the duration of a debt in natural Arabic:
  /// 0 -> "اليوم"
  /// 1 -> "منذ يوم"
  /// 2 -> "منذ يومين"
  /// 3..10 -> "منذ X أيام"
  /// 11+ -> "منذ X يوم"
  static String formatDebtAgeArabic(DateTime createdAt, [DateTime? now]) {
    final days = calculateDebtAgeInDays(createdAt, now);
    if (days == 0) {
      return 'اليوم';
    } else if (days == 1) {
      return 'منذ يوم';
    } else if (days == 2) {
      return 'منذ يومين';
    } else if (days >= 3 && days <= 10) {
      return 'منذ $days أيام';
    } else {
      return 'منذ $days يوم';
    }
  }

  /// Generates a polite Egyptian Arabic debt reminder message.
  /// Does NOT use the word "متأخر" since there is no due date by default.
  /// Never invents a due date.
  static String buildDebtReminderMessage({
    required String customerName,
    required double remainingAmount,
    DateTime? dueDate,
  }) {
    final formattedAmount = NumberFormat(
      '#,##0.##',
      'ar',
    ).format(remainingAmount);
    final buffer = StringBuffer();

    buffer.writeln('القرشي | Vodafone Cash');
    buffer.writeln();
    buffer.writeln('السلام عليكم ورحمة الله وبركاته 🌷');
    buffer.writeln();
    buffer.writeln('أهلاً بحضرتك يا $customerName،');
    buffer.writeln();
    buffer.writeln(
      'حابين نفكّر حضرتك إن فيه مبلغ متبقي من معاملة Vodafone Cash آجلة بقيمة $formattedAmount ج.م.',
    );

    if (dueDate != null) {
      buffer.writeln();
      buffer.writeln(
        '📅 تاريخ الاستحقاق: ${DateFormatter.formatTransactionDate(dueDate)}',
      );
    }

    buffer.writeln();
    buffer.writeln('ياريت يتم السداد في أقرب وقت مناسب لحضرتك 🙏');
    buffer.writeln();
    buffer.write('شكرًا لحسن تعاملكم معنا.');

    return buffer.toString().trim();
  }

  /// Opens WhatsApp directly to the customer's phone number with a pre-filled reminder message.
  /// Returns `true` if opened successfully, `false` otherwise.
  static Future<bool> openWhatsApp({
    required String phone,
    required String message,
  }) async {
    final normalized = normalizeEgyptianPhoneNumber(phone);
    if (normalized.isEmpty) return false;

    final encodedMessage = Uri.encodeComponent(message);
    final waMeUri = Uri.parse('https://wa.me/$normalized?text=$encodedMessage');

    try {
      final launched = await launchUrl(
        waMeUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {
      // Fall through to try native scheme
    }

    try {
      final nativeUri = Uri.parse(
        'whatsapp://send?phone=$normalized&text=$encodedMessage',
      );
      final launched = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (_) {
      return false;
    }
  }

  /// Opens the device dialer with the customer's phone number.
  /// Returns `true` if opened successfully, `false` otherwise.
  static Future<bool> openDialer({required String phone}) async {
    final dialerNum = getDialerPhoneNumber(phone);
    if (dialerNum.isEmpty) return false;

    final telUri = Uri(scheme: 'tel', path: dialerNum);
    try {
      return await launchUrl(telUri);
    } catch (_) {
      return false;
    }
  }
}
