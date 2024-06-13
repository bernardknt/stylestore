import 'package:intl/intl.dart';

class Utils {
  // static formatPrice(double price) => '${price.toStringAsFixed(2)}';
  static formatPrice(double price) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(price);
  }
  static formatDate(DateTime date) => DateFormat.MMMd().format(date);
}