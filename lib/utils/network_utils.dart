import 'dart:io';
import 'package:url_launcher/url_launcher.dart';


class NetworkUtils {
  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('bloc is connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
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

}