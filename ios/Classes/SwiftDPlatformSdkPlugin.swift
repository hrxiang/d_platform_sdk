import Flutter
import UIKit

public class SwiftDPlatformSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "d_platform_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftDPlatformSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            "call" == call.method,
            var args = call.arguments as? [String : Any]
        else {
            print("Invalid flutter call.")
            return
        }
        guard
            let action = args["action"] as? String,
            let orderSn = args["orderSn"] as? String,
            let channelNo = args["channelNo"] as? String
        else {
            print("The required parameters are missing.")
            return
        }
        
        if "pay" != action {
            print("Unknown action: \(action)")
            return
        }

        let token = args["token"] as? String
        let outUid = args["outUid"] as? String
        if outUid != nil {
            
        } else {
            
        }
    }
}
