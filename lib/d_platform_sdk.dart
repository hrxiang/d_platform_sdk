import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DPlatformSdk {
  static const MethodChannel _channel = const MethodChannel('d_platform_sdk');
  final String site;
  final DPlatformEvn evn;

  DPlatformSdk({
    @required this.site,
    this.evn = DPlatformEvn.RELEASE,
  })  : assert(null != site),
        assert(null != evn) {
    _channel.invokeMethod("init", {"site": site, "env": evn.index});
  }

  /// 数据回传监听
  void listener(handler(dynamic arguments)) {
    _channel.setMethodCallHandler((MethodCall call) {
      if ("listener" == call.method && null != handler) {
        return handler(call.arguments);
      }
      return null;
    });
    // 首次启动app
    _channel.invokeMethod("listener");
  }

  /// 自定义支付
  void pay({@required PayModel model}) => call(params: model.params);

  /// 通用方式
  void call({Map<String, dynamic> params}) async {
    _channel.invokeMethod("call", params);
  }
}

enum DPlatformEvn {
  DEBUG, //联调(index = 0)
  TEST, //测试(index = 1)
  PRO, //预发(index = 2)
  RELEASE, //生产(index = 3)
}

class PayModel extends BaseModel {
  final String token;
  final String orderSn;

//  final String outUid;
  final String channelNo;
  final Map<String, dynamic> attrs;

  PayModel({
    @required this.channelNo,
    @required this.orderSn,
    @required this.token,
//    @required this.outUid,
    this.attrs,
  })  : assert(null != channelNo),
        assert(null != orderSn),
        assert(null != token),
//        assert(null != outUid),
        super('pay') {
    params.addAll({
      "token": token,
      "orderSn": orderSn,
      "action": "pay",
//      "outUid": outUid,
      "channelNo": channelNo,
    });
    params.addAll(attrs ?? {});
  }
}

class BaseModel {
  final String action;
  final Map<String, dynamic> params = <String, dynamic>{};

  BaseModel(this.action) : assert(null != action) {
    params.addAll({"action": action});
  }
}
