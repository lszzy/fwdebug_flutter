import 'package:flutter/services.dart';

import 'fwdebug_flutter_platform_interface.dart';

class MethodChannelFwdebugFlutter extends FwdebugFlutterPlatform {
  Map<String, VoidCallback> registerEntryCallbacks = {};
  final methodChannel = const MethodChannel('fwdebug_flutter');

  MethodChannelFwdebugFlutter() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'registerEntryCallback':
          final name = call.arguments as String? ?? '';
          registerEntryCallbacks[name]?.call();
          return;
        default:
          throw MissingPluginException();
      }
    });
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> registerEntry(String name, VoidCallback callback) async {
    registerEntryCallbacks[name] = callback;
    return await methodChannel.invokeMethod('registerEntry', name);
  }

  @override
  Future<bool> toggle({bool? visible}) async {
    return await methodChannel.invokeMethod('toggle', visible);
  }

  @override
  Future<bool> systemLog(String message) async {
    return await methodChannel.invokeMethod('systemLog', message);
  }

  @override
  Future<bool> customLog(String message) async {
    return await methodChannel.invokeMethod('customLog', message);
  }
}
