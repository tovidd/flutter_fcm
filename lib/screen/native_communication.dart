import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fcm/main.dart';

class NativeCommunication extends StatefulWidget implements Attribute {
  @override
  _NativeCommunicationState createState() => _NativeCommunicationState();

  @override
  get data => this;

  @override
  String get routeName => '/native-communication';
}

class _NativeCommunicationState extends State<NativeCommunication> {
  String _message;
  static const platform = const MethodChannel('flutter/tovidd');
  TextEditingController _nameController;
  String _batteryLevel;

  @override
  void initState() {
    _message = 'Hello world, from Flutter code';
    _nameController = TextEditingController();
    _batteryLevel = 'Unknown battery level';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter to Native Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "Input your name"),
              ),
            ),
            RaisedButton(
              child: Text('Tap Me'),
              onPressed: () async {
                try {
                  String name = _nameController.text;
                  _message = await platform.invokeMethod(
                    'greetingFromNativeCode',
                    {'name': name},
                  );
                } on PlatformException catch (e) {
                  _message = 'Failed to invoke: ${e.message}';
                }
                setState(() {});
              },
            ),
            Text(_message),
            SizedBox(height: 20),
            RaisedButton(
              child: Text('battery level ?'),
              onPressed: _getBatteryLevel,
            ),
            Text(_batteryLevel),
          ],
        ),
      ),
    );
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result%';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }
}
