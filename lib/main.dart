import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:platform_device_id_v3/platform_device_id.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unique_identifier/unique_identifier.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Data',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Device Data'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var deviceData = <String, dynamic>{};

  Future<void> fetchData() async {
    // final platformDeviceId = await PlatformDeviceId.getDeviceId;

    final identifier = await UniqueIdentifier.serial;

    final advertisingId = await AdvertisingId.id(true);
    final isLimitAdTrackingEnabled =
        await AdvertisingId.isLimitAdTrackingEnabled;

    final isDeviceRooted = await FlutterJailbreakDetection.jailbroken;

    final battery = Battery();

    final batteryLevel = await battery.batteryLevel;
    final isInBatterySaveMode = await battery.isInBatterySaveMode;
    final batteryStatus = await battery.batteryState;

    var deviceInfo = Platform.isAndroid
        ? await _readAndroidBuildData()
        : Platform.isIOS
            ? await _readIosDeviceInfo()
            : null;

    setState(() {
      deviceData = <String, dynamic>{
        // 'platformDeviceId': platformDeviceId,
        'uniqueIdentifier': identifier,
        'advertisingId': advertisingId,
        'isLimitAdTrackingEnabled': isLimitAdTrackingEnabled,
        'isDeviceRooted': isDeviceRooted,
        'batteryLevel': batteryLevel,
        'isInBatterySaveMode': isInBatterySaveMode,
        'batteryStatus': batteryStatus.toString(),
        if (deviceInfo != null) ...deviceInfo,
      };
    });
  }

  Future<Map<String, dynamic>> _readAndroidBuildData() async {
    final build = await DeviceInfoPlugin().androidInfo;

    return <String, dynamic>{
      'release': build.version.release,
      'sdkInt': build.version.sdkInt,
      'previewSdkInt': build.version.previewSdkInt,
      'incremental': build.version.incremental,
      'baseOS': build.version.baseOS,
      'codename': build.version.codename,
      'securityPatch': build.version.securityPatch,
      'board': build.board,
      'bootloader': build.bootloader,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'deviceId': build.id,
      'tags': build.tags,
      'displayMetrics': build.displayMetrics.toString(),
      'serialNumber': build.serialNumber,
      'brand': build.brand,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'device': build.device,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          (build.displayMetrics.sizeInches * 10).roundToDouble() / 10,
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
    };
  }

  Future<Map<String, dynamic>> _readIosDeviceInfo() async {
    final data = await DeviceInfoPlugin().iosInfo;

    return <String, dynamic>{
      'ios_name': data.name,
      'ios_systemName': data.systemName,
      'ios_systemVersion': data.systemVersion,
      'ios_model': data.model,
      'ios_localizedModel': data.localizedModel,
      'ios_identifierForVendor': data.identifierForVendor,
      'ios_isPhysicalDevice': data.isPhysicalDevice,
      'ios_utsname.sysname:': data.utsname.sysname,
      'ios_utsname.nodename:': data.utsname.nodename,
      'ios_utsname.release:': data.utsname.release,
      'ios_utsname.version:': data.utsname.version,
      'ios_utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> shareData() async {
    await fetchData().then((_) async {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/device_data.txt');
      await file.writeAsString(deviceData.toString());
      await Share.shareXFiles([XFile(file.path)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: fetchData,
                  child: const Text('Get Device Data'),
                ),
                ElevatedButton(
                  onPressed: shareData,
                  child: const Text('Share Device Data'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...deviceData.entries.map(
              (e) => Row(
                children: [
                  Text(
                    '${e.key}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(child: Text(e.value.toString())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
