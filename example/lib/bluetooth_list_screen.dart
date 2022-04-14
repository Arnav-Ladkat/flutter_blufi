import 'dart:async';
import 'dart:convert';

import 'package:blufi_plugin/blufi_plugin.dart';
import 'package:blufi_plugin_example/main.dart';
import 'package:blufi_plugin_example/wifi_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

class BluetoothListScreen extends StatefulWidget {
  const BluetoothListScreen({Key key}) : super(key: key);

  @override
  State<BluetoothListScreen> createState() => _BluetoothListScreenState();
}

class _BluetoothListScreenState extends State<BluetoothListScreen> {
  String contentJson = 'Unknown';
  List<BluetoothItem> bleData = List.empty(growable: true);
  Map<String, dynamic> scanResult = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();
    FlutterBugfender.log("Enter into ${this.runtimeType}");
    initPlatformState();

    BlufiPlugin.instance.onMessageReceived(
      successCallback: (String data) {
        print("success data: $data");
        setState(() {
          contentJson = data;
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData.containsKey('key')) {
            String key = mapData['key'];
            if (key == 'ble_scan_result') {
              Map<String, dynamic> peripheral = mapData['value'];

              String address = peripheral['address'];
              String name = peripheral['name'];
              String rssi = peripheral['rssi'];
              final data = BluetoothItem(address, name, rssi);
              if (!scanResult.containsKey(address)) {
                bleData.add(data);
                FlutterBugfender.log(
                    "Adding Device to list Name: ${data.name} Address:${data.address}");
              }
              print("Name $name");
              scanResult[address] = name;
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
        title: const Text('Bluetooth List'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              await BlufiPlugin.instance
                  .scanDeviceInfo(filterString: 'PowerX')
                  .then(
                    (value) => print(
                      value.toString(),
                    ),
                  );
            },
            child: Text('Scan'),
          ),
          TextButton(
            onPressed: () async {
              stopScanning();
            },
            child: Text('Stop Scan'),
          ),
          TextButton(
            onPressed: () async {
              await BlufiPlugin.instance.isConnected().then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Connected $value"),
                      ),
                    ),
                  );
            },
            child: Text('Check Connection status'),
          ),
          Text(contentJson ?? ''),
          if (bleData.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: bleData.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = bleData[index];
                  return ListTile(
                    leading: Text(item.name ?? ''),
                    subtitle: Text(item.address ?? ''),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        stopScanning();
                        print("Connecting to ${item.address}");
                        FlutterBugfender.log(
                            "Connecting to ${item.name} Address:${item.address}");
                        await BlufiPlugin.instance
                            .connectPeripheral(
                          peripheralAddress: item.address,
                        )
                            .then(
                          (value) {
                            FlutterBugfender.log(
                                "Connecting value $value of ${item.name} Address:${item.address}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Connect $value to ${item.address}"),
                              ),
                            );
                          },
                        );
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WiFiListScreen(),
                          ),
                        );
                      },
                      child: Text('Connect'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> stopScanning() async {
    await BlufiPlugin.instance.stopScan();
    FlutterBugfender.log("Stoppnig the bluetooth scan");
  }
}
