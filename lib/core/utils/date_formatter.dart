import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'ru_RU').format(date);
  }

  static String getShortDayName(DateTime date) {
    return DateFormat('EE', 'ru_RU').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} лет назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} месяцев назад';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} недель назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} дней назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} часов назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} минут назад';
    } else {
      return 'только что';
    }
  }
}