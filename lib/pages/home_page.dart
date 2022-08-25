import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? webView;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (await webView!.canGoBack()) {
        //   // get the webview history
        //   WebHistory? webHistory = await webView!.getCopyBackForwardList();
        //   // if webHistory.currentIndex corresponds to 1 or 0
        //   if (webHistory!.currentIndex! <= 1) {
        //     // then it means that we are on the first page
        //     // so we can exit
        //     return true;
        //   }
        //   webView!.goBack();
        //   return false;
        // }
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse("https://osas.saptasarana.net/"),
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
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
          ),
        ),
      ),
    );
  }
}
