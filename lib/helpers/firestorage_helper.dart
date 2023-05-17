import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../utils/logx.dart';
import '../widgets/ui/toaster.dart';

class FirestorageHelper {
  static const String _TAG = 'FirestorageHelper';
  static var logger = Logger();

  static String USERS = 'user_image';
  static String BLOCS_IMAGES = 'bloc_image';
  static String BLOCS_SERVICES_IMAGES = 'bloc_service_image';
  static String CATEGORY_IMAGES = 'service_category_image';
  static String PRODUCT_IMAGES = 'product_image';
  static String PARTY_IMAGES = 'party_image';
  static String PARTY_STORY_IMAGES = 'party_story_image';
  static String USER_IMAGES = 'user_image';

  static Future<bool> deleteFile(String fileUrl) async {
    final firebaseStorage = FirebaseStorage.instance;

    try{
      await firebaseStorage.refFromURL(fileUrl).delete();
      Logx.d(_TAG, '$fileUrl deleted successfully');
      return true;
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
      Toaster.shortToast("file deletion failed. check credentials.");
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
      Toaster.shortToast("file deletion failed.");
    }
    return false;
  }

  static uploadFile(String directory, String docId, File file) async {
    logger.d("uploadFile : " + file.path);

    String url = '';

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(directory)
          .child(docId + '.jpg');
      await ref.putFile(file);
      url = await ref.getDownloadURL();
      Logx.i(_TAG, 'uploadFile success: ' + url.toString());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }

    return url;
  }

}