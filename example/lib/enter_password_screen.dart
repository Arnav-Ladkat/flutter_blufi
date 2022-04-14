import 'package:blufi_plugin/blufi_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

class EnterPasswordScreen extends StatefulWidget {
  final String wifiName;

  const EnterPasswordScreen(this.wifiName, {Key key}) : super(key: key);

  @override
  State<EnterPasswordScreen> createState() => _EnterPasswordScreenState();
}

class _EnterPasswordScreenState extends State<EnterPasswordScreen> {
  TextEditingController _wifiNameController, _pwdController;
  bool isHidden = true;
  @override
  void initState() {
    super.initState();
    _wifiNameController = TextEditingController();
    _pwdController = TextEditingController();
    FlutterBugfender.log("Enter into ${this.runtimeType}");
    _wifiNameController.text = widget.wifiName;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            SizedBox(
              height: 10.0,
            ),
            TextFormField(
              controller: _pwdController,
              obscureText: isHidden,
              decoration: InputDecoration(
                labelText: 'WiFi Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isHidden = !isHidden;
                    });
                  },
                  icon: Icon(
                    isHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
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
                    FlutterBugfender.log("Send WiFi Credentials ${value}");
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
    );
  }
}
