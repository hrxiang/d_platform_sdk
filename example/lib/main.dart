import 'dart:convert';

import 'package:d_platform_sdk/d_platform_sdk.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = "Unknow";

  @override
  void initState() {
    super.initState();
    DPlatformSdk.listener((data) {
      print('=================result===========${data.runtimeType}======');
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
      setState(() {
        result = jsonEncode(data);
        print('=================action===========${data["params"]}======');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('d platform plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Text(result),
            RaisedButton(
              onPressed: () {
                DPlatformSdk.call(
                  scheme: "org.dplatform.game.cs.org.platform.demo.game://",
                  action: "login",
                  androidPackageName: "org.dplatform.d_platform_sdk_test",
                  params: {"userId": "1234567"},
                  downloadUrl: "www.360.com",
                );
              },
              child: Text('获取token登录'),
            ),
          ],
        ),
      ),
    );
  }
}
