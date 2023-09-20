import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../main.dart';
import '../screens/parties/box_office_guest_confirm_screen.dart';
import '../widgets/ui/toaster.dart';
import 'logx.dart';

class ScanUtils {
  static const String _TAG = 'ScanUtils';

  static void scanCode(BuildContext context) async {
    String scanCode;

    try {
      scanCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'cancel', true, ScanMode.QR);
      Logx.i(_TAG, 'code scanned $scanCode');
      if (scanCode != '-1') {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) => BoxOfficeGuestConfirmScreen(
                    partyGuestId: scanCode,
                  )),
        );
      } else {
        Logx.i(_TAG, 'scan cancelled');
      }
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
      Toaster.longToast('code scan failed, not get platform version');
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
      Toaster.longToast('scan failed : $e');
    } catch (e) {
      logger.e(e);
      Toaster.longToast('scan failed : $e');
    }

    if (!context.mounted) {
      return;
    }
  }
}
