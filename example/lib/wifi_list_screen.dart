import 'dart:convert';

import 'package:blufi_plugin/blufi_plugin.dart';
import 'package:blufi_plugin_example/enter_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

class WiFiListScreen extends StatefulWidget {
  const WiFiListScreen({Key key}) : super(key: key);

  @override
  State<WiFiListScreen> createState() => _WiFiListScreenState();
}

class _WiFiListScreenState extends State<WiFiListScreen> {
  String contentJson = 'Unknown';
  List<WiFiItem> wifiList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    FlutterBugfender.log("Enter into ${this.runtimeType}");
    initPlatformState();
    BlufiPlugin.instance.onMessageReceived(
      successCallback: (String data) {
        print("success data: $data");
        FlutterBugfender.log(
            "onMessageReceived in WiFilist screen & data is $data");
        setState(() {
          contentJson = data;
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData.containsKey('key')) {
            String key = mapData['key'];
            if (key == 'wifi_info') {
              Map<String, dynamic> peripheral = mapData['value'];

              String address = peripheral['address'];
              String name = peripheral['ssid'];
              String rssi = peripheral['rssi'];
              final data = WiFiItem(address, name, rssi);

              wifiList.add(data);
              FlutterBugfender.log(
                  "Adding Device to WiFiItem list Name: ${data.name} Address:${data.address} rssi:${data.rssi}");
            }
          }
        });
      },
      errorCallback: (String error) {
        debugPrint("errorCallback $error");
      },
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await BlufiPlugin.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi List'),
      ),
      floatingActionButton: IconButton(
        onPressed: () => BlufiPlugin.instance.requestDeviceScan(),
        icon: Icon(Icons.search),
      ),
      body: wifiList.length > 0
          ? ListView.builder(
              itemCount: wifiList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => ListTile(
                leading: Text(wifiList[index].name ?? 'UNKNOWN'),
                trailing: TextButton(
                  child: Text('Connect'),
                  onPressed: () {
                    showPasswordDialog(wifiList[index].name);
                  },
                ),
              ),
            )
          : Text("Press on search to get wifi list"),
    );
  }

  showPasswordDialog(String wifiName) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.white,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        FlutterBugfender.log("Showing password dialog");
        return EnterPasswordScreen(wifiName);
      },
    );
  }
}

class WiFiItem {
  String address, name;
  String rssi;

  WiFiItem(this.address, this.name, this.rssi);
}
