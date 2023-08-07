import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';

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
}
