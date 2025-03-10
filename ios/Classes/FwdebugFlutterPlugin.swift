import Flutter
import UIKit
import FWDebug

public class FwdebugFlutterPlugin: NSObject, FlutterPlugin {
  private static var registeredEntries: [String] = []
  private static var methodChannel: FlutterMethodChannel?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fwdebug_flutter", binaryMessenger: registrar.messenger())
    methodChannel = channel
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
      result(nil)
    case "systemLog":
      if let message = call.arguments as? String, !message.isEmpty {
        FWDebugManager.sharedInstance().systemLog(message)
      }
      result(nil)
    case "customLog":
      if let message = call.arguments as? String, !message.isEmpty {
        FWDebugManager.sharedInstance().customLog(message)
      }
      result(nil)
    case "registerEntry":
      if let name = call.arguments as? String, !name.isEmpty,
         !FwdebugFlutterPlugin.registeredEntries.contains(name) {
        FwdebugFlutterPlugin.registeredEntries.append(name)
        
        FWDebugManager.sharedInstance().registerEntry(name) { viewController in
          viewController.dismiss(animated: true) {
            FwdebugFlutterPlugin.methodChannel?.invokeMethod("registerEntryCallback", arguments: name)
          }
        }
      }
      result(nil)
    case "openUrl":
      FWDebugManager.sharedInstance().openUrl = { url in
        var success = false
        FwdebugFlutterPlugin.methodChannel?.invokeMethod("openUrlCallback", arguments: url, result: { result in
          success = result as? Bool ?? false
        })
        return success
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
