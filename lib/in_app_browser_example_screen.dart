import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen>
    with SingleTickerProviderStateMixin {
  late InAppWebViewController webViewController;
  double _progress = 0.0;
  bool _isConnected = true;
  bool _isDialogOpen = false;
  bool _isInitialLoading = true;
  bool _showAppBar = true;
  late PullToRefreshController _pullToRefreshController;
  final connectionChecker = InternetConnectionChecker.createInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _loadingController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);
    _startConnectionChecker();
    _initPullToRefresh();
    _initLoadingAnimation();
  }

  void _initLoadingAnimation() {
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50.0),
    ]).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _textAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _loadingController.repeat(reverse: true);
  }

  static void downloadCallback(String id, int status, int progress) {
    if (DownloadTaskStatus.values[status] == DownloadTaskStatus.complete) {
      // Handle downloaded file
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
      final isConnected = status == InternetConnectionStatus.connected;
      if (_isConnected != isConnected) {
        setState(() => _isConnected = isConnected);
      }

      if (!isConnected && !_isDialogOpen) {
        _isDialogOpen = true;
        _showNoInternetDialog();
      } else if (isConnected && _isDialogOpen) {
        _isDialogOpen = false;
        Navigator.of(context).pop();
      }
    });
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("No Internet Connection"),
        content: const Text("Please connect to the internet."),
        actions: [
          TextButton(
            onPressed: OpenSettingsPlusAndroid().wifi,
            child: const Text("Enable Wi-Fi"),
          ),
          TextButton(
            onPressed: OpenSettingsPlusAndroid().dataUsage,
            child: const Text("Enable Data"),
          ),
        ],
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
            title: const Text("Exit App?"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _toggleAppBarVisibility() {
    setState(() => _showAppBar = !_showAppBar);
  }

  @override
  void dispose() {
    connectionChecker.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _showAppBar
            ? AppBar(
                backgroundColor: const Color(0xFF168880),
                title: Text(
                  "Beautiful Bhaluka",
                  style: const TextStyle(
                    fontFamily: 'SolaimanLipi',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(FontAwesomeIcons.bars,
                      color: Colors.white, size: 30),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Colors.white, size: 30),
                    onPressed: () => webViewController.reload(),
                  ),
                  if (_showAppBar)
                    IconButton(
                      icon: const Icon(Icons.fullscreen,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        _toggleAppBarVisibility();
                      },
                    ),
                ],
              )
            : null,
        drawer: const DrawerPage(),
        body: Stack(
          children: [
            if (!_isDialogOpen)
              Padding(
                padding: EdgeInsets.only(top: _showAppBar ? 0.0 : 56.0),
                child: InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: WebUri("https://beautifulbhaluka.com/")),
                  onWebViewCreated: (controller) =>
                      webViewController = controller,
                  pullToRefreshController: _pullToRefreshController,
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    supportZoom: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  onLoadStart: (_, __) {
                    if (_progress == 0.0) {
                      setState(() {
                        _isInitialLoading = true;
                      });
                    }
                  },
                  onLoadStop: (_, __) {
                    setState(() {
                      _progress = 1.0;
                      if (_isInitialLoading) {
                        _isInitialLoading = false;
                      }
                    });
                    _pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (_, progress) =>
                      setState(() => _progress = progress / 100),
                  onDownloadStartRequest: (_, url) =>
                      _downloadFile(url.url.toString()),
                  shouldOverrideUrlLoading: (_, navAction) async {
                    final uri = navAction.request.url!;
                    if (["http", "https"].contains(uri.scheme)) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.CANCEL;
                  },
                ),
              ),

            // Show full screen animated loader ONLY for first page load
            if (_isInitialLoading)
              Container(
                color: const Color(0xFF168880),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _logoAnimation.value,
                          child: child,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                color: Colors.black.withOpacity(0.2),
                              )
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: 70,
                            width: 70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _textAnimation,
                        child: const Text(
                          "Beautiful Bhaluka",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Slim progress bar on top for all loads
            if (_progress < 1.0 && !_isInitialLoading)
              Positioned(
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * _progress,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF168880), Color(0xFF4DB6AC)],
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: _showAppBar
            ? SizedBox.shrink()
            : FloatingActionButton(
                onPressed: () {
                  _toggleAppBarVisibility();
                },
                tooltip: 'Toggle AppBar',
                backgroundColor: const Color(0xFF168880),
                child: Icon(
                  _showAppBar ? Icons.fullscreen : Icons.fullscreen_exit,
                  color: Colors.white,
                  size: 35,
                ),
              ),
      ),
    );
  }
}
