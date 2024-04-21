import 'package:intl/intl.dart';
import 'package:stylestore/model/common_functions.dart';

class Utils {
  static formatPrice(double price) => '${CommonFunctions().formatter.format(price)}';
  static formatDate(DateTime date) => DateFormat.MMMd().format(date);
}