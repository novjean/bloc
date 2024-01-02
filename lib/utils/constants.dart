import 'package:flutter/material.dart';

const String kAppTitle = 'bloc';

class Constants {

  //todo: check all testMode before release
  static const String appVersion = '4.1.6';

  static const String fontDefault = 'Oswald';

  //Colors for theme
  static const Color primary = Color.fromRGBO(211, 167, 130, 1);
  static const Color lightPrimary =  Color.fromRGBO(222, 193, 170, 1);
  static const Color darkPrimary = Color.fromRGBO(42, 33, 26, 1);

  static const Color background = Color.fromRGBO(27, 26, 23, 1);
  static const Color backgroundWhite = Color.fromRGBO(255, 255, 240, 1);

  static const Color errorColor = Color.fromRGBO(220, 20, 60, 1);
  static const Color shadowColor = Color.fromRGBO(158, 158, 158, 1);

  static const Color hopp = Color.fromRGBO(248, 194, 32, 1);
  static const Color ferrari = Color.fromRGBO(255, 40, 0, 1);

  static Color lightAccent = const Color(0xff5563ff);
  static Color darkAccent = const Color(0xff5563ff);
  static Color lightBG = const Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color? ratingBG = Colors.red[600];

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBG,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBG,
  );

  static int CUSTOMER_LEVEL = 1;
  static int CAPTAIN_LEVEL = 3;
  static int PROMOTER_LEVEL = 4;
  static int MANAGER_LEVEL = 5;
  static int OWNER_LEVEL = 7;
  static int ADMIN_LEVEL = 69;

  // flagship store kept for ease of reference
  static String blocServiceId = 'UVU4XPqTYr3U0YhQzEhg';
  static String blocPromoterId = 'QQEck1k84xT49iLPtRaPWeKtOIhp';
  static String blocCommunityLoungeId = 'HZfHfnB09xBcl5haYavd2nyvXiyF';
  static String ladiesLoungeId = 'uieGkTmtQQP4F8RKSEq57bpWezbl';

  static String blocInstaHandle = 'https://www.instagram.com/bloc.communitybar/';
  static String blocGoogleReview = 'https://g.page/r/CUPsfopXRRX8EBM/review';
  static String blocAppStoreId = '1672736309';

  static const String urlBlocWeb= 'https://bloc.bar/#/';
  static const String urlBlocPlayStore = 'https://play.google.com/store/apps/details?id=com.novatech.bloc';
  static const String urlBlocAppStore = 'https://apps.apple.com/in/app/bloc-community/id1672736309';

  static double blocLatitude = 18.537952548349075;
  static double blocLongitude = 73.9126973030436;

  static String blocUuid = 'ulwX8iOEOiNrZSIkFDFS1kakRSi2';

  static String freqInstaHandle = 'https://www.instagram.com/freq.club/';
  static String freqGoogleReview = 'https://g.page/r/CVIkJ_SP99KOEAI/review';

  static int skipPhoneNumber = 911234567890;

  static String clubRules = '- entry is restricted to the age of 21+ \n- we are a community. respect everyone and their space on the floor. don’t be a killjoy!! \n- do not carry illegal substances. there isn\'t a better drug than music! \n- keep a smile and respect other patrons, artists, staff, bouncers, and the community. \n- please refrain from using the phrase \'you don\'t know who I am\'. we are all humans here and unfortunately, pets are not allowed.\n- you are being shot by our cameras. no guns and ammunition in the club allowed.\n- violence will not be tolerated. keep P.L.U.R on your mind: peace, love, unity & respect.\n- always toast before a shot. have fun and stay classy.\n- you are responsible for your valuable belongings, that includes your partners. Keep an eye!\n- Open footwear is not allowed. No one likes an “Ouch” moment!\n- Rights of admission reserved for the ones who deserve.\n- You are important to us. Do not Drink & Drive.';
  static String guestListRules = 'guest list shuts at {} on the day of the event. club entry charges may apply.';

  static String loungeRules = '✓ act respectfully towards everyone \n✓ please keep chats in "English" in order to have everyone included and able to join the conversations\n✓ hateful language, bigotry, race, orientation, bullying and therealike are condemned and will not be tolerated. This also includes “imagery”, “profile pictures” and “display” names (moderators reserve the right to change nicknames)\n✓ we avoid discussing politics, religion and other sensitive topics. The risk of misunderstandings is too big and we are here to have a good time!\n✓ do not impersonate others - just be your true self!\n✓ self promoting, advertising, soliciting, pump-and-dump schemes, and NSFW content is not allowed.\n✓ team members and moderators will NEVER DM you asking for personal information, seed phrase, or anything of the sort.\n✓ please exercise caution and report anything suspicious\n✓ breaking or bending of any rules will result in a permanent ban\n✓ most importantly: be kind, respectful and have fun!';

  /** configs **/
  static String configQuickOrder = 'quick order';

  /** ticketing **/
  static double igstPercent = 0.1525;
  static double bookingFeePercent = 0.059;

  /** phone pe **/
  static String testSaltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  static String testSaltIndex = "1";
  static String phonePeApiEndPoint = "/pg/v1/pay";

  static String prodHostUrl = "https://api.phonepe.com/apis/hermes";

  /** phone pe test **/
  static String testEnvironment = "UAT_SIM";
  static String testMerchantId = "PGTESTPAYUAT";

  /** phone pe prod **/
  static String saltKey = "34765f86-1b43-4395-a9cb-0bea807630d9";
  static String saltIndex = "1";
  static String environment = "PRODUCTION";
  static String iosAppId = "c8cf8a00d27b450cb80491bd6e21ef5b";
  static String androidAppId = "d4f45bc915f048e2b7eed50f0115648f";
  static String merchantId = "BLOCKONLINE";

}
