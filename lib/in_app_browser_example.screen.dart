import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'drawer.dart'; // Ensure this file exists in your project

class InAppBrowserExampleScreen extends StatefulWidget {
  const InAppBrowserExampleScreen({super.key});

  @override
  _InAppBrowserExampleScreenState createState() =>
      _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  late InAppWebViewController webViewController;
  double _progress = 0.0; // Progress to track loading
  _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Exit App"),
              content: Text("Are you sure you want to exit the app?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Stay in the app
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Exit the app
                  },
                  child: Text(
                    "Exit",
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed
  }

  static void downloadCallback(String id, int status, int progress) {
    DownloadTaskStatus taskStatus = DownloadTaskStatus.values[status];

    if (taskStatus == DownloadTaskStatus.enqueued ||
        taskStatus == DownloadTaskStatus.running) {
      // Handle enqueued or running status
    }

    if (taskStatus == DownloadTaskStatus.complete) {
      // Open file when the download is complete
    }
  }

  bool isConnected = true;
  bool _isDialogOpen = false;
  bool isFirst = true;
  late PullToRefreshController _pullToRefreshController;
  @override
  void initState() {
    _startConnectionChecker();
    FlutterDownloader.registerCallback(downloadCallback);
    loadWebViewPullToRefresh();

    super.initState();
  }

  loadWebViewPullToRefresh() async {
    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue, // Set the color of the refresh indicator
      ),
      onRefresh: () async {
        // Reload the webview
        await webViewController.reload();
        // Notify the controller that the refresh is complete
        _pullToRefreshController.endRefreshing();
      },
    );
  }

  Future<void> _downloadFile(String url) async {
    await requestPermissions();

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: '/storage/emulated/0/Download',
      // savedDir: savePath,
      showNotification: true, // Show notification
      openFileFromNotification: true, // Open file when the download is complete
    );
  }

  Future<void> requestPermissions() async {
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isDenied) {
      // Handle permission denied case
      if (await Permission.storage.request().isDenied) {
        // Show a dialog or notification that the permission is required
      }
    }
    var notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      if (await Permission.notification.request().isDenied) {
        // Handle the scenario where notification permission is denied
      }
    }
  }

  final connectionChecker = InternetConnectionChecker.instance;
  _startConnectionChecker() async {
    connectionChecker.onStatusChange.listen(
      (InternetConnectionStatus status) {
        if (status == InternetConnectionStatus.connected) {
          isConnected = true;
        } else {
          isConnected = false;
        }
        if (!isConnected) {
          showNoInternetDialog();
        } else {
          if (_isDialogOpen == true) {
            _isDialogOpen = false;
            Navigator.of(context).pop();
            setState(() {});
          }
        }
      },
    );
  }

  @override
  void dispose() {
    connectionChecker.dispose();
    super.dispose();
  }

  void showNoInternetDialog() {
    if (!_isDialogOpen) {
      // Only show dialog if it's not already open
      setState(() {
        _isDialogOpen = true; // Mark dialog as open
      });
    }
    showDialog(
      context: context,
      barrierDismissible: false, // Non-dismissible dialog
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Internet Connection",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "বিউটিফুল ভালুকা স্মার্ট অ্যাপের সেবা পেতে ইন্টারনেট সংযোগ চালু করুন",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Solaiman Lipi',
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            OpenSettingsPlusAndroid().wifi();
                          },
                          icon: Icon(Icons.wifi),
                          label: Text("Enable Wi-Fi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            OpenSettingsPlusAndroid().dataUsage();
                          },
                          icon: Icon(Icons.signal_cellular_alt),
                          label: Text("Enable Data"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool isBack = await webViewController.canGoBack();
        if (isBack) {
          webViewController.goBack();
          return false;
        } else {
          return await _showExitConfirmationDialog(context);
        }

        // Show an exit confirmation dialog
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 22, 136, 128),
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text(
            "Beautiful Bhaluka",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
        drawer: DrawerPage(),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Progress bar to indicate loading

            _isDialogOpen
                ? Center()
                : InAppWebView(
                    initialUrlRequest: URLRequest(
                        url: WebUri("https://beautifulbhaluka.com/")),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    pullToRefreshController: _pullToRefreshController,
                    initialSettings: InAppWebViewSettings(
                      allowUniversalAccessFromFileURLs: true,
                      clearCache: true,
                      javaScriptEnabled: true,
                      allowContentAccess: true,
                      allowFileAccess: true,
                      supportZoom: true, // Allow zooming
                      mediaPlaybackRequiresUserGesture: false,
                      javaScriptCanOpenWindowsAutomatically: true,
                    ),
                    onLoadStart: (controller, url) {
                      setState(() {
                        _progress = 0.0; // Reset progress on load start
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        _progress =
                            1.0; // Set progress to 100% when loading is complete
                      });
                      _pullToRefreshController.endRefreshing();
                      isFirst = false;
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        _progress =
                            progress / 100.0; // Update progress dynamically
                      });
                    },
                    onDownloadStartRequest: (controller, url) async {
                      // Trigger file download
                      _downloadFile(url.url.toString());
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final uri = navigationAction.request.url!;
                      if (uri.scheme == 'http' || uri.scheme == 'https') {
                        // Allow navigation within the web view
                        return NavigationActionPolicy.ALLOW;
                      } else if (await canLaunchUrl(uri)) {
                        // Handle external links (e.g., mailto, tel)
                        await launchUrl(uri);
                        return NavigationActionPolicy.CANCEL;
                      }
                      return NavigationActionPolicy.CANCEL;
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint(
                          "JavaScript Console: ${consoleMessage.message}");
                    },
                  ),
            if (isFirst)
              Positioned(
                  child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Please Wait....",
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 22),
                          )
                        ],
                      ))),

            if (_progress < 1.0 && !isFirst)
              LinearProgressIndicator(value: _progress)
          ],
        ),
      ),
    );
  }
}
