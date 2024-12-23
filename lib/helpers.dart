import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadJson(String filename) async {
  String jsonString = await rootBundle.loadString('assets/$filename.json');
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return jsonData;
}
