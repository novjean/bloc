import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../widgets/ui/Toaster.dart';

class FirestorageHelper {
  static var logger = Logger();

  static String USERS = 'user_image';
  static String BLOCS_IMAGES = 'bloc_image';
  static String BLOCS_SERVICES_IMAGES = 'bloc_service_image';
  static String PRODUCT_IMAGES = 'product_image';

  static Future<bool> deleteFile(String fileUrl) async {
    final firebaseStorage = FirebaseStorage.instance;

    try{
      await firebaseStorage.refFromURL(fileUrl).delete();
      return true;
    } on PlatformException catch (err) {
      logger.e(err.message);
      Toaster.shortToast("File deletion failed. Check credentials.");
    } catch (err) {
      logger.e(err);
      Toaster.shortToast("File deletion failed.");
    }
    return false;
  }

  static uploadFile(String directory, String docId, File file) async {
    logger.d("uploadFile : " + file.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child(directory)
        .child(docId + '.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    return url;
  }

}