import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../main.dart';
import '../widgets/ui/toaster.dart';

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
    logger.e(tag + ':' + e.toString());
    FirebaseCrashlytics.instance.recordError(e, s);
  }

  static void em(String tag, String message) {
    String text = tag + ':' + message;
    logger.e(text);
    FirebaseCrashlytics.instance.log(text);
  }
  static void ex(String tag, String message, Exception e, StackTrace s) {
    logger.e(tag + ':' + message + e.toString());
    FirebaseCrashlytics.instance.recordError(e, s);
  }

  static void d(String tag, String message) {
    String text = tag + ':' + message;
    logger.d(text);
  }

}
