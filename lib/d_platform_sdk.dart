import 'package:flutter/services.dart';

class DPlatformSdk {
  static const MethodChannel _channel = const MethodChannel('d_platform_sdk');

  /// 其他app唤起当前app传递数据
  static void listener(handler(Map<String, String> arguments)) {
    _channel.setMethodCallHandler((MethodCall call) {
      if ("listener" == call.method &&
          null != handler &&
          call.arguments is Map) {
        handler(call.arguments);
      }
      return null;
    });
    // 首次启动app
    _channel.invokeMethod("listener");
  }

  /// 当前唤起其他app获取数据
  static void call(
    String urlString,
    String action,
    String packageName, {
    Map<String, String> params = const <String, String>{},
    String downloadUrl,
  }) {
    // 区分当前事件类型
    params?.putIfAbsent("action", () => action);
    // 被唤起的应用的scheme
    params?.putIfAbsent("urlString", () => urlString);
    // 被唤起的应用的包名
    params?.putIfAbsent("packageName", () => packageName);
    // 被唤起的应用的下载地址
    params?.putIfAbsent("downloadUrl", () => downloadUrl);
    // 启动scheme
    _channel.invokeMethod("call", params);
  }
}
