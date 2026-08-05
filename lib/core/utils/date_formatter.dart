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

  static String formatFullDateTime(DateTime date) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a', 'ar').format(date);
    if (date.year == now.year) {
      final dayMonth = DateFormat('d MMMM', 'ar').format(date);
      return '$dayMonth • $timeStr';
    } else {
      final fullDate = DateFormat('d MMMM y', 'ar').format(date);
      return '$fullDate • $timeStr';
    }
  }

  static String formatDateOnly(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year) {
      return DateFormat('d MMMM', 'ar').format(date);
    }
    return DateFormat('d MMMM y', 'ar').format(date);
  }

  static String formatTimeOnly(DateTime date) {
    return DateFormat('h:mm a', 'ar').format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      if (mins == 1) return 'منذ دقيقة';
      if (mins == 2) return 'منذ دقيقتين';
      if (mins >= 3 && mins <= 10) return 'منذ $mins دقائق';
      return 'منذ $mins دقيقة';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours >= 3 && hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (diff.inDays < 7) {
      final days = diff.inDays;
      if (days == 1) return 'أمس';
      if (days == 2) return 'منذ يومين';
      if (days >= 3 && days <= 10) return 'منذ $days أيام';
      return 'منذ $days يوم';
    } else {
      return formatDateOnly(date);
    }
  }

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
