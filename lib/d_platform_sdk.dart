import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DPlatformSdk {
  static const MethodChannel _channel = const MethodChannel('d_platform_sdk');

  /// 其他app唤起当前app传递数据
  static void listener(handler(dynamic arguments)) {
    _channel.setMethodCallHandler((MethodCall call) {
      if ("listener" == call.method && null != handler) {
        return handler(call.arguments);
      }
      return null;
    });
    // 首次启动app
    _channel.invokeMethod("listener");
  }

  /// 当前唤起其他app获取数据
  static void call({
    @required String scheme,
    @required String action,
    String androidPackageName,
    String iosBundleId,
    Map<String, String> params = const <String, String>{},
    String downloadUrl,
  }) async {
    if (null == scheme) throw Exception("scheme is null!");
    if (null == action) throw Exception("action is null!");
    // 被唤起的应用的scheme
    params?.putIfAbsent("scheme", () => _buildFullScheme(scheme));
    // 区分当前事件类型
    params?.putIfAbsent("action", () => action);
    // 被唤起的应用的包名
    params?.putIfAbsent("androidPackageName", () => androidPackageName);
    // 被唤起的应用的包名
    params?.putIfAbsent("iosBundleId", () => iosBundleId);
    // 被唤起的应用的下载地址
    params?.putIfAbsent("downloadUrl", () => downloadUrl);
    // 启动scheme
    _channel.invokeMethod("call", params);
  }

  static String _buildFullScheme(String scheme) {
    return "${scheme.contains("://") ? scheme : "$scheme://do"}";
  }
}
