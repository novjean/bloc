import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../utils/logx.dart';
import '../widgets/ui/toaster.dart';

class FirestorageHelper {
  static const String _TAG = 'FirestorageHelper';
  static var logger = Logger();

  static String AD_IMAGES = 'ad_image';
  static String AD_CAMPAIGN_IMAGES = 'ad_campaign_image';
  static String ADVERT_IMAGES = 'advert_image';
  static String USERS = 'user_image';
  static String BLOCS_IMAGES = 'bloc_image';
  static String BLOCS_MAP_IMAGES = 'bloc_map_image';
  static String BLOCS_SERVICES_IMAGES = 'bloc_service_image';
  static String CATEGORY_IMAGES = 'service_category_image';
  static String CHAT_IMAGES = 'chat_image';
  static String LOUNGE_IMAGES = 'lounge_image';
  static String NOTIFICATION_TEST_IMAGES = 'notification_test_image';
  static String ORGANIZER_IMAGES = 'organizer_image';
  static String PRODUCT_IMAGES = 'product_image';
  static String PARTY_IMAGES = 'party_image';
  static String PARTY_STORY_IMAGES = 'party_story_image';
  static String PARTY_PHOTO_IMAGES = 'party_photo_image';
  static String PARTY_PHOTO_THUMB_IMAGES = 'party_photo_thumb_image';
  static String SUPPORT_CHAT_IMAGES = 'support_chat_image';
  static String UI_PHOTO_IMAGES = 'ui_photo_image';
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
    Logx.d(_TAG, "uploadFile : ${file.path}");

    String url = '';

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(directory)
          .child(docId + '.jpg');

      await ref.putFile(file, SettableMetadata(contentType: 'image/jpg')).then((pO){
        Logx.i(_TAG, 'data transferred: ${pO.bytesTransferred / 1000} kb');
      });
      url = await ref.getDownloadURL();
      Logx.i(_TAG, 'uploadFile success: $url');
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