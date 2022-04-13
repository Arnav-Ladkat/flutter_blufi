import 'dart:async';
import 'dart:convert';

import 'package:blufi_plugin/blufi_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

void main() {
  FlutterBugfender.init(
    "4AglrhenGCgYEJKG0uCxZMeFPEwyiAdU",
    enableAndroidLogcatLogging: true,
  );

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
  }, (Object error, StackTrace stack) async {
    FlutterBugfender.error(error);
    FlutterBugfender.error(stack.toString());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String contentJson = 'Unknown';
  List<ListData> bleData = List.empty(growable: true);
  Map<String, dynamic> scanResult = Map<String, dynamic>();

  TextEditingController _wifiNameController, _pwdController;

  @override
  void initState() {
    super.initState();
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
              final data = ListData(address, name, rssi);
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
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              await BlufiPlugin.instance.scanDeviceInfo().then(
                    (value) => print(
                      value.toString(),
                    ),
                  );
            },
            child: Text('Scan'),
          ),
          TextButton(
            onPressed: () async {
              await BlufiPlugin.instance.stopScan();
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
          /*TextButton(
                onPressed: () async {
                  await BlufiPlugin.instance.connectPeripheral(
                      peripheralAddress: scanResult.keys.first);
                },
                child: Text('Connect Peripheral')),
            TextButton(
                onPressed: () async {
                  await BlufiPlugin.instance.requestCloseConnection();
                },
                child: Text('Close Connect')),
           TextButton(
              onPressed: () async {
                await BlufiPlugin.instance.configProvision(
                  username: _wifiNameController.text.trim(),
                  password: _pwdController.text.trim(),
                );
              },
              child: Text('Config Provision'),
            ),
            TextButton(
              onPressed: () async {
                String command = '12345678';
                await BlufiPlugin.instance.postCustomData(command);
              },
              child: Text('Send Custom Data'),
            ),*/
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
                      },
                      child: Text('Connect'),
                    ),
                  );
                },
              ),
            ),
          if (bleData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: _wifiNameController,
                      decoration: InputDecoration(
                        labelText: 'WiFi Name',
                      ),
                    ),
                    TextFormField(
                      controller: _pwdController,
                      decoration: InputDecoration(
                        labelText: 'WiFi Password',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        FlutterBugfender.log(
                            "Send WiFi Credentials WiFi ${_wifiNameController.text.trim()} pwd:${_pwdController.text.trim()}");
                        await BlufiPlugin.instance
                            .configProvision(
                          username: _wifiNameController.text.trim(),
                          password: _pwdController.text.trim(),
                        )
                            .then(
                          (value) {
                            FlutterBugfender.log(
                                "Send WiFi Credentials ${value}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Send WiFi Credentials ${value}"),
                              ),
                            );
                          },
                        );
                      },
                      child: Text('Send WiFi Credentials'),
                    ),
                    SizedBox(
                      height: 20.0,
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ListData {
  String address, name;
  String rssi;

  ListData(this.address, this.name, this.rssi);
}
