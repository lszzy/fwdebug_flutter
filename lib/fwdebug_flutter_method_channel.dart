import 'package:flutter/services.dart';

import 'fwdebug_flutter_platform_interface.dart';

class MethodChannelFwdebugFlutter extends FwdebugFlutterPlatform {
  Map<String, VoidCallback> registerEntryCallbacks = {};
  void Function(String url)? openUrlCallback;
  final methodChannel = const MethodChannel('fwdebug_flutter');

  MethodChannelFwdebugFlutter() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'registerEntryCallback':
          final name = call.arguments as String? ?? '';
          registerEntryCallbacks[name]?.call();
          return null;
        case 'openUrlCallback':
          final url = call.arguments as String? ?? '';
          openUrlCallback?.call(url);
          return null;
        default:
          throw MissingPluginException();
      }
    });
  }

  @override
  toggle({bool? visible}) async {
    await methodChannel.invokeMethod('toggle', visible);
  }

  @override
  systemLog(String message) async {
    await methodChannel.invokeMethod('systemLog', message);
  }

  @override
  customLog(String message) async {
    await methodChannel.invokeMethod('customLog', message);
  }

  @override
  registerEntry(String name, VoidCallback callback) async {
    registerEntryCallbacks[name] = callback;
    await methodChannel.invokeMethod('registerEntry', name);
  }

  @override
  openUrl(void Function(String url) callback) async {
    openUrlCallback = callback;
    await methodChannel.invokeMethod('openUrl');
  }
}
