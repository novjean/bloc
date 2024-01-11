import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../main.dart';
import '../widgets/ui/toaster.dart';
import 'constants.dart';

class Logx {
  static void i(String tag, String message) {
    String text = '$tag:$message';
    logger.i(text);
    FirebaseCrashlytics.instance.log(text);
  }

  static void ist(String tag, String message) {
    String text = '$tag:$message';
    logger.i(text);
    FirebaseCrashlytics.instance.log(text);
    Toaster.shortToast(message);
  }

  static void ilt(String tag, String message) {
    String text = '$tag:$message';
    logger.i(text);
    FirebaseCrashlytics.instance.log(text);
    Toaster.longToast(message);
  }

  static void e(String tag, Exception e, StackTrace s) {
    logger.e('$tag:$e');
    FirebaseCrashlytics.instance.recordError(e, s);
  }

  static void em(String tag, String message) {
    String text = '$tag:$message';
    logger.e(text);
    FirebaseCrashlytics.instance.log(text);
  }
  static void ex(String tag, String message, Exception e, StackTrace s) {
    logger.e('$tag:$message$e');
    FirebaseCrashlytics.instance.recordError(e, s);
  }

  static void est(String tag, String message) {
    String text = '$tag:$message';
    logger.e(text);
    FirebaseCrashlytics.instance.log(text);
    Toaster.shortToast(message);
  }

  static void elt(String tag, String message) {
    String text = '$tag:$message';
    logger.e(text);
    FirebaseCrashlytics.instance.log(text);
    Toaster.longToast(message);
  }

  static void d(String tag, String message) {
    String text = '$tag:$message';
    logger.d(text);
  }

  static void dst(String tag, String message) {
    String text = '$tag:$message';
    logger.d(text);
    FirebaseCrashlytics.instance.log(text);
    Toaster.shortToast(message);
  }

  static void alt(String tag, String message) {
    String text = '$tag:$message';
    logger.d(text);
    FirebaseCrashlytics.instance.log(text);

    if(UserPreferences.myUser.clearanceLevel==Constants.ADMIN_LEVEL){
      Toaster.longToast(message);
    }
  }

}
