import 'package:flutter/material.dart';

abstract final class AppFormatters {
  static String money(
    double amount, {
    required String symbol,
    bool trimDecimals = false,
  }) {
    final safeAmount = amount.abs();
    final useWholeNumber =
        trimDecimals && safeAmount == safeAmount.roundToDouble();
    final value = useWholeNumber
        ? safeAmount.toStringAsFixed(0)
        : safeAmount.toStringAsFixed(2);
    return '$value $symbol';
  }

  static String signedMoney(
    double amount, {
    required String symbol,
    required bool positive,
  }) {
    final prefix = positive ? '+' : '-';
    return '$prefix${money(amount, symbol: symbol)}';
  }

  static String dayDate(DateTime date, Locale locale, {bool padDay = false}) {
    final day = padDay ? date.day.toString().padLeft(2, '0') : '${date.day}';
    return '$day ${_monthLabel(date.month, locale)} ${date.year}';
  }

  static String monthChip(DateTime date, Locale locale) {
    return '${_monthLabel(date.month, locale)} ${date.year}';
  }

  static String _monthLabel(int month, Locale locale) {
    final languageCode = locale.languageCode;
    final months = switch (languageCode) {
      'pl' => const [
        'sty',
        'lut',
        'mar',
        'kwi',
        'maj',
        'cze',
        'lip',
        'sie',
        'wrz',
        'paź',
        'lis',
        'gru',
      ],
      'ru' => const [
        'янв',
        'фев',
        'мар',
        'апр',
        'май',
        'июн',
        'июл',
        'авг',
        'сен',
        'окт',
        'ноя',
        'дек',
      ],
      _ => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ],
    };
    return months[month - 1];
  }
}
