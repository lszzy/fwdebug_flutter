# fwdebug_flutter

iOS [FWDebug](https://github.com/lszzy/FWDebug) Wrapper for Flutter.

**Since this debug library calls the private APIs, the on-board review will not pass, so please remove it when submitting to AppStore.**

## Getting Started

### 1. inspector
Initialize the Inspector debugging widget, for example:

    Widget build(BuildContext context) {
      return MaterialApp(
        ...
        builder: (context, child) {
          return FwdebugFlutter.inspector(child: child!);
        },
      );
    }

### 2. intercept
Forward Dio requests to iOS native FWDebug, for example:

    final dio = Dio();
    FwdebugFlutter.intercept(dio);

### 3. systemLog
Record logs to iOS native FWDebug, for example:

    FwdebugFlutter.systemLog('This is a system log');

### 4. customLog
Record file logs to iOS native FWDebug, for example:

    FwdebugFlutter.customLog('This is a custom log');

### 5. toggle
Toggle iOS native FWDebug to show or hide, for example:

    FwdebugFlutter.toggle();

### 6. registerEntry
Register custom entry to iOS native FWDebug, for example:

    FwdebugFlutter.registerEntry('🍺  Custom Entry', () { ... });

### 6. openUrl
Register opening URL of iOS native FWDebug, for example:

    FwdebugFlutter.openUrl((url) { ... });
