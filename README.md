# fwdebug_flutter

Flutter debugging libraray, wrapper for [talker_flutter](https://pub.dev/packages/talker_flutter), [inspector](https://pub.dev/packages/inspector), [FWDebug](https://github.com/lszzy/FWDebug) and so on, to facilitate development and testing.

## Screenshot
<img src="fwdebug_flutter.gif" width="375" />

## Getting Started
By default, fwdebug_flutter is available in all modes. If you want to enable it only in debug mode, you can set it at startup as follows:

    FwdebugFlutter.isEnabled = kDebugMode;

In addition, in order to make iOS FWDebug only effective in debug mode, you need to add the following code between `target 'Runner' do` and `end` in `ios/Podfile`:

    pod 'FWDebug', :configurations => ['Debug']

### 1. inspector
Initialize the fwdebug_flutter inspector, for example:

    Widget build(BuildContext context) {
      return MaterialApp(
        ...
        builder: (context, child) {
          return FwdebugFlutter.inspector(child: child!);
        },
      );
    }

### 2. navigatorObserver
Register the fwdebug_flutter navigatorObserver, for example:

    Widget build(BuildContext context) {
      return MaterialApp(
        ...
        navigatorObservers: [FwdebugFlutter.navigatorObserver],
      );
    }

### 3. intercept
Forward Dio requests to fwdebug_flutter, for example:

    final dio = Dio();
    FwdebugFlutter.intercept(dio);
    // dio.interceptors.add(FwdebugFlutter.interceptor);

### 4. riverpodObserver
Register the fwdebug_flutter riverpodObserver, for example:

    runApp(ProviderScope(
      observers: [FwdebugFlutter.riverpodObserver],
      child: const MyApp(),
    ));

### 5. systemLog
Record logs to fwdebug_flutter, for example:

    FwdebugFlutter.debug('This is a system debug log');
    // FwdebugFlutter.info('This is a system info log');
    // FwdebugFlutter.warning('This is a system warning log');
    // FwdebugFlutter.error('This is a system error log', group: 'test');
    // FwdebugFlutter.systemLog('This is a system debug log', group: 'test');

### 6. customLog
Record custom logs to fwdebug_flutter, for example:

    FwdebugFlutter.customLog('This is a custom debug log');
    // FwdebugFlutter.customLog('This is a custom info log', level: LogLevel.info);
    // FwdebugFlutter.customLog('This is a custom warning log', level: LogLevel.warning, group: 'test');
    // FwdebugFlutter.customLog('This is a custom error log', level: LogLevel.error, group: 'test');

### 7. toggle
Toggle fwdebug_flutter to show or hide, for example:

    FwdebugFlutter.toggle();

### 8. registerEntry
Register custom entry to fwdebug_flutter, for example:

    FwdebugFlutter.registerEntry(
        'entry',
        GestureDetector(
            onTap: () { ... }, 
            child: Icon(icon, color: Colors.blue, size: 20),
        ),
    );

### 9. registerInfo
Register custom info to fwdebug_flutter, for example:

    FwdebugFlutter.registerInfo('custom', () { ... });

### 10. registerUrl
Register custom url to fwdebug_flutter, for example:

    FwdebugFlutter.registerUrl('/custom');
    // FwdebugFlutter.registerUrl('/custom', (url) { ... });

### 11. openUrl
Register opening URL of fwdebug_flutter, for example:

    FwdebugFlutter.openUrl((url) { ... });
