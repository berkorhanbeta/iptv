import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:iptv/model/iptv/iptv_model.dart';

class HomeController extends ChangeNotifier {
  static Map<String, List<IptvModel>> groupedIptv = {}; // Grouped channels map
  static bool isTV = false;


  getIPTV(List<String> urls) async {
    Dio dio = Dio();
    try {
      List<Response> responses = await Future.wait(
        urls.map((url) => dio.get(url)),
      );
      Map<int, Response> resMap = responses.asMap();
      for (int index in resMap.keys.toList()) {
        List<String> file = responses[index].data.toString().split('\n');
        file = file.where((element) =>
        element
            .trim()
            .isNotEmpty).toList();
        createIPTV(file);
      }
    } catch (e) {
      print(e);
    }
  }

  void createIPTV(List<String> file) {
    if (file.first.contains('#EXTM3U')) {
      file.removeAt(0);
    }
    file = file
        .where((element) =>
    element.contains('#EXTINF:') ||
        element.startsWith('http') ||
        element.startsWith('#EXTVLCOPT:'))
        .toList();

    IptvModel? currentChannel;

    for (String line in file) {
      if (line.startsWith('#EXTINF:')) {
        var nameMatch = RegExp(r'tvg-name="([^"]+)"').firstMatch(line);
        if (nameMatch == null) {
          nameMatch = RegExp(r'tvg-id="([^"]+)"').firstMatch(line);
        }
        final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(line);
        final groupMatch = RegExp(r'group-title="([^"]+)"').firstMatch(line);

        currentChannel = IptvModel(
          name: nameMatch?.group(1),
          logo: logoMatch?.group(1),
          groupTitle: groupMatch?.group(1),
        );
      } else if (line.startsWith('#EXTVLCOPT:')) {
        final referrerMatch = RegExp(r'http-referrer=(.*)').firstMatch(line);
        currentChannel?.referrer = referrerMatch?.group(1);
      } else if (line.startsWith('http')) {
        currentChannel?.url = line;

        if (currentChannel != null) {
          String group = currentChannel.groupTitle ??
              'Unknown';

          if (!groupedIptv.containsKey(group)) {
            groupedIptv[group] = []; 
          }
          groupedIptv[group]!.add(
              currentChannel);
        }
      }
    }
  }


  static String _selected = 'Unknown';
  String get selected => _selected;
  void setSelected(String value) {
    _selected = value;
    notifyListeners();
  }

}
