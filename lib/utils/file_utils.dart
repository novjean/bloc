import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {

  static write(String fileName, String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${fileName}');
    file.writeAsString(text);
  }
}