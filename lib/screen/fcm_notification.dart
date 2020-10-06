import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMNotification extends StatefulWidget implements Attribute {
  @override
  _FCMNotificationState createState() => _FCMNotificationState();

  @override
  // TODO: implement routeName
  String get routeName => '/fcm-notification';

  @override
  // TODO: implement data
  get data => FCMNotification();
}

class _FCMNotificationState extends State<FCMNotification> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  final firebaseMessaging = FirebaseMessaging();
  final controllerTopic = TextEditingController();
  bool isSubscribed = false;
  String token = '';
  static String dataName = '';
  static String dataAge = '';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessage: $message');
    if (message.containsKey('data')) {
      String name = '';
      String age = '';
      if (Platform.isIOS) {
        name = message['name'];
        age = message['age'];
      } else if (Platform.isAndroid) {
        var data = message['data'];
        name = data['name'];
        age = data['age'];
      }
      dataName = name;
      dataAge = age;
      debugPrint('onBackgroundMessage: name: $name & age: $age');
    }
    return null;
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('onMessage: $message');
        getDataFcm(message);
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (Map<String, dynamic> message) async {
        debugPrint('onResume: $message');
        getDataFcm(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('onLaunch: $message');
        getDataFcm(message);
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      debugPrint('Settings registered: $settings');
    });
    firebaseMessaging.getToken().then((token) => setState(() {
          this.token = token;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('token: $token');
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Flutter FCM'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'TOKEN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(token),
            Divider(thickness: 1),
            Text(
              'TOPIC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: controllerTopic,
              enabled: !isSubscribed,
              decoration: InputDecoration(
                hintText: 'Enter a topic',
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Subscribe'),
                    onPressed: isSubscribed
                        ? null
                        : () {
                            String topic = controllerTopic.text;
                            if (topic.isEmpty) {
                              scaffoldState.currentState.showSnackBar(SnackBar(
                                content: Text('Topic invalid'),
                              ));
                              return;
                            }
                            firebaseMessaging.subscribeToTopic(topic);
                            setState(() {
                              isSubscribed = true;
                            });
                          },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: RaisedButton(
                    child: Text('Unsubscribe'),
                    onPressed: !isSubscribed
                        ? null
                        : () {
                            String topic = controllerTopic.text;
                            firebaseMessaging.unsubscribeFromTopic(topic);
                            setState(() {
                              isSubscribed = false;
                            });
                          },
                  ),
                ),
              ],
            ),
            Divider(thickness: 1),
            Text(
              'DATA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildWidgetTextDataFcm(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetTextDataFcm() {
    if (dataName == null ||
        dataName.isEmpty ||
        dataAge == null ||
        dataAge.isEmpty) {
      return Text('Your data FCM is here');
    } else {
      return Text('Name: $dataName & Age: $dataAge');
    }
  }

  void getDataFcm(Map<String, dynamic> message) {
    String name = '';
    String age = '';
    if (Platform.isIOS) {
      name = message['name'];
      age = message['age'];
    } else if (Platform.isAndroid) {
      var data = message['data'];
      name = data['name'];
      age = data['age'];
    }
    if (name.isNotEmpty && age.isNotEmpty) {
      setState(() {
        dataName = name;
        dataAge = age;
      });
    }
    debugPrint('getDataFcm: name: $name & age: $age');
    _showNotification();
  }

  Future<void> _showNotification() async {
    print('show notification');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }
}
