
import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getFormattedDateString(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
    return date;
  }

}