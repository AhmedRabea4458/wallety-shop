import 'package:intl/intl.dart';

/// Smart date formatter for transaction display.
/// 
/// Rules:
/// - Today: "اليوم • 3:45 PM"
/// - Yesterday: "أمس • 10:20 AM"
/// - Current year: "12 يونيو • 5:30 PM"
/// - Previous year: "12 يونيو 2025 • 5:30 PM"
class DateFormatter {
  static String formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final timeFormat = DateFormat('h:mm a', 'ar');
    final time = timeFormat.format(date);

    if (dateOnly == today) {
      return 'اليوم • $time';
    } else if (dateOnly == yesterday) {
      return 'أمس • $time';
    } else if (date.year == now.year) {
      final dayMonth = DateFormat('d MMMM', 'ar').format(date);
      return '$dayMonth • $time';
    } else {
      final dayMonthYear = DateFormat('d MMMM y', 'ar').format(date);
      return '$dayMonthYear • $time';
    }
  }

  /// Returns a group key for date grouping.
  /// 
  /// - Today: "اليوم"
  /// - Yesterday: "أمس"
  /// - Current year: "12 يونيو"
  /// - Previous year: "12 يونيو 2025"
  static String groupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'اليوم';
    } else if (dateOnly == yesterday) {
      return 'أمس';
    } else if (date.year == now.year) {
      return DateFormat('d MMMM', 'ar').format(date);
    } else {
      return DateFormat('d MMMM y', 'ar').format(date);
    }
  }
}
