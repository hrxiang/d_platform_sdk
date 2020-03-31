import 'dart:async';

import 'package:flutter/services.dart';

typedef OnDPlatformSDKCallback = Function();

class DPlatformSdk {
  static const MethodChannel _channel = const MethodChannel('d_platform_sdk');

  /// 回传数据
  static void listener(handler(dynamic arguments)) {
    _channel.setMethodCallHandler((MethodCall call) {
      if ("listener" == call.method && null != handler) {
        handler(call.arguments);
      }
      return null;
    });
    // app第一次启动，原生主动调用invoke方法时，flutter还没有注册监听，所以需要主动获取一次数据
    _channel.invokeMethod("listener");
  }

  /// 唤起scheme
  static void call(
    String urlString,
    String action,
    String packageName, {
    Map<String, String> params = const <String, String>{},
    String downloadUrl,
  }) {
    // 区分当前事件类型
    params.putIfAbsent("action", () => action);
    // 被唤起的应用的scheme
    params.putIfAbsent("urlString", () => urlString);
    // 被唤起的应用的包名
    params.putIfAbsent("packageName", () => packageName);
    // 启动scheme
    _channel.invokeMethod("call", params);
  }
}
