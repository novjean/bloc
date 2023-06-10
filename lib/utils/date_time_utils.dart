import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';

import '../widgets/ui/toaster.dart';
import 'logx.dart';

class DateTimeUtils {
  static const String _TAG = 'DateTimeUtils';

  static int millisecondsHour = 3600000;
  static int millisecondsDay = 86400000;
  static int millisecondsWeek = 604800000;

  static List<String> formatTypes = ['yMMMMEEEEd'];

  static String getFormattedDateString(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
    return date;
  }

  static String getFormattedDateType(int millis, int type){
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat(formatTypes[type]).format(dt);
    return date;
  }

  //fri, may 12
  static String getFormattedDate(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('MMMEd').format(dt);
    return date.toLowerCase();
  }

  //saturday, may 6
  static String getFormattedDate2(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('MMMMEEEEd').format(dt);
    return date.toLowerCase();
  }

  //8 pm
  static String getFormattedTime(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('j').format(dt);
    return date.toLowerCase();
  }

  // 8:30 PM
  static String getFormattedTime2(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('hh:mm a').format(dt);
    return date;
  }

  static String getFormattedDateYear(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('yMMMd').format(dt);
    return date.toLowerCase();
  }

  static DateTime getDate(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static TimeOfDay getTimeOfDay(String sTimeOfDay) {
    TimeOfDay time = TimeOfDay(hour:int.parse(sTimeOfDay.split(":")[0]),minute: int.parse(sTimeOfDay.split(":")[1]));
    return time;
  }

  // 6:30 PM
  static TimeOfDay convertTimeString(String timeString) {
    final DateFormat dateFormat = DateFormat('hh:mm a');
    final DateTime dateTime = dateFormat.parse(timeString);
    final TimeOfDay timeOfDay = TimeOfDay(
      hour: dateTime.hour,
      minute: dateTime.minute,
    );
    return timeOfDay;
  }

}