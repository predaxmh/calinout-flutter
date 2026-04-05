class ValueFormatter {
  ValueFormatter._();

  static String formatNumber(double value, {int decimals = 1}) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(decimals);
  }
}
