import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fwdebug_flutter/fwdebug_flutter.dart';

void main() {
  // FwdebugFlutter.isEnabled = kDebugMode;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      builder: (context, child) {
        return FwdebugFlutter.inspector(child: child!);
      },
      navigatorObservers: [FwdebugFlutter.navigatorObserver],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('fwdebug_flutter'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              FwdebugFlutter.toggle();
            },
            child: const Text('Toggle'),
          ),
          ElevatedButton(
            onPressed: () {
              FwdebugFlutter.systemLog('This is a system debug log');
              FwdebugFlutter.info('This is a system info log');
              FwdebugFlutter.warning('This is a system warning log');
              FwdebugFlutter.error('This is a system error log');
              _showToast('System Log called');
            },
            child: const Text('System Log'),
          ),
          ElevatedButton(
            onPressed: () {
              FwdebugFlutter.customLog('This is a custom debug log');
              FwdebugFlutter.customLog('This is a custom info log',
                  level: LogLevel.info);
              FwdebugFlutter.customLog('This is a custom warning log',
                  level: LogLevel.warning);
              FwdebugFlutter.customLog('This is a custom error log',
                  level: LogLevel.error);
              _showToast('Custom Log called');
            },
            child: const Text('Custom Log'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dio = Dio();
              FwdebugFlutter.intercept(dio);
              // dio.interceptors.add(FwdebugFlutter.interceptor);

              final response = await dio.get('http://www.wuyong.site/time.php');
              _showToast(response.data?.toString() ?? 'Request failed');
            },
            child: const Text('Dio Request'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!FwdebugFlutter.registerEntry('close', null)) {
                FwdebugFlutter.registerEntry(
                  'close',
                  GestureDetector(
                    onTap: () {
                      FwdebugFlutter.toggle(false);
                    },
                    child:
                        const Icon(Icons.close, color: Colors.blue, size: 20),
                  ),
                );
              }

              _showToast('Custom Entry registered');
            },
            child: const Text('Register Entry'),
          ),
          ElevatedButton(
            onPressed: () async {
              FwdebugFlutter.registerInfo('Flavor',
                  () => const String.fromEnvironment('FLUTTER_APP_FLAVOR'));
              FwdebugFlutter.registerInfo('Async Info', () async {
                await Future.delayed(const Duration(milliseconds: 10));
                return "test";
              });

              _showToast('Custom Info registered');
            },
            child: const Text('Register Info'),
          ),
          ElevatedButton(
            onPressed: () async {
              FwdebugFlutter.registerUrl('/');
              FwdebugFlutter.registerUrl('/custom', (url) {
                _showToast('Open Custom Url: $url');
              });

              _showToast('Custom Url registered');
            },
            child: const Text('Register Url'),
          ),
          ElevatedButton(
            onPressed: () async {
              FwdebugFlutter.openUrl((url) {
                _showToast('Open Url: $url');
              });

              _showToast('Open Url registered');
            },
            child: const Text('Open Url'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
