import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iptv/helper/shared_pref.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:iptv/screen/home/controller/home_controller.dart';
import 'package:iptv/screen/home/tv_os/category_widget.dart';
import 'package:iptv/screen/home/widget/category_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsScreen extends StatefulWidget {

  @override
  _SettingsScreenState createState() => _SettingsScreenState();

}

class _SettingsScreenState extends State<SettingsScreen> {


  final TextEditingController tvName = TextEditingController();
  final TextEditingController tvAddress = TextEditingController();
  List<Map<String, String>> savedData = [];
  final SharedPref _sharedPref = SharedPref();
  String? selectedTV;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Map<String, String>> data = await _sharedPref.loadData();
    String? loadedSelectedTV = await _sharedPref.loadSelectedTV();
    setState(() {
      savedData = data;
      selectedTV = loadedSelectedTV;
    });
  }

  Future<void> _saveData() async {
    String name = tvName.text;
    String url = tvAddress.text;

    if (name.isNotEmpty && url.isNotEmpty) {
      setState(() {
        savedData.add({"name": name, "url": url});
      });

      await _sharedPref.saveData(savedData);
      tvName.clear();
      tvAddress.clear();
    }
  }

  Future<void> _removeData(int index) async {
    setState(() {
      savedData.removeAt(index);
    });
    await _sharedPref.removeDataAt(index);
  }


  Future<void> _saveSelectedTv(String address) async {
    await _sharedPref.saveSelectedTV(address);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("TV Adresi : $address olarak güncellendi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ayarlar"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 500,
                child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'IPTV Adı',
                              prefixIcon: Icon(Icons.tv),
                              border: InputBorder.none,
                            ),
                            controller: tvName,
                          ),
                          const Divider(height: 15),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'IPTV Adresi',
                              prefixIcon: Icon(Icons.http_outlined),
                              border: InputBorder.none,
                            ),
                            controller: tvAddress,
                          ),
                          SizedBox(height: 15),
                          FilledButton.tonal(
                            onPressed: _saveData,
                            child: const Text('Ekle'),
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Card(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => Divider(height: 5, color: Colors.white),
                    itemCount: savedData.length,
                    itemBuilder: (context, index) {
                      bool isSelected = savedData[index]["url"] == selectedTV;
                      return Dismissible(
                        key: Key(savedData[index]["name"] ?? ""),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (savedData[index]["url"] == selectedTV) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Kullanılan Sağlayıcı Silinemez!')),
                            );
                            return false;
                          }
                          return true;
                        },
                        onDismissed: (direction) async {
                          _removeData(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("IPTV silindi")),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            savedData[index]["name"] ?? "",
                            style: TextStyle(
                                color: isSelected ? Colors.yellow[300] : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          ),
                          subtitle: Text(
                            savedData[index]["url"] ?? "",
                            style: TextStyle(
                                color: isSelected ? Colors.yellow[300] : Colors.white,
                                fontSize: 13
                            ),
                          ),
                          onTap: () => _saveSelectedTv(savedData[index]["url"]!),
                        ),
                      );
                    },
                  ),
                ),
              )
            ),
          ],
        )
    );
  }
  



}