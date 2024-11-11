import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/helper/page_navigation.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:iptv/screen/home/controller/home_controller.dart';
import 'package:iptv/screen/home/widget/channel_widget.dart';

class CategoryWidget extends StatefulWidget {
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  int? selectedIndex = 0;
  String? searchQery;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  onTap: () {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) async {
                searchResult(controller.text);

                return List<ListTile>.generate(searchResults.length~/2, (int index) {
                  final IptvModel item = searchResults[index];
                  return ListTile(
                    title: Text(item.name ?? 'Unknown'), // Handle null names gracefully
                    onTap: () {
                      setState(() {
                        Get.toNamed('${PageNavigation.player}', parameters: {'channel': jsonEncode(item)});
                      });
                    },
                  );
                });
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.width > 600 ? 0 : 15),
            Expanded(child: checkScreen())
          ],
        )
      )
    );
  }

  checkScreen(){

    if(MediaQuery.of(context).size.width > 600) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: category(),
            height: double.infinity,
            width: MediaQuery.of(context).size.width / 3,
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: ChannelWidget(),
            height: double.infinity,
            width: MediaQuery.of(context).size.width / 2,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: category(),
          ),
          SizedBox(height: 10),
          Expanded(child: ChannelWidget())
        ],
      );
    }
  }

  category() {
    return ListView.separated(
      scrollDirection: MediaQuery.of(context).size.width > 600 ? Axis.vertical : Axis.horizontal,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 35, color: Colors.transparent),
      itemCount: HomeController.groupedIptv.keys.length,
      itemBuilder: (context, int index) {
        String groupTitle = HomeController.groupedIptv.keys.elementAt(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
              HomeController().setSelected(HomeController.groupedIptv.keys.elementAt(index));
              print('${HomeController.groupedIptv.keys.elementAt(index)}');
            });
          },
          child: Row(
            children: [
              MediaQuery.of(context).size.width > 600 ?
                Icon(Icons.live_tv, color: selectedIndex == index ? Colors.yellow[300] : Colors.white) :
                SizedBox(width: 15),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: MediaQuery.of(context).size.width > 600 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text(
                    groupTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == index ? Colors.yellow[300] : Colors.white,
                    ),
                  ),
                  Text(
                    '${HomeController.groupedIptv[groupTitle]!.length} Kanal',
                    style: TextStyle(
                      color: selectedIndex == index ? Colors.yellow[300] : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<IptvModel> searchResults = [];
  void searchResult(String query) {
    setState(() {
      searchResults = []; // Initialize as an empty list
      HomeController.groupedIptv.forEach((group, channels) {
        searchResults.addAll(
          channels.where((item) =>
          item.name != null && item.name!.toLowerCase().contains(query.toLowerCase())
          ).toList()
        );
      });
    });

  }
}
