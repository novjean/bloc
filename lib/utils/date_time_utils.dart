import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getFormattedDateString(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
    return date;
  }

  static String getFormattedDate(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('MMMEd').format(dt);
    return date.toLowerCase();
  }

  static String getFormattedTime(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('j').format(dt);
    return date.toLowerCase();
  }

  static String getFormattedDateYear(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('yMMMd').format(dt);
    return date.toLowerCase();
  }

  static DateTime getDate(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

}