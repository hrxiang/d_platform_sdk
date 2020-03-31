import 'package:d_platform_sdk/d_platform_sdk.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DPlatformSdk.listener((data) {
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
      if (data is Map) {
        if ("login" == data['action']) {
          //
        }
      }
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
            RaisedButton(
              onPressed: () {
                DPlatformSdk.call(
                  "dflatformdemo1",
                  "login",
                  "xxx.xxx.xxx",
                  params: {},
                  downloadUrl: "www.360.com",
                );
              },
              child: Text('获取token登录'),
            )
          ],
        ),
      ),
    );
  }
}
