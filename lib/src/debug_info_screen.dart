import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fwdebug_flutter/fwdebug_flutter_inspector.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'debug_url_screen.dart';

class DebugInfoScreen extends StatefulWidget {
  const DebugInfoScreen({super.key});

  @override
  State<DebugInfoScreen> createState() => _DebugInfoScreenState();
}

class _DebugInfoScreenState extends State<DebugInfoScreen> {
  static const _toolbarHeight = 54.0;

  late final TextEditingController _filterTextController;
  late List<List<(String, String)>> _filteredInfos;
  final List<List<(String, String)>> _infos = [];

  final List<String> _sections = [
    "Custom Info",
    "Media Query",
    "Package Info",
    "Device Info",
    if (!kIsWeb) "Platform Info",
  ];

  String get _filterText => _filterTextController.text.trim();

  @override
  void initState() {
    super.initState();

    _filterTextController = TextEditingController();
    _filteredInfos = [];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setupInfos();
      _filterInfos();
    });
  }

  @override
  void dispose() {
    _filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          SmallTextButton(
            title: 'Copy',
            onTap: () => _onCopyInfos(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, _toolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              height: _toolbarHeight,
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _filterTextController,
                onChanged: (_) => _filterInfos(),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusedBorder: _buildBorder(),
                  enabledBorder: _buildBorder(),
                  border: _buildBorder(),
                  suffixIcon: _filterText.isNotEmpty
                      ? SmallIconButton(
                          icon: Icons.cancel_outlined,
                          onTap: _onSearchBarCancel,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 2,
          left: 16,
          right: 16,
          bottom: 10 + MediaQuery.paddingOf(context).bottom,
        ),
        children: _buildList(),
      ),
    );
  }

  List<Widget> _buildList() {
    final List<Widget> list = [];
    for (var i = 0; i < _filteredInfos.length; i++) {
      final info = _filteredInfos[i];
      if (info.isEmpty) continue;

      list.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF212121),
            border: Border.all(
              color: Colors.white70,
              width: 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _onCopyText(_sections[i]);
                },
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.titleLarge,
                  child: Text(
                    _sections[i],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ...info.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () {
                      _onCopyText("${entry.$1}: ${entry.$2}");
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.bodySmall,
                          child: Text(
                            "${entry.$1}:",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: DefaultTextStyle.merge(
                              style: Theme.of(context).textTheme.bodySmall,
                              child: Text(
                                entry.$2,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
    return list;
  }

  Future _setupInfos() async {
    await _setupCustomInfo();
    await _setupMediaQuery();
    await _setupPackageInfo();
    await _setupDeviceInfo();
    if (!kIsWeb) await _setupPlatformInfo();
  }

  Future _setupCustomInfo() async {
    List<(String, String)> info = [];
    for (var entry in FwdebugFlutterInspector.registeredInfos) {
      final value = entry.$2();
      if (value is Future<dynamic>) {
        info.add((entry.$1, _format(await value)));
      } else {
        info.add((entry.$1, _format(value)));
      }
    }
    _infos.add(info);
  }

  Future _setupMediaQuery() async {
    var data = MediaQuery.maybeOf(context);
    if (data == null) {
      data = MediaQueryData.fromView(View.of(context));
      if (!kReleaseMode) {
        data = data.copyWith(platformBrightness: debugBrightnessOverride);
      }
    }

    List<(String, String)> info = [];
    info.add(("Size", _format(data.size)));
    info.add(("Device Pixel Ratio", _format(data.devicePixelRatio)));
    info.add(("Physical Size", _format(data.size * data.devicePixelRatio)));
    info.add(("Orientation", _format(data.orientation)));
    info.add(("Text Scale Factor", _format(data.textScaler.scale(1))));
    info.add(("Platform Brightness", _format(data.platformBrightness)));
    info.add(("Padding", _format(data.padding)));
    info.add(("View Insets", _format(data.viewInsets)));
    info.add(("System Gesture Insets", _format(data.systemGestureInsets)));
    info.add(("View Padding", _format(data.viewPadding)));
    info.add(
        ("Always use 24 Hour Format", _format(data.alwaysUse24HourFormat)));
    info.add(("Accessible Navigation", _format(data.accessibleNavigation)));
    info.add(("Invert Colors", _format(data.invertColors)));
    info.add(("High Contrast", _format(data.highContrast)));
    info.add(("On/Off switch labels", _format(data.onOffSwitchLabels)));
    info.add(("Disable Animations", _format(data.disableAnimations)));
    info.add(("Bold Text", _format(data.boldText)));
    info.add(("Navigation Mode", _format(data.navigationMode)));
    info.add(("Gesture Settings", ""));
    info.add(
        ("  Touch Slop", _format(data.gestureSettings.touchSlop ?? 'unset')));
    info.add(("  Pan Slop", _format(data.gestureSettings.panSlop ?? 'unset')));
    _infos.add(info);
  }

  Future _setupPackageInfo() async {
    final data = await PackageInfo.fromPlatform();

    List<(String, String)> info = [];
    info.add(("App Name", _format(data.appName)));
    info.add(("Package Name", _format(data.packageName)));
    info.add(("Version", _format(data.version)));
    info.add(("Build Number", _format(data.buildNumber)));
    info.add(("Build Signature", _format(data.buildSignature)));
    info.add(("Installer Store", _format(data.installerStore ?? 'unknown')));
    _infos.add(info);
  }

  Future _setupDeviceInfo() async {
    if (kIsWeb) return await _setupWebInfo();
    if (Platform.isAndroid) return await _setupAndroidInfo();
    if (Platform.isIOS) return await _setupiOSInfo();
    if (Platform.isWindows) return await _setupWindowsInfo();
    if (Platform.isLinux) return await _setupLinuxInfo();
    if (Platform.isMacOS) return await _setupMacOSInfo();

    List<(String, String)> info = [];
    if (Platform.isFuchsia) {
      info.add(("OS", "Fuchsia"));
    } else {
      info.add(("OS", Platform.operatingSystem));
    }
    _infos.add(info);
  }

  Future _setupWebInfo() async {
    final data = await DeviceInfoPlugin().webBrowserInfo;

    List<(String, String)> info = [];
    info.add(("Browser", _format(data.browserName)));
    info.add(("  Vendor", _format(data.vendor)));
    info.add(("  Vendor Version", _format(data.vendorSub)));
    info.add(("  Codename", _format(data.appCodeName)));
    info.add(("  Version", _format(data.appVersion)));
    info.add(("  Build Number", _format(data.productSub)));
    info.add(("Language", _format(data.language)));
    info.add(("Languages", _format(data.languages)));
    info.add(("User Agent", _format(data.userAgent)));
    info.add(
        ("Maximum Simultaneous Touch Points", _format(data.maxTouchPoints)));
    info.add(("Logical CPU Cores", _format(data.hardwareConcurrency)));
    info.add((
      "Memory Size (GB)",
      _format(data.deviceMemory?.toDouble() ?? 'unknown')
    ));
    _infos.add(info);
  }

  Future _setupAndroidInfo() async {
    final data = await DeviceInfoPlugin().androidInfo;

    List<(String, String)> info = [];
    info.add(("Android", ""));
    info.add(("  Build Type", _format(data.type)));
    info.add(("  Build Tags", _format(data.tags)));
    info.add(("  Fingerprint", _format(data.fingerprint)));
    info.add(("  Supported 32-Bit ABIs", _format(data.supported32BitAbis)));
    info.add(("  Supported 64-Bit ABIs", _format(data.supported64BitAbis)));
    info.add(("  Supported ABIs", _format(data.supportedAbis)));
    info.add(("  System Features", _format(data.systemFeatures)));
    info.add(("  Version", ""));
    info.add(("    Version", _format(data.version.release)));
    info.add(("    SDK Version", _format(data.version.sdkInt)));
    info.add((
      "    Developer Preview SDK",
      _format(data.version.previewSdkInt ?? '-')
    ));
    info.add(("    Base OS Build", _format(data.version.baseOS ?? "")));
    info.add(("    Security Patch", _format(data.version.securityPatch ?? "")));
    info.add(("    Codename", _format(data.version.codename)));
    info.add(("    Incremental", _format(data.version.incremental)));
    info.add(("Device", ""));
    info.add(("  Is a physical device?", _format(data.isPhysicalDevice)));
    info.add(("  Board", _format(data.board)));
    info.add(("  Manufacturer", _format(data.manufacturer)));
    info.add(("  Brand", _format(data.brand)));
    info.add(("  Product", _format(data.product)));
    info.add(("  Device", _format(data.device)));
    info.add(("  Model", _format(data.model)));
    info.add(("  Bootloader", _format(data.bootloader)));
    info.add(("  Hardware", _format(data.hardware)));
    info.add(("  Hostname", _format(data.host)));
    info.add(("  Serial Number", _format(data.serialNumber)));
    info.add(("  Changelist Number / Label", _format(data.id)));
    info.add(("  Display Build ID", _format(data.display)));
    _infos.add(info);
  }

  Future _setupiOSInfo() async {
    final data = await DeviceInfoPlugin().iosInfo;

    List<(String, String)> info = [];
    info.add(("iOS", ""));
    info.add(("  Name", _format(data.systemName)));
    info.add(("  Version", _format(data.systemVersion)));
    info.add(("  utsname", ""));
    info.add(("    Name", _format(data.utsname.sysname)));
    info.add(("    Network Node Name", _format(data.utsname.nodename)));
    info.add(("    Release Level", _format(data.utsname.release)));
    info.add(("    Version Level", _format(data.utsname.version)));
    info.add(("    Hardware Type", _format(data.utsname.machine)));
    info.add(("Device", ""));
    info.add(("  Is a physical device?", _format(data.isPhysicalDevice)));
    info.add(("  Name", _format(data.name)));
    info.add(("  Model", _format(data.model)));
    info.add(("  Model (localized)", _format(data.localizedModel)));
    info.add(
        ("  Identifier for the Vendor", _format(data.identifierForVendor)));
    _infos.add(info);
  }

  Future _setupWindowsInfo() async {
    final data = await DeviceInfoPlugin().windowsInfo;

    List<(String, String)> info = [];
    info.add(("Windows", ""));
    info.add(("  Computer Name", _format(data.computerName)));
    info.add(("  Core Count", _format(data.numberOfCores)));
    info.add(("  Memory Size (MB)", _format(data.systemMemoryInMegabytes)));
    _infos.add(info);
  }

  Future _setupLinuxInfo() async {
    final data = await DeviceInfoPlugin().linuxInfo;

    List<(String, String)> info = [];
    info.add((data.prettyName, ""));
    info.add(("  ID", _format(data.id)));
    info.add(("  ID-like", _format(data.idLike)));
    info.add(("  Version", _format(data.version)));
    info.add(("  Version ID", _format(data.versionId)));
    info.add(("  Version Codename", _format(data.versionCodename)));
    info.add(("  Build ID", _format(data.buildId)));
    info.add(("  Variant", _format(data.variant)));
    info.add(("  Variant ID", _format(data.variantId)));
    info.add(("  Machine ID", _format(data.machineId)));
    _infos.add(info);
  }

  Future _setupMacOSInfo() async {
    final data = await DeviceInfoPlugin().macOsInfo;

    List<(String, String)> info = [];
    info.add(("macOS", ""));
    info.add(("  OS Release", _format(data.osRelease)));
    info.add(("  Kernel Version", _format(data.kernelVersion)));
    info.add(("  Architecture", _format(data.arch)));
    info.add(("  Device Model", _format(data.model)));
    info.add(("  Computer Name", _format(data.computerName)));
    info.add(("  Host Name", _format(data.hostName)));
    info.add(("  Active CPUs", _format(data.activeCPUs)));
    info.add(("  Memory Size", _format(data.memorySize)));
    info.add(("  CPU Frequency", _format("${data.cpuFrequency}Hz")));
    _infos.add(info);
  }

  Future _setupPlatformInfo() async {
    List<(String, String)> info = [];
    info.add(("OS", _format(Platform.operatingSystem)));
    info.add(("OS Version", _format(Platform.operatingSystemVersion)));
    info.add(("Version", _format(Platform.version)));
    info.add(("Locale", _format(Platform.localeName)));
    info.add(("Hostname", _format(Platform.localHostname)));
    info.add(("Number of CPUs", _format(Platform.numberOfProcessors)));
    info.add((
      "Package Config",
      _format(Platform.packageConfig ?? "No flag specified")
    ));
    info.add(("Path Separator", _format(Platform.pathSeparator)));
    info.add(("Executable", _format(Platform.executable)));
    info.add(("Resolved Executable", _format(Platform.resolvedExecutable)));
    info.add((
      "Environment Variables",
      Platform.environment.entries.isNotEmpty ? "" : "[]"
    ));
    info.addAll(Platform.environment.entries
        .map((entry) => ("  ${entry.key}", _format(entry.value)))
        .toList());
    info.add(("Executable Arguments", _format(Platform.executableArguments)));
    _infos.add(info);
  }

  String _format(dynamic value) {
    if (value is String) return '"$value"';
    if (value is Enum) return value.name;
    return '$value';
  }

  void _onSearchBarCancel() {
    setState(() {
      _filterTextController.clear();
      _filterInfos();
    });
  }

  void _onCopyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
    );
  }

  void _onCopyInfos() {
    var text = "";
    for (var i = 0; i < _filteredInfos.length; i++) {
      final info = _filteredInfos[i];
      if (info.isEmpty) continue;

      text += "\n${_sections[i]}\n";
      for (var entry in info) {
        text += "${entry.$1}: ${entry.$2}\n";
      }
    }
    _onCopyText(text.trim());
  }

  void _filterInfos() {
    final searchText = _filterText.toLowerCase();
    List<List<(String, String)>> filteredResults = [];
    for (var info in _infos) {
      final List<(String, String)> filteredInfo = [];
      for (var entry in info) {
        if (entry.$1.toLowerCase().contains(searchText) ||
            entry.$2.toLowerCase().contains(searchText)) {
          filteredInfo.add(entry);
        }
      }
      filteredResults.add(filteredInfo);
    }

    setState(() => _filteredInfos = filteredResults);
  }

  OutlineInputBorder _buildBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white70,
        width: 0,
      ),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }
}
