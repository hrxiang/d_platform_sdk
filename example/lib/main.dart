import 'package:flutter/material.dart';
import 'package:flutter_dplatform_sdk/d_platform_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = "Unknow";
  DPlatformSdk _sdk = DPlatformSdk(site: "HT", evn: DPlatformEvn.DEBUG);

  @override
  void initState() {
    super.initState();

    // 数据回传监听
    _sdk.listener((data) {
      print('=================result===========${data.runtimeType}======$data');
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
      setState(() {
        result = data;
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

              // 发起支付
              onPressed: () {
                _sdk.pay(
                  model: PayModel(
                    orderSn: "9527",
                    outUid: "0099991",
                    channelNo: "10001",
//                    token: "000001",
//                    attrs: {
//                      "key0": "value0",
//                      "key1": "value1",
//                    },
                  ),
                );
              },
              child: Text('去充值'),
            ),
          ],
        ),
      ),
    );
  }
}
