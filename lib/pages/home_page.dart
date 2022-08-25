import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? webView;

  String? appVersion;
  String? deviceId;

  bool isLoaded = false;

  void getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
    ].request();

    if (await Permission.locationWhenInUse.isPermanentlyDenied) {
      openAppSettings();
    }
    if (await Permission.camera.isPermanentlyDenied) {
      openAppSettings();
    }
    if (await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void getApplocationDetail() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String? id;

    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      id = androidDeviceInfo.id; // unique ID on Android
    }

    setState(() {
      appVersion = '${packageInfo.version}.${packageInfo.buildNumber}';
      isLoaded = true;
      deviceId = id;
    });
  }

  @override
  void initState() {
    super.initState();

    getPermission();
    getApplocationDetail();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: isLoaded
              ? InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        "https://osas.saptasarana.net?version=$appVersion&device_id=$deviceId"),
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      supportZoom: false,
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  androidOnGeolocationPermissionsShowPrompt:
                      (InAppWebViewController controller, String origin) async {
                    return GeolocationPermissionShowPromptResponse(
                        origin: origin, allow: true, retain: true);
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
