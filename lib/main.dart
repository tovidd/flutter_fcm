import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm/screen/fcm_notification.dart';
import 'package:flutter_fcm/screen/native_communication.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Attribute> atts = [
      FCMNotification(),
      NativeCommunication(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('App'),
      ),
      backgroundColor: Colors.white70,
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: atts.length,
        separatorBuilder: (c, i) => SizedBox(height: 5),
        itemBuilder: (c, i) => row(context, atts[i]),
      ),
    );
  }

  Widget row(BuildContext context, Attribute att) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => att.data));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 20,
            color: Colors.green,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10),
              height: 40,
              alignment: Alignment.centerLeft,
              color: Colors.green[100],
              child: Text(att.routeName),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class Attribute<T> {
  String get routeName;
  T get data;
}
