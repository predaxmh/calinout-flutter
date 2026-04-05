class TimeFormatter {
  TimeFormatter._();

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;
    final minutePadded = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';

    return '$displayHour:$minutePadded $period';
  }
}
