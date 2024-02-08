import 'dart:convert';

class ApiHelper {
  static String encodeJsonToBase64(Map<String, dynamic> jsonData) {
    String jsonString = jsonEncode(jsonData);
    String base64String = base64Encode(utf8.encode(jsonString));
    return base64String;
  }
}