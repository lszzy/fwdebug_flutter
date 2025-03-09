import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:inspector/inspector.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

import 'fwdebug_flutter_platform_interface.dart';

class FwdebugFlutter {
  static final ValueNotifier<bool> _inspectorVisible = ValueNotifier(false);

  static Widget inspector({required Widget child}) {
    if (Platform.isIOS) {
      FwdebugFlutterPlatform.instance.registerEntry('👨🏾‍💻  Flutter Inspector', () {
        _inspectorVisible.value = !_inspectorVisible.value;
      });
       
      return ValueListenableBuilder(
        valueListenable: _inspectorVisible,
        builder: (context, visible, child) {
          return Inspector(
            isPanelVisible: visible,
            child: child!,
          );
        },
        child: child,
      );
    } else {
      return child;
    }
  }

  static bool intercept(Dio dio) {
    if (Platform.isIOS) {
      dio.httpClientAdapter = NativeAdapter();
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> toggle({bool? visible}) async {
    if (Platform.isIOS) {
      return await FwdebugFlutterPlatform.instance.toggle(visible: visible);
    } else {
      return false;
    }
  }

  static Future<bool> systemLog(String message) async {
    if (Platform.isIOS) {
      return await FwdebugFlutterPlatform.instance.systemLog(message);
    } else {
      return false;
    }
  }

  static Future<bool> customLog(String message) async {
    if (Platform.isIOS) {
      return FwdebugFlutterPlatform.instance.customLog(message);
    } else {
      return false;
    }
  }
}
