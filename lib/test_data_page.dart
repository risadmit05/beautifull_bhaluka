import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2), () {});
        },
        child: ListView(
          children: [
            Text('ksdjfjksfkjhskjdfhskjhfhs'),
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://beautifulbhaluka.com/"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
