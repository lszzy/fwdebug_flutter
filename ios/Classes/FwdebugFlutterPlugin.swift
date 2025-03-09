import Flutter
import UIKit
import FWDebug

public class FwdebugFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fwdebug_flutter", binaryMessenger: registrar.messenger())
    let instance = FwdebugFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "toggle":
      if let visible = call.arguments as? Bool {
        visible ? FWDebugManager.sharedInstance().show() : FWDebugManager.sharedInstance().hide()
      } else {
        FWDebugManager.sharedInstance().toggle()
      }
      result(true)
    case "systemLog":
      if let message = call.arguments as? String, !message.isEmpty {
        FWDebugManager.sharedInstance().systemLog(message)
        result(true)
      } else {
        result(false)
      }
    case "customLog":
      if let message = call.arguments as? String, !message.isEmpty {
        FWDebugManager.sharedInstance().customLog(message)
        result(true)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
