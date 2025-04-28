import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:inspector/inspector.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

import 'fwdebug_flutter_platform_interface.dart';

class FwdebugFlutter {
  static var fwdebugEnabled = true;

  static final ValueNotifier<bool> _inspectorVisible =
      ValueNotifier(Platform.isIOS ? !fwdebugEnabled : true);

  static Widget inspector({required Widget child}) {
    if (Platform.isIOS && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance
          .registerEntry('👨🏾‍💻  Flutter Inspector', () {
        _inspectorVisible.value = !_inspectorVisible.value;
      });
    }

    return ValueListenableBuilder(
      valueListenable: _inspectorVisible,
      builder: (context, visible, child) {
        return Inspector(
          isEnabled: true,
          isPanelVisible: visible,
          child: child!,
        );
      },
      child: child,
    );
  }

  static intercept(Dio dio) {
    if (Platform.isIOS && fwdebugEnabled) {
      dio.httpClientAdapter = NativeAdapter();
    }
  }

  static toggle({bool? visible}) async {
    if (Platform.isIOS && fwdebugEnabled) {
      await FwdebugFlutterPlatform.instance.toggle(visible: visible);
    } else {
      _inspectorVisible.value = !_inspectorVisible.value;
    }
  }

  static systemLog(String message) async {
    if (Platform.isIOS && fwdebugEnabled) {
      await FwdebugFlutterPlatform.instance.systemLog(message);
    }
  }

  static customLog(String message) async {
    if (Platform.isIOS && fwdebugEnabled) {
      await FwdebugFlutterPlatform.instance.customLog(message);
    }
  }

  static registerEntry(String name, VoidCallback callback) async {
    if (Platform.isIOS && fwdebugEnabled) {
      await FwdebugFlutterPlatform.instance.registerEntry(name, callback);
    }
  }

  static openUrl(void Function(String url) callback) async {
    if (Platform.isIOS && fwdebugEnabled) {
      await FwdebugFlutterPlatform.instance.openUrl(callback);
    }
  }
}
