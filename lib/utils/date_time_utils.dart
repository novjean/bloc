import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
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

  static TimeOfDay getTimeOfDay(String sTimeOfDay) {
    TimeOfDay time = TimeOfDay(hour:int.parse(sTimeOfDay.split(":")[0]),minute: int.parse(sTimeOfDay.split(":")[1]));
    return time;
  }

  static TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

}