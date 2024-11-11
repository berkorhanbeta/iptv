import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/helper/page_navigation.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:iptv/screen/home/controller/home_controller.dart';

class ChannelWidget extends StatefulWidget {
  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();

}

class _ChannelWidgetState extends State<ChannelWidget> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: list(),
        )
    );
  }


  list(){

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.transparent),
      itemCount: HomeController.groupedIptv[HomeController().selected]!.length,
      itemBuilder: (context, int index) {
        IptvModel? channel = HomeController.groupedIptv[HomeController().selected]!.elementAt(index);

        return GestureDetector(
            onTap: () => {
              Get.toNamed('${PageNavigation.player}', parameters: {'channel': jsonEncode(channel)})
            },
            child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: MediaQuery.of(context).size.width > 900 ?
                  Row(
                    children: [
                      channel.logo == null ?
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/5753/5753212.png',
                        height: 200,
                        width: 200,
                      ) : Image.network(
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
                  ) :
                  Column(
                    children: [
                      channel.logo == null ?
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/5753/5753212.png',
                        height: 200,
                        width: 200,
                      ) : Image.network(
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
                      SizedBox(height: 10)
                    ],
                  ),
                )
            )
        );
      },
    );

  }

}