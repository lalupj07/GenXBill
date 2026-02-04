import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatAmount(double amount, String currencyCode) {
    String symbol = '';
    String locale = 'en_IN';

    switch (currencyCode) {
      case 'USD':
        symbol = '\$';
        locale = 'en_US';
        break;
      case 'EUR':
        symbol = '€';
        locale = 'en_EU';
        break;
      case 'GBP':
        symbol = '£';
        locale = 'en_GB';
        break;
      case 'JPY':
        symbol = '¥';
        locale = 'ja_JP';
        break;
      case 'INR':
      default:
        symbol = '₹';
        locale = 'en_IN';
        break;
    }

    final format = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    );

    return format.format(amount);
  }

  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
      default:
        return '₹';
    }
  }
}
