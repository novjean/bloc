import 'dart:io';

import 'package:gallery_saver/gallery_saver.dart';
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

  static void saveNetworkImage(String imagePath) async {
    GallerySaver.saveImage(imagePath).then((bool? success) {
      Logx.ist(_TAG, 'photo saved in gallery');
    });
  }

}
