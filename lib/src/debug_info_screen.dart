import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.titleLarge,
                child: Text(
                  _sections[i],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ...info.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
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
                );
              }),
            ],
          ),
        ),
      );
    }

    list.addAll(_buildEntries());
    return list;
  }

  List<Widget> _buildEntries() {
    final List<Widget> entries = [
      DeviceInfoEntry(),
      if (!kIsWeb) PlatformInfoEntry(),
    ];
    return entries;
  }

  Future _setupInfos() async {
    await _setupCustomInfo();
    await _setupMediaQuery();
    await _setupPackageInfo();
  }

  Future _setupCustomInfo() async {
    List<(String, String)> info = [];
    for (var entry in FwdebugFlutterInspector.registeredInfos) {
      info.add((entry.$1, _format(entry.$2())));
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
    info.add(("Orientation", data.orientation.name));
    info.add(("Text Scale Factor", _format(data.textScaler.scale(1))));
    info.add(("Platform Brightness", data.platformBrightness.name));
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
    info.add(("Navigation Mode", data.navigationMode.name));
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

  String _format(dynamic value) {
    if (value is String) return '"$value"';
    return '$value';
  }

  void _onSearchBarCancel() {
    setState(() {
      _filterTextController.clear();
      _filterInfos();
    });
  }

  void _onCopyInfos() {}

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

class MediaQueryInfoEntry extends StatelessWidget {
  const MediaQueryInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugInfoEntry(
      title: const Text("MediaQuery"),
      data: _retrieveInfo(context),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo(
      BuildContext context) async {
    var data = MediaQuery.maybeOf(context);
    if (data == null) {
      data = MediaQueryData.fromView(View.of(context));
      if (!kReleaseMode) {
        data = data.copyWith(platformBrightness: debugBrightnessOverride);
      }
    }

    return [
      DebugProperty(
        "Size",
        data.size,
        defaultValue: Size.zero,
        tooltip:
            "The size of the media in logical pixels (e.g, the size of the screen).",
      ),
      DebugDoubleProperty(
        "Device Pixel Ratio",
        data.devicePixelRatio,
        defaultValue: 1,
        tooltip: "The number of device pixels for each logical pixel.",
      ),
      DebugProperty(
        "Physical Size",
        data.size * data.devicePixelRatio,
        tooltip: "The size of the media in device pixels.",
      ),
      DebugEnumProperty(
        "Orientation",
        data.orientation,
      ),
      DebugDoubleProperty(
        "Text Scale Factor",
        data.textScaler.scale(1),
        defaultValue: 1,
        tooltip: "The number of font pixels for each logical pixel",
      ),
      DebugEnumProperty(
        "Platform Brightness",
        data.platformBrightness,
      ),
      DebugProperty(
        "Padding",
        data.padding,
        defaultValue: EdgeInsets.zero,
        tooltip:
            "Padding is derived from the values of viewInsets and viewPadding.",
      ),
      DebugProperty(
        "View Insets",
        data.viewInsets,
        defaultValue: EdgeInsets.zero,
        tooltip: "The parts of the display that are completely obscured by"
            " system UI, typically by the device's keyboard.",
      ),
      DebugProperty(
        "System Gesture Insets",
        data.systemGestureInsets,
        defaultValue: EdgeInsets.zero,
        tooltip: "The areas along the edges of the display where the system"
            " consumes certain input events and blocks delivery"
            " of those events to the app.",
      ),
      DebugProperty(
        "View Padding",
        data.viewPadding,
        defaultValue: EdgeInsets.zero,
        tooltip:
            'The parts of the display that are partially obscured by system UI,'
            ' typically by the hardware display "notches" or the system status bar.',
      ),
      DebugFlagProperty(
        "Always use 24 Hour Format",
        value: data.alwaysUse24HourFormat,
        ifTrue: "Always use 24 Hour Format",
      ),
      DebugFlagProperty(
        "Accessible Navigation",
        value: data.accessibleNavigation,
        ifTrue: "Use accessible navigation",
        tooltip:
            "Whether the user is using an accessibility service like TalkBack or VoiceOver to interact with the application.",
      ),
      DebugFlagProperty(
        "Invert Colors",
        value: data.invertColors,
        ifTrue: "The device inverts colors",
      ),
      DebugFlagProperty(
        "High Contrast",
        value: data.highContrast,
        ifTrue: "Should use high contrast",
      ),
      DebugFlagProperty(
        "On/Off switch labels",
        value: data.onOffSwitchLabels,
        ifTrue: "Should use on/off labels inside switches",
        tooltip: "Whether the user requested on/off labels inside switches",
      ),
      DebugFlagProperty(
        "Disable Animations",
        value: data.disableAnimations,
        ifTrue: "Disable animations",
      ),
      DebugFlagProperty(
        "Bold Text",
        value: data.boldText,
        ifTrue: "Use bold text",
      ),
      DebugEnumProperty(
        "Navigation Mode",
        data.navigationMode,
      ),
      DebugBlock(
        name: "Gesture Settings",
        children: [
          DebugDoubleProperty(
            "Touch Slop",
            data.gestureSettings.touchSlop,
            ifNull: "unset",
            tooltip:
                "The number of logical pixels a pointer is allowed to drift before it is considered an intentional touch.",
          ),
          DebugDoubleProperty(
            "Pan Slop",
            data.gestureSettings.panSlop,
            ifNull: "unset",
            tooltip:
                "The number of logical pixels a pointer is allowed to drift before it is considered an intentional pan.",
          ),
        ],
      ),
    ];
  }
}

class PackageInfoEntry extends StatelessWidget {
  const PackageInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugInfoEntry(
      title: const Text("Package Info"),
      data: _retrieveInfo(),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo() async {
    final info = await PackageInfo.fromPlatform();
    return [
      DebugStringProperty(
        "App Name",
        info.appName,
        tooltip: "CFBundleDisplayName on iOS, application/label on Android.",
      ),
      DebugStringProperty(
        "Package Name",
        info.packageName,
        tooltip: "bundleIdentifier on iOS, getPackageName on Android.",
      ),
      DebugStringProperty(
        "Version",
        info.version,
        tooltip: "CFBundleShortVersionString on iOS, versionName on Android.",
      ),
      DebugStringProperty(
        "Build Number",
        info.buildNumber,
        tooltip: "CFBundleVersion on iOS, versionCode on Android.",
      ),
      DebugStringProperty(
        "Build Signature",
        info.buildSignature,
        tooltip: "Empty string on iOS, signing key signature (hex) on Android.",
      ),
      DebugStringProperty(
        "Installer Store",
        info.installerStore,
        ifNull: "unknown",
        tooltip:
            "Indicates through which store this application was installed.",
      ),
    ];
  }
}

class DeviceInfoEntry extends StatelessWidget {
  const DeviceInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugInfoEntry(
      title: const Text("Device Info"),
      data: _retrieveInfo(),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo() async {
    if (kIsWeb) return _retrieveWebInfo();
    if (Platform.isAndroid) return _retrieveAndroidInfo();
    if (Platform.isIOS) return _retrieveiOSInfo();
    if (Platform.isWindows) return _retrieveWindowsInfo();
    if (Platform.isLinux) return _retrieveLinuxInfo();
    if (Platform.isMacOS) return _retrieveMacOSInfo();
    if (Platform.isFuchsia) return [DebugStringProperty("OS", "Fuchsia")];
    return [
      DebugStringProperty("OS", Platform.operatingSystem),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveWebInfo() async {
    final info = await DeviceInfoPlugin().webBrowserInfo;
    return [
      DebugBlock(
        name: "Browser: ${info.browserName.name}",
        properties: [
          DebugStringProperty(
            "Vendor",
            info.vendor,
          ),
          DebugStringProperty(
            "Vendor Version",
            info.vendorSub,
            defaultValue: "",
          ),
          DebugStringProperty(
            "Codename",
            info.appCodeName,
          ),
          DebugStringProperty(
            "Version",
            info.appVersion,
          ),
          DebugStringProperty(
            "Build Number",
            info.productSub,
          ),
        ],
      ),
      DebugStringProperty("Language", info.language),
      DebugIterableProperty("Languages", info.languages),
      DebugStringProperty("User Agent", info.userAgent),
      DebugIntProperty(
        "Maximum Simultaneous Touch Points",
        info.maxTouchPoints,
        defaultValue: 0,
      ),
      DebugIntProperty("Logical CPU Cores", info.hardwareConcurrency),
      DebugDoubleProperty(
        "Memory Size (GB)",
        info.deviceMemory?.toDouble(),
        ifNull: "unknown",
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveAndroidInfo() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return [
      DebugBlock(
        name: "Android",
        properties: [
          DebugStringProperty("Build Type", info.type),
          DebugStringProperty("Build Tags", info.tags),
          DebugStringProperty(
            "Fingerprint",
            info.fingerprint,
          ),
          DebugIterableProperty(
            "Supported 32-Bit ABIs",
            info.supported32BitAbis,
          ),
          DebugIterableProperty(
            "Supported 64-Bit ABIs",
            info.supported64BitAbis,
          ),
          DebugIterableProperty(
            "Supported ABIs",
            info.supportedAbis,
          ),
          DebugIterableProperty(
            "System Features",
            info.systemFeatures,
          ),
        ],
        children: [
          DebugBlock(
            name: "Version",
            properties: [
              DebugStringProperty("Version", info.version.release),
              DebugIntProperty(
                "SDK Version",
                info.version.sdkInt,
                defaultValue: -1,
              ),
              DebugIntProperty(
                "Developer Preview SDK",
                info.version.previewSdkInt,
                ifNull: "-",
              ),
              DebugStringProperty(
                "Base OS Build",
                info.version.baseOS,
                defaultValue: "",
              ),
              DebugStringProperty(
                "Security Patch",
                info.version.securityPatch,
                defaultValue: "",
              ),
              DebugStringProperty(
                "Codename",
                info.version.codename,
                defaultValue: "REL",
              ),
              DebugStringProperty(
                "Incremental",
                info.version.incremental,
              ),
            ],
          ),
        ],
      ),
      DebugBlock(
        name: "Device",
        properties: [
          DebugFlagProperty(
            "Is a physical device?",
            value: info.isPhysicalDevice,
            ifTrue: "Running on a physical device",
            ifFalse: "Running on an emulator or unknown device",
          ),
          DebugStringProperty("Board", info.board),
          DebugStringProperty("Manufacturer", info.manufacturer),
          DebugStringProperty("Brand", info.brand),
          DebugStringProperty("Product", info.product),
          DebugStringProperty("Device", info.device),
          DebugStringProperty("Model", info.model),
          DebugStringProperty("Bootloader", info.bootloader),
          DebugStringProperty("Hardware", info.hardware),
          DebugStringProperty("Hostname", info.host),
          DebugStringProperty("Serial Number", info.serialNumber),
          DebugStringProperty("Changelist Number / Label", info.id),
        ],
        children: [
          DebugStringProperty(
            "Display Build ID",
            info.display,
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveiOSInfo() async {
    final info = await DeviceInfoPlugin().iosInfo;
    return [
      DebugBlock(
        name: "iOS",
        properties: [
          DebugStringProperty("Name", info.systemName),
          DebugStringProperty("Version", info.systemVersion),
        ],
        children: [
          DebugBlock(
            name: "utsname",
            properties: [
              DebugStringProperty("Name", info.utsname.sysname),
              DebugStringProperty("Network Node Name", info.utsname.nodename),
              DebugStringProperty("Release Level", info.utsname.release),
              DebugStringProperty("Version Level", info.utsname.version),
              DebugStringProperty("Hardware Type", info.utsname.machine),
            ],
          ),
        ],
      ),
      DebugBlock(
        name: "Device",
        properties: [
          DebugFlagProperty(
            "Is a physical device?",
            value: info.isPhysicalDevice,
            ifTrue: "Running on a physical device",
            ifFalse: "Running on a simulator or unknown device",
          ),
          DebugStringProperty("Name", info.name),
          DebugStringProperty("Model", info.model),
          DebugStringProperty("Model (localized)", info.localizedModel),
          DebugStringProperty(
            "Identifier for the Vendor",
            info.identifierForVendor,
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveWindowsInfo() async {
    final info = await DeviceInfoPlugin().windowsInfo;
    return [
      DebugBlock(
        name: "Windows",
        children: [
          DebugStringProperty(
            "Computer Name",
            info.computerName,
            defaultValue: "",
          ),
          DebugIntProperty("Core Count", info.numberOfCores),
          DebugStringProperty(
            "Memory Size (MB)",
            "${(info.systemMemoryInMegabytes)}",
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveLinuxInfo() async {
    final info = await DeviceInfoPlugin().linuxInfo;
    return [
      DebugBlock(
        name: info.prettyName,
        children: [
          DebugStringProperty(
            "ID",
            info.id,
            defaultValue: "linux",
          ),
          DebugIterableProperty("ID-like", info.idLike),
          DebugStringProperty("Version", info.version, defaultValue: null),
          DebugStringProperty("Version ID", info.versionId, defaultValue: null),
          DebugStringProperty(
            "Version Codename",
            info.versionCodename,
            defaultValue: null,
          ),
          DebugStringProperty("Build ID", info.buildId, defaultValue: null),
          DebugStringProperty("Variant", info.variant, defaultValue: null),
          DebugStringProperty(
            "Variant ID",
            info.variantId,
            defaultValue: null,
          ),
          DebugStringProperty(
            "Machine ID",
            info.machineId,
            defaultValue: null,
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveMacOSInfo() async {
    final info = await DeviceInfoPlugin().macOsInfo;
    return [
      DebugBlock(
        name: "macOS",
        children: [
          DebugStringProperty("OS Release", info.osRelease),
          DebugStringProperty(
            "Kernel Version",
            info.kernelVersion,
          ),
          DebugStringProperty("Architecture", info.arch),
          DebugStringProperty("Device Model", info.model),
          DebugStringProperty("Computer Name", info.computerName),
          DebugStringProperty("Host Name", info.hostName),
          DebugIntProperty("Active CPUs", info.activeCPUs),
          DebugStringProperty(
            "Memory Size",
            "${info.memorySize}",
          ),
          DebugStringProperty(
            "CPU Frequency",
            "${info.cpuFrequency}Hz",
          ),
        ],
      ),
    ];
  }
}

class PlatformInfoEntry extends StatelessWidget {
  const PlatformInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    assert(!kIsWeb, "This debug widget is not supported on dart.library.html");

    return DebugInfoEntry(
      title: const Text("Platform Info"),
      data: _retrieveInfo(),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo() async {
    return [
      DebugStringProperty("OS", Platform.operatingSystem),
      DebugStringProperty("OS Version", Platform.operatingSystemVersion),
      DebugStringProperty("Version", Platform.version),
      DebugStringProperty("Locale", Platform.localeName),
      DebugStringProperty("Hostname", Platform.localHostname),
      DebugIntProperty("Number of CPUs", Platform.numberOfProcessors),
      DebugStringProperty(
        "Package Config",
        Platform.packageConfig ?? "No flag specified",
        tooltip:
            "The --packages flag passed to the executable used to run the script in this isolate.",
      ),
      DebugStringProperty("Path Separator", Platform.pathSeparator),
      DebugStringProperty("Executable", Platform.executable),
      DebugStringProperty("Resolved Executable", Platform.resolvedExecutable),
      DebugBlock(
        name: "Environment Variables",
        properties: Platform.environment.entries
            .map((entry) => DebugStringProperty(entry.key, entry.value))
            .toList(),
      ),
      DebugIterableProperty(
        "Executable Arguments",
        Platform.executableArguments,
      ),
    ];
  }
}

class DebugInfoEntry extends StatelessWidget {
  static const double _kChildrenPadding = 6.0;

  const DebugInfoEntry({
    super.key,
    required this.title,
    required this.data,
  });

  final Widget title;
  final Future<List<DebugPropertyNode>> data;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      child: FutureBuilder<List<DebugPropertyNode>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              debugPrint("Error while collecting data: ${snapshot.error}");
              debugPrintStack(stackTrace: snapshot.stackTrace);
            }

            return Text("${snapshot.error}\n${snapshot.stackTrace!}");
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isNotEmpty) {
            return SelectionArea(
              child: Column(
                children: buildChildren(snapshot.data!),
              ),
            );
          } else {
            return Center(
              child: Text(
                "Empty",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> buildChildren(
    List<DebugPropertyNode> children, [
    double leftPadding = 0.0,
  ]) {
    List<Widget> widgets = [];

    for (var child in children) {
      String? name = child.name;
      String description = child.toDescription().trimRight();
      bool wrapDescription =
          description.contains("\n") || description.length >= 120;

      var nextChildren = buildChildren(child.getChildren(), _kChildrenPadding);

      Widget wrapTooltip(Widget child, {String? tooltip}) {
        if (tooltip != null) {
          return Tooltip(
            message: tooltip,
            child: child,
          );
        }
        return child;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: leftPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (child.showName && name != null)
                      wrapTooltip(
                        Text(
                          child.showSeparator ? "$name:" : name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: child.tooltip,
                      ),
                    if (description.isNotEmpty && !wrapDescription)
                      Expanded(
                        child: wrapTooltip(
                          Padding(
                            padding: child.showName
                                ? const EdgeInsets.only(left: 4.0)
                                : EdgeInsets.zero,
                            child: Text(description),
                          ),
                          tooltip: !child.showName || name == null
                              ? child.tooltip
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              if (wrapDescription)
                Padding(
                  padding: child.showName
                      ? const EdgeInsets.only(left: _kChildrenPadding)
                      : EdgeInsets.zero,
                  child: Text(description),
                ),
              ...buildChildren(child.getProperties(), _kChildrenPadding),
              if (nextChildren.isNotEmpty)
                Column(
                  children: nextChildren,
                )
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}

abstract class DebugPropertyNode {
  final String? name;
  final bool showName;
  final bool showSeparator;

  DebugPropertyNode({
    required this.name,
    this.showName = true,
    this.showSeparator = true,
  }) : assert(
          name == null || !name.endsWith(":"),
          "Names must not end with colons.\n"
          "name:\n"
          '  "$name"',
        );

  Object? get value;

  String? get tooltip;

  /// Children of this [DebugPropertyNode].
  List<DebugPropertyNode> getChildren();

  /// Properties of this [DebugPropertyNode].
  List<DebugPropertyNode> getProperties();

  /// Returns a description with a short summary of the node itself not
  /// including children or properties.
  String toDescription();
}

class DebugBlock extends DebugPropertyNode {
  DebugBlock({
    super.name,
    bool showName = true,
    super.showSeparator,
    this.value,
    String? description,
    List<DebugPropertyNode> children = const [],
    List<DebugPropertyNode> properties = const [],
  })  : _description = description ?? '',
        _children = children,
        _properties = properties,
        super(
          showName: showName && name != null,
        );

  final List<DebugPropertyNode> _children;
  final List<DebugPropertyNode> _properties;

  final String _description;

  @override
  final Object? value;

  @override
  String? get tooltip => null;

  @override
  List<DebugPropertyNode> getChildren() => _children;

  @override
  List<DebugPropertyNode> getProperties() => _properties;

  @override
  String toDescription() => _description;
}

class DebugProperty<T> extends DebugPropertyNode {
  DebugProperty(
    String? name,
    this.value, {
    super.showName,
    super.showSeparator,
    this.description,
    this.ifNull,
    this.ifEmpty,
    this.defaultValue = kNoDefaultValue,
    this.tooltip,
  }) : super(name: name);

  /// The type of the property [value].
  Type get propertyType => T;

  @override
  final T? value;

  /// Description if the property [value] is null.
  final String? ifNull;

  /// Description if the property description would otherwise be empty.
  final String? ifEmpty;

  @override
  final String? tooltip;

  /// The default value of this property, when it has not been set to a specific
  /// value.
  ///
  /// The [defaultValue] is [kNoDefaultValue] by default. Otherwise it must be of
  /// type `T?`.
  final Object? defaultValue;

  final String? description;

  /// Returns a string representation of the property value.
  ///
  /// Subclasses should override this method instead of [toDescription] to
  /// customize how property values are converted to strings.
  String valueToString() {
    return value.toString();
  }

  @override
  String toDescription() {
    if (description != null) {
      return description!;
    }

    if (ifNull != null && value == null) {
      return ifNull!;
    }

    String result = valueToString();
    if (result.isEmpty && ifEmpty != null) {
      result = ifEmpty!;
    }
    return result;
  }

  @override
  List<DebugPropertyNode> getChildren() {
    final T? object = value;
    if (object is DebugPropertyNode) {
      return object.getChildren();
    }
    return const [];
  }

  @override
  List<DebugPropertyNode> getProperties() {
    final T? object = value;
    if (object is DebugPropertyNode) {
      return object.getProperties();
    }
    return const [];
  }
}

class DebugStringProperty extends DebugProperty<String> {
  /// Create a diagnostics property for strings.
  DebugStringProperty(
    String super.name,
    super.value, {
    super.description,
    super.tooltip,
    super.showName,
    super.defaultValue,
    this.quoted = true,
    super.ifEmpty,
    super.ifNull,
  });

  /// Whether the value is enclosed in double quotes.
  final bool quoted;

  @override
  String valueToString() {
    String? text = description ?? value;

    if (quoted && text != null) {
      // An empty value would not appear empty after being surrounded with
      // quotes so we have to handle this case separately.
      if (ifEmpty != null && text.isEmpty) {
        return ifEmpty!;
      }
      return '"$text"';
    }
    return text.toString();
  }
}

abstract class _DebugNumProperty<T extends num> extends DebugProperty<T> {
  _DebugNumProperty(
    String super.name,
    super.value, {
    super.ifNull,
    this.unit,
    super.showName,
    super.defaultValue,
    super.tooltip,
  });

  /// Optional unit the [value] is measured in.
  ///
  /// Unit must be acceptable to display immediately after a number with no
  /// spaces. For example: 'physical pixels per logical pixel' should be a
  /// [tooltip] not a [unit].
  final String? unit;

  /// String describing just the numeric [value] without a unit suffix.
  String numberToString();

  @override
  String valueToString() {
    if (value == null) {
      return value.toString();
    }

    return unit != null ? '${numberToString()}$unit' : numberToString();
  }
}

/// Property describing a [double] [value] with an optional [unit] of measurement.
///
/// Numeric formatting is optimized for debug message readability.
class DebugDoubleProperty extends _DebugNumProperty<double> {
  /// If specified, [unit] describes the unit for the [value] (e.g. px).
  DebugDoubleProperty(
    super.name,
    super.value, {
    super.ifNull,
    super.unit,
    super.tooltip,
    super.defaultValue,
    super.showName,
  });

  @override
  String numberToString() => debugFormatDouble(value);
}

/// An int valued property with an optional unit the value is measured in.
///
/// Examples of units include 'px' and 'ms'.
class DebugIntProperty extends _DebugNumProperty<int> {
  /// Create a diagnostics property for integers.
  DebugIntProperty(
    super.name,
    super.value, {
    super.ifNull,
    super.showName,
    super.unit,
    super.defaultValue,
  });

  @override
  String numberToString() => value.toString();
}

class DebugFlagProperty extends DebugProperty<bool> {
  /// Constructs a FlagProperty with the given descriptions with the specified descriptions.
  ///
  /// [showName] defaults to false as typically [ifTrue] and [ifFalse] should
  /// be descriptions that make the property name redundant.
  DebugFlagProperty(
    String name, {
    required bool? value,
    this.ifTrue,
    this.ifFalse,
    super.tooltip,
    bool showName = false,
    Object? defaultValue,
  })  : assert(ifTrue != null || ifFalse != null),
        super(
          name,
          value,
          showName: showName,
          defaultValue: defaultValue,
        );

  /// Description to use if the property [value] is true.
  final String? ifTrue;

  /// Description to use if the property value is false.
  final String? ifFalse;

  @override
  String valueToString() {
    if (value ?? false) {
      if (ifTrue != null) {
        return ifTrue!;
      }
    } else if (value == false) {
      if (ifFalse != null) {
        return ifFalse!;
      }
    }
    return super.valueToString();
  }

  @override
  bool get showName {
    if (value == null ||
        ((value ?? false) && ifTrue == null) ||
        (!(value ?? true) && ifFalse == null)) {
      // We are missing a description for the flag value so we need to show the
      // flag name. The property will have DiagnosticLevel.hidden for this case
      // so users will not see this the property in this case unless they are
      // displaying hidden properties.
      return true;
    }
    return super.showName;
  }
}

class DebugIterableProperty<T> extends DebugProperty<Iterable<T>> {
  /// Create a diagnostics property for iterables (e.g. lists).
  ///
  /// The [ifEmpty] argument is used to indicate how an iterable [value] with 0
  /// elements is displayed. If [ifEmpty] equals null that indicates that an
  /// empty iterable [value] is not interesting to display similar to how
  /// [defaultValue] is used to indicate that a specific concrete value is not
  /// interesting to display.
  DebugIterableProperty(
    String super.name,
    super.value, {
    super.defaultValue,
    super.ifNull,
    super.ifEmpty = '[]',
    super.showName,
    super.showSeparator,
  });

  @override
  String valueToString() {
    if (value == null) {
      return value.toString();
    }

    if (value!.isEmpty) {
      return ifEmpty ?? '[]';
    }

    final Iterable<String> formattedValues = value!.map((T v) {
      if (T == double && v is double) {
        return debugFormatDouble(v);
      } else {
        return v.toString();
      }
    });

    return formattedValues.join('\n');
  }
}

class DebugEnumProperty<T extends Enum?> extends DebugProperty<T> {
  /// Create a diagnostics property that displays an enum.
  DebugEnumProperty(
    String super.name,
    super.value, {
    super.defaultValue,
  });

  @override
  String valueToString() {
    if (value == null) {
      return value.toString();
    }
    return value!.name;
  }
}

class DataCard extends StatelessWidget {
  final bool selected;
  final GestureTapCallback? onTap;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const DataCard({
    super.key,
    this.selected = false,
    this.onTap,
    this.constraints,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Widget card = Card(
      elevation: themeData.useMaterial3 ? null : 0.0,
      color: selected ? themeData.colorScheme.secondaryContainer : null,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: selected
            ? BorderSide(color: themeData.colorScheme.secondary)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (constraints != null) {
      card = ConstrainedBox(
        constraints: constraints!,
        child: card,
      );
    }

    return card;
  }
}

class InfoCard extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget child;

  const InfoCard({
    super.key,
    required this.title,
    this.actions = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DataCard(
      padding: const EdgeInsets.only(
        left: 16,
        right: 4.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                  ),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleLarge,
                    child: title,
                  ),
                ),
              ),
              ...actions,
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 16,
              right: 16 - 4.5,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
