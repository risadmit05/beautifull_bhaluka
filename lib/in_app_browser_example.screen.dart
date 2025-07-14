import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'drawer.dart';

class InAppBrowserExampleScreen extends StatefulWidget {
  const InAppBrowserExampleScreen({super.key});

  @override
  State<InAppBrowserExampleScreen> createState() =>
      _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  late InAppWebViewController webViewController;
  double _progress = 0.0;
  bool isConnected = true;
  bool _isDialogOpen = false;
  bool isFirst = true;
  late PullToRefreshController _pullToRefreshController;
  final connectionChecker = InternetConnectionChecker.createInstance();

  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);
    _startConnectionChecker();
    _initPullToRefresh();
  }

  static void downloadCallback(String id, int status, int progress) {
    if (DownloadTaskStatus.values[status] == DownloadTaskStatus.complete) {
      // File downloaded
    }
  }

  void _initPullToRefresh() {
    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        await webViewController.reload();
        _pullToRefreshController.endRefreshing();
      },
    );
  }

  Future<void> _downloadFile(String url) async {
    await _requestPermissions();
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: '/storage/emulated/0/Download',
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _startConnectionChecker() {
    connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        if (_isDialogOpen) {
          _isDialogOpen = false;
          Navigator.of(context).pop();
        }
        setState(() => isConnected = true);
      } else {
        setState(() => isConnected = false);
        _showNoInternetDialog();
      }
    });
  }

  void _showNoInternetDialog() {
    if (_isDialogOpen) return;

    setState(() => _isDialogOpen = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 60, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text("No Internet Connection",
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Text(
                "বিউটিফুল ভালুকা স্মার্ট অ্যাপের সেবা পেতে ইন্টারনেট সংযোগ চালু করুন",
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Solaiman Lipi',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: OpenSettingsPlusAndroid().wifi,
                      icon: const Icon(Icons.wifi),
                      label: const Text("Enable Wi-Fi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: OpenSettingsPlusAndroid().dataUsage,
                      icon: const Icon(Icons.signal_cellular_alt),
                      label: const Text("Enable Data"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return false;
    }
    return await _showExitConfirmationDialog();
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Exit")),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    connectionChecker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF168880),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Beautiful Bhaluka",
              style: TextStyle(color: Colors.white)),
        ),
        drawer: DrawerPage(),
        body: Stack(
          children: [
            if (!_isDialogOpen)
              InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri("https://beautifulbhaluka.com/")),
                onWebViewCreated: (controller) =>
                    webViewController = controller,
                pullToRefreshController: _pullToRefreshController,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportZoom: true,
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptCanOpenWindowsAutomatically: true,
                ),
                onLoadStart: (_, __) => setState(() => _progress = 0.0),
                onLoadStop: (_, __) {
                  setState(() => _progress = 1.0);
                  _pullToRefreshController.endRefreshing();
                  isFirst = false;
                },
                onProgressChanged: (_, progress) =>
                    setState(() => _progress = progress / 100),
                onDownloadStartRequest: (_, url) =>
                    _downloadFile(url.url.toString()),
                shouldOverrideUrlLoading: (_, navAction) async {
                  final uri = navAction.request.url!;
                  if (["http", "https"].contains(uri.scheme))
                    return NavigationActionPolicy.ALLOW;
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.CANCEL;
                },
                onConsoleMessage: (_, msg) =>
                    debugPrint("Console: ${msg.message}"),
              ),
            if (isFirst)
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                          strokeWidth: 4, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 10),
                    Text("Loading...",
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 18)),
                  ],
                ),
              ),
            if (_progress < 1.0 && !isFirst)
              LinearProgressIndicator(
                  value: _progress, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
