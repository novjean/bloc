import 'package:flutter/material.dart';

const String kAppTitle = 'bloc';

class Constants {
  static const String appVersion = '1.8.9';

  //Colors for theme
  static const Color primary = Color.fromRGBO(211, 167, 130, 1);
  static const Color lightPrimary =  Color.fromRGBO(222, 193, 170, 1);
  static const Color darkPrimary = Color.fromRGBO(42, 33, 26, 1);

  static const Color background = Color.fromRGBO(38, 50, 56, 1.0);

  static Color lightAccent = const Color(0xff5563ff);
  static Color darkAccent = const Color(0xff5563ff);
  static Color lightBG = const Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color? ratingBG = Colors.red[600];

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    // accentColor: lightAccent,
    // cursorColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      // textTheme: TextTheme(
      //   headline6: TextStyle(
      //     color: darkBG,
      //     fontSize: 18.0,
      //     fontWeight: FontWeight.w800,
      //   ),
      // ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    // accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    // cursorColor: darkAccent,
    appBarTheme: AppBarTheme(
      // textTheme: TextTheme(
      //   headline6: TextStyle(
      //     color: lightBG,
      //     fontSize: 18.0,
      //     fontWeight: FontWeight.w800,
      //   ),
      // ),
    ),
  );

  static int USER_LEVEL = 1;
  static int CAPTAIN_LEVEL = 3;
  static int PROMOTER_LEVEL = 4;
  static int MANAGER_LEVEL = 5;
  static int OWNER_LEVEL = 7;


  // flagship store kept for ease of reference
  static String blocServiceId = 'UVU4XPqTYr3U0YhQzEhg';

  static int skipPhoneNumber = 911234567890;

  static String clubRules = '- entry is restricted to the age of 21+ \n- we are a community. respect everyone and their space on the floor. don’t be a killjoy!! \n- do not carry illegal substances. there isn\'t a better drug than music! \n- keep a smile and respect other patrons, artists, staff, bouncers, and the community. \n- please refrain from using the phrase \'you don\'t know who I am\'. we are all humans here and unfortunately, pets are not allowed.\n- you are being shot by our cameras. no guns and ammunition in the club allowed.\n- violence will not be tolerated. keep P.L.U.R on your mind: peace, love, unity & respect.\n- always toast before a shot. have fun and stay classy.\n- you are responsible for your valuable belongings, that includes your partners. Keep an eye!\n- Open footwear is not allowed. No one likes an “Ouch” moment!\n- Rights of admission reserved for the ones who deserve.\n- You are important to us. Do not Drink & Drive.';
  static String guestListRules = 'guest list shuts at 11 pm on the day of the event. club entry charges apply.';

}
