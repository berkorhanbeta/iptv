import 'package:get/get.dart';
import 'package:iptv/screen/home/home_screen.dart';
import 'package:iptv/screen/home/tv_os/category_widget.dart';
import 'package:iptv/screen/home/tv_os/channel_widget.dart';
import 'package:iptv/screen/player/player_screen.dart';
import 'package:iptv/screen/settings/settings_screen.dart';

class PageNavigation {

  static const String home = '/';
  static const String channels = '/channels';
  static const String player = '/player';
  static const String settings = '/settings';


  static final routes = [
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: channels, page: () {
      final category = Get.parameters['category'] ?? '';
      return ChannelWidgetTV(category: category);
    }),
    GetPage(name: player, page: () {
      final channel = Get.parameters['id'] ?? '';
      return PlayerScreen(channel: channel);
    }),
    GetPage(name: settings, page: () => SettingsScreen())

  ];

}