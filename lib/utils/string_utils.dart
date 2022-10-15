import 'dart:math';

class StringUtils {
  static String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static int getInt(String word) {
    String aStr = word.replaceAll(new RegExp(r'[^0-9]'),'');
    int value = int.parse(aStr);
    return value;
  }

  static double getDouble(String word) {
    String aStr = word.replaceAll(new RegExp(r'[^0-9]'),'');
    double value = double.parse(aStr);
    return value;
  }
}
