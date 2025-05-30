import 'dart:io';

import 'package:flutter/services.dart';

import 'fwdebug_flutter_platform_interface.dart';

class MethodChannelFwdebugFlutter extends FwdebugFlutterPlatform {
  final Map<String, VoidCallback> _registerEntryCallbacks = {};
  void Function(String url)? _openUrlCallback;
  bool? _isEnabled;
  bool get _isSupported => Platform.isIOS;
  late final _methodChannel = const MethodChannel('fwdebug_flutter')
    ..setMethodCallHandler((call) async {
      switch (call.method) {
        case 'registerEntryCallback':
          final name = call.arguments as String? ?? '';
          _registerEntryCallbacks[name]?.call();
          return null;
        case 'openUrlCallback':
          final url = call.arguments as String? ?? '';
          _openUrlCallback?.call(url);
          return null;
        default:
          throw MissingPluginException();
      }
    });

  MethodChannelFwdebugFlutter() {}

  @override
  setEnabled(bool enabled) {
    if (!_isSupported) return;
    _isEnabled = enabled;
  }

  @override
  Future<bool> isEnabled() async {
    if (!_isSupported) {
      return false;
    }

    _isEnabled ??= await _methodChannel.invokeMethod('isEnabled') as bool?;
    return _isEnabled ?? false;
  }

  @override
  toggle({bool? visible}) async {
    if (!_isSupported) return;
    await _methodChannel.invokeMethod('toggle', visible);
  }

  @override
  systemLog(String message) async {
    if (!_isSupported) return;
    await _methodChannel.invokeMethod('systemLog', message);
  }

  @override
  customLog(String message) async {
    if (!_isSupported) return;
    await _methodChannel.invokeMethod('customLog', message);
  }

  @override
  registerEntry(String name, VoidCallback callback) async {
    if (!_isSupported) return;
    _registerEntryCallbacks[name] = callback;
    await _methodChannel.invokeMethod('registerEntry', name);
  }

  @override
  openUrl(void Function(String url) callback) async {
    if (!_isSupported) return;
    _openUrlCallback = callback;
    await _methodChannel.invokeMethod('openUrl');
  }
}
