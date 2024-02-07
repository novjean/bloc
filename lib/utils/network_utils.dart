import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'logx.dart';

class NetworkUtils {
  static const String _TAG = 'NetworkUtils';

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Logx.i(_TAG, 'bloc is connected');
        return true;
      }
    } on SocketException catch (_) {
      Logx.em(_TAG, 'internet connection is not present, bloc is not connected');
      return false;
    }
    return false;
  }

  static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('could not launch $url');
    }
  }

  static Future<void> launchInAppBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
    )) {
      throw Exception('could not launch $url');
    }
  }

  // Function to make a phone call
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final uri = Uri.parse(phoneNumber);
      await launchUrl(uri);
    } catch (e) {
      Logx.est(_TAG, 'phone calling failed, please try again.');
    }
  }

}