import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';

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


  static String getFormattedDate3(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('MMMMd').format(dt);
    return date.toLowerCase();
  }

  static String getFormattedDate4(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('yMd').format(dt);
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

  //jul 30, 2023
  static String getFormattedDateYear(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = DateFormat('yMMMd').format(dt);
    return date.toLowerCase();
  }

  static DateTime getDate(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  // 6:30 PM
  static TimeOfDay convertStringToTime(String timeString) {
    final DateFormat dateFormat = DateFormat('hh:mm a');
    final DateTime dateTime = dateFormat.parse(timeString);
    final TimeOfDay timeOfDay = TimeOfDay(
      hour: dateTime.hour,
      minute: dateTime.minute,
    );
    return timeOfDay;
  }
  // 6:30 PM
  static String convertTimeToString(TimeOfDay tod){
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final DateFormat dateFormat = DateFormat('hh:mm a');
    return dateFormat.format(dt);
  }

  static String getChatDate(int time) {
    int now = Timestamp.now().millisecondsSinceEpoch;

    if(now-time<millisecondsDay){
      return getFormattedTime2(time);
    } else {
      return getFormattedDate3(time);
    }
  }

  static String getDay(int millis) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOfWeek[dateTime.weekday - 1];
  }

}