import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iptv/helper/page_navigation.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:iptv/screen/home/controller/home_controller.dart';
import 'package:iptv/screen/home/home_screen.dart';
import 'package:iptv/screen/home/tv_os/channel_widget.dart';
import 'package:iptv/screen/home/widget/channel_widget.dart';

class CategoryWidgetTV extends StatefulWidget {

  @override
  _CategoryWidgetTVState createState() => _CategoryWidgetTVState();
}

class _CategoryWidgetTVState extends State<CategoryWidgetTV> {
  int? selectedIndex = 0;
  String? searchQuery;
  List<IptvModel> searchResults = [];

  // Focus Nodes for Android TV remote navigation
  FocusNode searchFocusNode = FocusNode();
  FocusNode categoryFocusNode = FocusNode();
  List<FocusNode> channelFocusNodes = [];

  @override
  void dispose() {
    // Dispose focus nodes when the widget is disposed
    searchFocusNode.dispose();
    categoryFocusNode.dispose();
    channelFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            !HomeController.isTV ? SearchAnchor(
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
                  focusNode: searchFocusNode, // Assign focus node for remote control
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) async {
                searchResult(controller.text);

                return List<ListTile>.generate(searchResults.length ~/ 2, (int index) {
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
            ) : SizedBox(),
            SizedBox(height: MediaQuery.of(context).size.width > 600 ? 0 : 15),
            Expanded(child: category())
          ],
        ),
      ),
    );
  }

  Widget category() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 35, color: Colors.transparent),
      itemCount: HomeController.groupedIptv.keys.length,
      itemBuilder: (context, int index) {
        String groupTitle = HomeController.groupedIptv.keys.elementAt(index);

        return Focus(
          canRequestFocus: true,
          onFocusChange: (isFocused) {
            setState(() {
              if (isFocused) {
                selectedIndex = index;
              }
            });
          },
          onKey: (FocusNode node, RawKeyEvent event) {
            if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.select) {
              // OK tuşuna basıldığında seçim yapılır
              setState(() {
                selectedIndex = index;
                HomeController().setSelected(HomeController.groupedIptv.keys.elementAt(index));
                print('${HomeController.groupedIptv.keys.elementAt(index)} seçildi');

              });
              Get.toNamed('${PageNavigation.channels}', parameters: {'category': HomeController.groupedIptv[HomeController().selected]!.elementAt(index).name!});
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;

          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
                HomeController().setSelected(HomeController.groupedIptv.keys.elementAt(index));
                print('${HomeController.groupedIptv.keys.elementAt(index)}');
              });
              Get.toNamed('${PageNavigation.channels}', parameters: {'category': HomeController.groupedIptv[HomeController().selected]!.elementAt(index).name!});
            },
            child: Container(
              decoration: BoxDecoration(
                color: selectedIndex == index ? Colors.grey.shade800 : Colors.transparent,
                border: Border.all(
                  color: selectedIndex == index ? Colors.yellow.shade300 : Colors.transparent,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.live_tv, color: selectedIndex == index ? Colors.yellow[300] : Colors.white),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
          ),
        );
      },
    );
  }


  void searchResult(String query) {
    setState(() {
      searchResults = []; // Initialize as an empty list
      HomeController.groupedIptv.forEach((group, channels) {
        searchResults.addAll(
          channels.where((item) => item.name != null && item.name!.toLowerCase().contains(query.toLowerCase())).toList(),
        );
      });
    });

    print('Search performed');
  }
}
