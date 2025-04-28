import Flutter
import UIKit
#if DEBUG
import FWDebug
#endif

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
      #if DEBUG
      if let visible = call.arguments as? Bool {
        visible ? FWDebugManager.sharedInstance().show() : FWDebugManager.sharedInstance().hide()
      } else {
        FWDebugManager.sharedInstance().toggle()
      }
      #endif
      result(nil)
    case "systemLog":
      #if DEBUG
      if let message = call.arguments as? String, !message.isEmpty {
        FWDebugManager.sharedInstance().systemLog(message)
      }
      #endif
      result(nil)
    case "customLog":
      #if DEBUG
      if let message = call.arguments as? String, !message.isEmpty {
        FWDebugManager.sharedInstance().customLog(message)
      }
      #endif
      result(nil)
    case "registerEntry":
      #if DEBUG
      if let name = call.arguments as? String, !name.isEmpty,
         !FwdebugFlutterPlugin.registeredEntries.contains(name) {
        FwdebugFlutterPlugin.registeredEntries.append(name)
        
        FWDebugManager.sharedInstance().registerEntry(name) { viewController in
          viewController.dismiss(animated: true) {
            FwdebugFlutterPlugin.methodChannel?.invokeMethod("registerEntryCallback", arguments: name)
          }
        }
      }
      #endif
      result(nil)
    case "openUrl":
      #if DEBUG
      FWDebugManager.sharedInstance().openUrl = { url in
        FwdebugFlutterPlugin.methodChannel?.invokeMethod("openUrlCallback", arguments: url)
        return true
      }
      #endif
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
