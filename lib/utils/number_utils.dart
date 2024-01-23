import 'dart:math';

class NumberUtils {
  static double getPercentage(double current, double previous) {
    double percentage = (current/previous) * 100;
    return roundDouble(percentage, 2);
  }

  static double roundDouble(double value, int places){
    double mod = pow(10.0, places) as double;
    return ((value * mod).round().toDouble() / mod);
  }

  static int getRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

}