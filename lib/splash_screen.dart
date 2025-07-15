import 'package:beautiful_bhaluka/in_app_browser_example_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3 seconds and then navigate to the next screen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const InAppBrowserExampleScreen(), // Replace with your next screen widget
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
            Center(
              child: Text(
                'বিউটিফুল ভালুকার স্মার্ট অ্যাপে আপনাকে স্বাগতম',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'Solaiman Lipi'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Version:1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
