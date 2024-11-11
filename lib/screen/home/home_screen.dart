import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/helper/page_navigation.dart';
import 'package:iptv/helper/shared_pref.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:iptv/screen/home/controller/home_controller.dart';
import 'package:iptv/screen/home/tv_os/category_widget.dart';
import 'package:iptv/screen/home/widget/category_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: tv(),
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.yellow[300]!,
                size: 200,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text("APPBeta Mobile IPTV"),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Liste yenilendi'))
                        );
                      });
                    },
                    icon: Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.toNamed('${PageNavigation.settings}');
                    },
                    icon: Icon(Icons.settings),
                  )
                ],
              ),
                body: Column(
                  children: [
                    Expanded(
                      child: HomeController.isTV ? CategoryWidgetTV() : CategoryWidget(),
                    ),
                  ],
                )
            );
          }
        }
    );
  }

  List<IptvModel> searchResults = [];
  void searchResult(String query) {
    searchResults = []; // Initialize as an empty list
    HomeController.groupedIptv.forEach((group, channels) {
      searchResults.addAll(
        channels.where((item) =>
        item.name != null && item.name!.toLowerCase().contains(query.toLowerCase())
        ).toList(),
      );
    });

    for (var element in searchResults) {
      print(element.name);
    }
  }


  String? selectedTv;
  final SharedPref _sharedPref = SharedPref();
  Future<void> tv() async {
    HomeController homeController = HomeController();
    HomeController.groupedIptv.clear();
    selectedTv = await _sharedPref.loadSelectedTV();
    if(selectedTv != null){
      await homeController.getIPTV([selectedTv!]);
    } else {
      //await homeController.getIPTV(['https://appbeta.net/']);
      await homeController.getIPTV(['https://iptv-org.github.io/iptv/index.m3u']);
    }

    if(!kIsWeb){
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      HomeController.isTV = androidInfo.systemFeatures.contains('android.software.leanback');
    }


  }



}