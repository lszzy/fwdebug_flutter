import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fwdebug_flutter/fwdebug_flutter.dart';

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
            onPressed: () async {
              await FwdebugFlutter.systemLog('This is a system log');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('System Log called'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('System Log'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FwdebugFlutter.customLog('This is a custom log');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Custom Log called'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Custom Log'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dio = Dio();
              FwdebugFlutter.intercept(dio);

              final response = await dio.get('http://www.wuyong.site/time.php');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.data?.toString() ?? 'Request failed'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Dio Request'),
          ),
          ElevatedButton(
            onPressed: () async {
              FwdebugFlutter.registerEntry(const Icon(Icons.close), () {
                FwdebugFlutter.toggle(false);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Custom Entry registered'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Register Entry'),
          ),
          ElevatedButton(
            onPressed: () async {
              FwdebugFlutter.openUrl((url) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Open Url: ${url}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open Url registered'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Open Url'),
          ),
        ],
      ),
    );
  }
}
