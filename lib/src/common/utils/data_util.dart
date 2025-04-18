import 'package:intl/intl.dart';

class AppDataUtil {
  static String dateFormat(String format, DateTime date) {
    return DateFormat(format).format(date);
  }
}
