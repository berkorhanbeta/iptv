import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iptv/helper/page_navigation.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:iptv/screen/home/controller/home_controller.dart';

class ChannelWidgetTV extends StatefulWidget {
  final String? category;
  ChannelWidgetTV({super.key, required this.category});

  @override
  _ChannelWidgetTVState createState() => _ChannelWidgetTVState();
}

class _ChannelWidgetTVState extends State<ChannelWidgetTV> {
  late List<FocusNode> focusNodes;
  late ScrollController scrollController;
  String? title;

  @override
  void initState() {
    super.initState();
    title = Get.parameters['category'];
    scrollController = ScrollController();
    focusNodes = List.generate(
      HomeController.groupedIptv[HomeController().selected]!.length,
          (index) => FocusNode(),
    );
    focusNodes.first.requestFocus(); // Focus the first item initially
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToIndex(int index) async {
    double itemHeight = 220.0; // Adjust this value based on the actual height of each item

    // Calculate the offset for the current index
    double offset = index * itemHeight;

    // Ensure the scroll doesn't go beyond the content
    if (offset < scrollController.position.maxScrollExtent) {
      await scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${title}')),
      body: Container(
        child: list(),
      ),
    );
  }

  Widget list() {
    return FocusTraversalGroup(
      child: ListView.builder(
        controller: scrollController,
        itemCount: HomeController.groupedIptv[HomeController().selected]!.length,
        itemBuilder: (context, int index) {
          IptvModel? channel = HomeController.groupedIptv[HomeController().selected]!.elementAt(index);

          return Focus(
            focusNode: focusNodes[index],
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _scrollToIndex(index);
                });
              }
            },
            onKey: (FocusNode node, RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown && index < focusNodes.length - 1) {
                  focusNodes[index + 1].requestFocus();
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && index > 0) {
                  focusNodes[index - 1].requestFocus();
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                  Get.toNamed('${PageNavigation.player}', parameters: {'channel': jsonEncode(channel)});
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: () => {
                Get.toNamed('${PageNavigation.player}', parameters: {'channel': jsonEncode(channel)})
              },
              child: Card(
                margin: EdgeInsets.all(15),
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: focusNodes[index].hasFocus ? Colors.yellow[300]! : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MediaQuery.of(context).size.width > 900
                      ? Row(
                    children: [
                      channel.logo == null
                          ? Image.network(
                        'https://cdn-icons-png.flaticon.com/512/5753/5753212.png',
                        height: 200,
                        width: 200,
                      )
                          : Image.network(
                        channel.logo!,
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          channel.name ?? 'Bilinmiyor',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                      : Column(
                    children: [
                      channel.logo == null
                          ? Image.network(
                        'https://cdn-icons-png.flaticon.com/512/5753/5753212.png',
                        height: 200,
                        width: 200,
                      )
                          : Image.network(
                        channel.logo!,
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(height: 5),
                      Text(
                        channel.name ?? 'Bilinmiyor',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

