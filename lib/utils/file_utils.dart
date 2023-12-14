import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


import 'logx.dart';

class FileUtils {
  static const String _TAG = 'FileUtils';

  static write(String fileName, String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${fileName}');
    file.writeAsString(text);
  }

  static void downloadFileForWeb(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  static void openFileNewTabForWeb(String url) {
    html.window.open(url, 'new tab');
  }

  static void shareCsvFile(String fileName, String text, String shareMessage) async {
    var temp = await getTemporaryDirectory();
    final path = '${temp.path}/$fileName';
    await File(path).writeAsString(text);

    final files = <XFile>[];
    files.add(
        XFile(path, name: fileName));

    await Share.shareXFiles(files,
        text: '#blocCommunity: $shareMessage');
  }

  static void saveNetworkImage(String imagePath, String fileName) async {
    String finalName = 'bloc-$fileName'.replaceAll(' ', '');
    var response = await Dio().get(
      imagePath,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: finalName.trim());

    bool isSuccess = result['isSuccess'];

    if(isSuccess){
      Logx.ist(_TAG, 'photo saved to gallery as $fileName');
    } else {
      Logx.est(_TAG, 'photo save failed, please try again');
    }
  }

  static Future<File> getAssetImageAsFile(String assetPath) async {
    // Load the asset image data
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Get a temporary directory to store the compressed image
    var temp = await getTemporaryDirectory();
    final path = '${temp.path}/temp_image.png';
    final tempFile = File(path);

    // Compress and write the image to the temporary file
    final compressedImage = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 250,
      minWidth: 250,
      quality: 95,
    );

    await tempFile.writeAsBytes(compressedImage);

    return tempFile;
  }

  static Future<File> getImageCompressed(String filePath, int minHeight, int minWidth, int quality) async {
    // Load the asset image data
    File file = File(filePath);
    final Uint8List bytes = await file.readAsBytes();

    // Get a temporary directory to store the compressed image
    var temp = await getTemporaryDirectory();
    final path = '${temp.path}/temp_image.png';
    final tempFile = File(path);

    // Compress and write the image to the temporary file
    final compressedImage = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
    );

    await tempFile.writeAsBytes(compressedImage);

    return tempFile;
  }

  static void sharePhoto(String id, String urlImage, String fileName, String shareText) async {
    final Uri url = Uri.parse(urlImage);
    final response = await http.get(url);
    final Uint8List bytes = response.bodyBytes;

    try{
      var temp = await getTemporaryDirectory();
      final path = '${temp.path}/$fileName.png';
      File(path).writeAsBytesSync(bytes);

      final files = <XFile>[];
      files.add(
          XFile(path, name: '$fileName.jpg'));

      await Share.shareXFiles(files,
          text: shareText.isEmpty? '#blocCommunity': shareText);
    } catch(e){
      Logx.em(_TAG, e.toString());
    }
  }

  static void shareFile(String id, String path, String fileName) async {
    try{
      final files = <XFile>[];
      files.add(
          XFile(path, name: fileName));

      await Share.shareXFiles(files, text: '#blocCommunity');
    } catch(e){
      Logx.em(_TAG, e.toString());
    }
  }

}
