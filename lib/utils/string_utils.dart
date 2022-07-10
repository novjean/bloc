import 'dart:math';

class StringUtils {
  static String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static int getNumberOnly(String word) {
    String aStr = word.replaceAll(new RegExp(r'[^0-9]'),'');
    int aInt = int.parse(aStr);
    return aInt;
  }
}
