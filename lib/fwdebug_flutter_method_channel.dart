import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fwdebug_flutter_platform_interface.dart';

class MethodChannelFwdebugFlutter extends FwdebugFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('fwdebug_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
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
