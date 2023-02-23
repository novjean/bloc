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

  static String firstFewWords(String bigSentence, int numOfWords){

    int startIndex = 0, indexOfSpace = 0;

    for(int i = 0; i < numOfWords; i++){
      indexOfSpace = bigSentence.indexOf(' ', startIndex);
      if(indexOfSpace == -1){     //-1 is when character is not found
        return bigSentence;
      }
      startIndex = indexOfSpace + 1;
    }

    return bigSentence.substring(0, indexOfSpace);
  }

  static int getWordCount(String value) {
    RegExp regExp = RegExp(" ");
    int count = regExp.allMatches(value).length + 1;
    return count;
  }
}
