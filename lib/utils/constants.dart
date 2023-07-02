import 'package:flutter/material.dart';

const String kAppTitle = 'bloc';

class Constants {
  static const String appVersion = '2.0.6';

  static const String fontDefault = 'Oswald';

  //Colors for theme
  static const Color primary = Color.fromRGBO(211, 167, 130, 1);
  static const Color lightPrimary =  Color.fromRGBO(222, 193, 170, 1);
  static const Color darkPrimary = Color.fromRGBO(42, 33, 26, 1);

  static const Color background = Color.fromRGBO(27, 26, 23, 1);

  static const Color hopp = Color.fromRGBO(248, 194, 32, 1);


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

  static int CUSTOMER_LEVEL = 1;
  static int CAPTAIN_LEVEL = 3;
  static int PROMOTER_LEVEL = 4;
  static int MANAGER_LEVEL = 5;
  static int OWNER_LEVEL = 7;
  static int ADMIN_LEVEL = 69;


  // flagship store kept for ease of reference
  static String blocServiceId = 'UVU4XPqTYr3U0YhQzEhg';

  static int skipPhoneNumber = 911234567890;

  static String clubRules = '- entry is restricted to the age of 21+ \n- we are a community. respect everyone and their space on the floor. don’t be a killjoy!! \n- do not carry illegal substances. there isn\'t a better drug than music! \n- keep a smile and respect other patrons, artists, staff, bouncers, and the community. \n- please refrain from using the phrase \'you don\'t know who I am\'. we are all humans here and unfortunately, pets are not allowed.\n- you are being shot by our cameras. no guns and ammunition in the club allowed.\n- violence will not be tolerated. keep P.L.U.R on your mind: peace, love, unity & respect.\n- always toast before a shot. have fun and stay classy.\n- you are responsible for your valuable belongings, that includes your partners. Keep an eye!\n- Open footwear is not allowed. No one likes an “Ouch” moment!\n- Rights of admission reserved for the ones who deserve.\n- You are important to us. Do not Drink & Drive.';
  static String guestListRules = 'guest list shuts at 11 pm on the day of the event. club entry charges apply.';

  static String loungeRules = '✓ act respectfully towards everyone \n✓ please keep chats in "English" in order to have everyone included and able to join the conversations\n✓ hateful language, bigotry, race, orientation, bullying and therealike are condemned and will not be tolerated. This also includes “imagery”, “profile pictures” and “display” names (moderators reserve the right to change nicknames)\n✓ we avoid discussing politics, religion and other sensitive topics. The risk of misunderstandings is too big and we are here to have a good time!\n✓ do not impersonate others - just be your true self!\n✓ self promoting, advertising, soliciting, pump-and-dump schemes, and NSFW content is not allowed.\n✓ team members and moderators will NEVER DM you asking for personal information, seed phrase, or anything of the sort.\n✓ please exercise caution and report anything suspicious\n✓ breaking or bending of any rules will result in a permanent ban\n✓ most importantly: be kind, respectful and have fun!';
}
