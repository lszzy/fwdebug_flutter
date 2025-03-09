import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fwdebug_flutter_method_channel.dart';

abstract class FwdebugFlutterPlatform extends PlatformInterface {
  FwdebugFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FwdebugFlutterPlatform _instance = MethodChannelFwdebugFlutter();

  static FwdebugFlutterPlatform get instance => _instance;

  static set instance(FwdebugFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> registerEntry(String name, VoidCallback callback) async {
    throw UnimplementedError('registerEntry() has not been implemented.');
  } 

  Future<bool> toggle({bool? visible}) async {
    throw UnimplementedError('toggle() has not been implemented.');
  }

  Future<bool> systemLog(String message) async {
    throw UnimplementedError('systemLog() has not been implemented.');
  }

  Future<bool> customLog(String message) async {
    throw UnimplementedError('customLog() has not been implemented.');
  }
}
