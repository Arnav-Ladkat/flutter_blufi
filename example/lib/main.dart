import 'dart:async';

import 'package:blufi_plugin_example/bluetooth_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBugfender.init(
    "4AglrhenGCgYEJKG0uCxZMeFPEwyiAdU",
    enableAndroidLogcatLogging: true,
  );

  runZonedGuarded(() async {
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
      debugShowCheckedModeBanner: false,
      home: BluetoothListScreen(),
    );
  }
}

class BluetoothItem {
  String address, name;
  String rssi;

  BluetoothItem(this.address, this.name, this.rssi);
}
