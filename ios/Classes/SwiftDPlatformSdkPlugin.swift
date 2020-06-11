import Flutter
import UIKit

public class SwiftDPlatformSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "d_platform_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftDPlatformSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if "init" == call.method {
            handleInit(call, result: result)
        } else if "call" == call.method {
            handleCall(call, result: result)
        } else {
            print("Unknown flutter call: \(call.method)")
        }
    }
    
    func handleInit(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            var args = call.arguments as? [String : Any]
        else {
            print("Invalid flutter call.")
            return
        }
        guard
            let site = args["site"] as? String,
            let env = args["env"] as? Int
        else {
            print("The required parameters are missing.")
            return
        }
        
        var envVal = Environment.prod
        if 0 == env { envVal = Environment.debug }
        else if 1 == env { envVal = Environment.test }
        else if 2 == env { envVal = Environment.stage }
        DPlatformApi.registerApp(withEnv: envVal, station: site)
    }
    
    func handleCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            var args = call.arguments as? [String : Any]
        else {
            print("Invalid flutter call.")
            return
        }
        guard
            let action = args["action"] as? String,
            let orderSn = args["orderSn"] as? String
        else {
            print("The required parameters are missing.")
            return
        }
        guard
            "pay" != action
        else {
            print("Unknown action: \(action)")
            return
        }

        let token = args["token"] as? String
        let outUid = args["outUid"] as? String
        let channelNo = (args["channelNo"] as? String) ?? ""
        if outUid != nil {
            DPlatformApi.sendPayReq(withOrderSn: orderSn, outUid: outUid, channelNo: channelNo, extraParams: args)
        } else token != nil {
            DPlatformApi.sendPayReq(withOrderSn: orderSn, token: token, channelNo: channelNo)
        } else {
            print("The required parameters are missing: token&outUid")
        }
    }
}
