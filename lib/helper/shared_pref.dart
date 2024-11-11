import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {


  Future<void> saveData(List<Map<String, String>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(data);
    await prefs.setString('savedData', jsonData);
  }

  Future<List<Map<String, String>>> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('savedData');
    if (jsonData != null) {
      List<dynamic> data = jsonDecode(jsonData);
      return data.map((item) => Map<String, String>.from(item)).toList();
    }
    return [];
  }

  Future<void> removeDataAt(int index) async {
    List<Map<String, String>> data = await loadData();
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      await saveData(data);
    }
  }

  Future<void> saveSelectedTV(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTV', address);
  }

  Future<String?> loadSelectedTV() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedTV');
  }

}
