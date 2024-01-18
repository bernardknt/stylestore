import 'package:intl/intl.dart';

class Utils {
  static formatPrice(double price) => 'Ugx ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date) => DateFormat.MMMd().format(date);
}