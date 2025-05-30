import Flutter
import UIKit

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
    case "isEnabled":
      result(debugManager != nil)
    case "toggle":
      if let visible = call.arguments as? Bool {
        visible ? debugManager?.objcShow() : debugManager?.objcHide()
      } else {
        debugManager?.objcToggle()
      }
      result(nil)
    case "systemLog":
      if let message = call.arguments as? String, !message.isEmpty {
        debugManager?.objcSystemLog(message)
      }
      result(nil)
    case "customLog":
      if let message = call.arguments as? String, !message.isEmpty {
        debugManager?.objcCustomLog(message)
      }
      result(nil)
    case "registerEntry":
      if let name = call.arguments as? String, !name.isEmpty,
         !FwdebugFlutterPlugin.registeredEntries.contains(name) {
        FwdebugFlutterPlugin.registeredEntries.append(name)
        
        debugManager?.objcRegisterEntry(name) { viewController in
          viewController.dismiss(animated: true) {
            FwdebugFlutterPlugin.methodChannel?.invokeMethod("registerEntryCallback", arguments: name)
          }
        }
      }
      result(nil)
    case "openUrl":
      debugManager?.objcOpenUrl = { url in
        FwdebugFlutterPlugin.methodChannel?.invokeMethod("openUrlCallback", arguments: url)
        return true
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private var debugManager: (NSObject & ObjCDebugManagerBridge)? {
    let debugClass: AnyClass? = NSClassFromString("FWDebugManager")
    return debugClass?.objcSharedInstance()
  }
}

@objc protocol ObjCDebugManagerBridge {
  @objc(sharedInstance)
  static func objcSharedInstance() -> NSObject & ObjCDebugManagerBridge

  @objc(openUrl)
  var objcOpenUrl: ((String) -> Bool)? { get set }
  
  @objc(show)
  func objcShow()
  
  @objc(hide)
  func objcHide()
  
  @objc(toggle)
  func objcToggle()
  
  @objc(systemLog:)
  func objcSystemLog(_ message: String)
  
  @objc(customLog:)
  func objcCustomLog(_ message: String)
  
  @objc(registerEntry:actionBlock:)
  func objcRegisterEntry(_ entryName: String, actionBlock: @escaping (UITableViewController) -> Void)
}
