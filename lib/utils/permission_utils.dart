import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      // Camera permission is granted
      return true;
    } else {
      // Camera permission is not granted
      return false;
    }
  }
}