import 'dart:io';

import 'package:beautiful_bhaluka/in_app_browser_example_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// Opens a Facebook URL
    /// Opens a Facebook page in the Facebook app or browser
    Future<void> openFacebook(String username) async {
      try {
        // Attempt to open in the Facebook app using the fallback web URL
        final Uri facebookAppUri = Uri.parse(
            "fb://facewebmodal/f?href=https://facebook.com/$username");
        if (!await launchUrl(facebookAppUri,
            mode: LaunchMode.externalApplication)) {
          throw Exception('Could not open in Facebook app');
        }
      } catch (e) {
        // Fallback to opening in the browser
        final Uri facebookWebUri = Uri.parse("https://facebook.com/$username");
        if (!await launchUrl(facebookWebUri)) {
          throw Exception('Could not open Facebook');
        }
      }
    }

    /// Opens WhatsApp with a specific phone number
    Future<void> openWhatsApp(String phoneNumber) async {
      final Uri whatsappUri = Uri.parse("whatsapp://send?phone=$phoneNumber");
      final Uri fallbackUri = Uri.parse("https://wa.me/$phoneNumber");

      // Try to open in WhatsApp app
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to opening in the browser
        if (!await launchUrl(fallbackUri,
            mode: LaunchMode.externalApplication)) {
          throw Exception('Could not open WhatsApp');
        }
      }
    }

    /// Opens a YouTube video by URL
    Future<void> openYouTube(String videoUrl) async {
      /// Opens the YouTube app for a specific channel

      const String channelUrl = "youtube://www.youtube.com/@bbhaluka";
      const String fallbackUrl = "https://www.youtube.com/@bbhaluka";

      // Check if the YouTube app can handle the URL
      if (await canLaunchUrl(Uri.parse(channelUrl))) {
        await launchUrl(Uri.parse(channelUrl),
            mode: LaunchMode.externalApplication);
      } else {
        // Open in browser if YouTube app is not available
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      }
    }

    Future<void> openChrome() async {
      /// Opens the YouTube app for a specific channel

      const String url =
          "https://beautifulbhaluka.com/"; // Fallback URL for browser

      // Check if the YouTube app can handle the URL
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Open in browser if YouTube app is not available
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }

    /// Opens a YouTube video by URL
    Future<void> shareApp() async {
      Share.share(
          'Check out this বিউটিফুল ভালুকা app! Download it here: https://play.google.com/store/apps/details?id=com.devsvally.beautifullbhaluka',
          subject: 'বিউটিফুল ভালুকা');
    }

    /// Opens a YouTube video by URL
    Future<void> rateUs() async {
      const url =
          'https://play.google.com/store/apps/details?id=com.devsvally.beautifullbhaluka';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the app store')),
        );
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with logo and description
          buildHeader(context, isDark),
          const SizedBox(height: 10),

          // Main navigation items
          buildTile(
            context,
            icon: FontAwesomeIcons.house,
            title: 'HOME',
            onTap: () => navigateToHome(context),
          ),
          buildTile(
            context,
            icon: FontAwesomeIcons.chrome,
            title: 'Visit Website',
            onTap: openChrome,
          ),

          // Social media section
          buildSectionHeader('Connect With Us'),
          buildSocialTile(
            context,
            icon: FontAwesomeIcons.facebook,
            title: 'Facebook Page',
            color: const Color(0xFF1877F2),
            onTap: () => openFacebook('beautifulbhaluka2'),
          ),
          buildSocialTile(
            context,
            icon: FontAwesomeIcons.facebook,
            title: 'Facebook Page 2.0',
            color: const Color(0xFF1877F2),
            onTap: () => openFacebook('beautifulbhaluka4'),
          ),
          buildSocialTile(
            context,
            icon: FontAwesomeIcons.youtube,
            title: 'YouTube',
            color: const Color(0xFFFF0000),
            onTap: () => openYouTube,
          ),
          buildSocialTile(
            context,
            icon: FontAwesomeIcons.whatsapp,
            title: 'WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () => openWhatsApp('+18053159616'),
          ),

          // App actions section
          buildSectionHeader('App Actions'),
          buildTile(
            context,
            icon: FontAwesomeIcons.share,
            title: 'Share App',
            onTap: shareApp,
          ),
          buildTile(
            context,
            icon: FontAwesomeIcons.star,
            title: 'Rate Us',
            onTap: () => rateUs(),
          ),

          // Exit button
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: buildExitButton(context),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey[800] : const Color(0xFF168880),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              // color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'বিউটিফুল ভালুকা',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Solaiman Lipi',
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'ভালুকার প্রয়োজনীয় সব কিছু এখন বিউটিফুল ভালুকা স্মার্ট অ্যাপে',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Solaiman Lipi',
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Solaiman Lipi',
              fontWeight: FontWeight.w400,
              wordSpacing: 1.1)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      minLeadingWidth: 5,
    );
  }

  Widget buildSocialTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, size: 20, color: color),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Solaiman Lipi',
              fontWeight: FontWeight.w400,
              wordSpacing: 1.1)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      minLeadingWidth: 5,
    );
  }

  Widget buildExitButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.red),
      title: const Text('Exit',
          style: TextStyle(
              color: Colors.red,
              fontSize: 15,
              fontFamily: 'Solaiman Lipi',
              fontWeight: FontWeight.w600,
              wordSpacing: 1.1)),
      onTap: () => showExitDialog(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
    );
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void navigateToHome(BuildContext context) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 250), () {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const InAppBrowserExampleScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
        (route) => false,
      );
    });
  }
}
