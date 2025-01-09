import 'dart:io';

import 'package:beautiful_bhaluka/in_app_browser_example.screen.dart';
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

      const String channelUrl =
          "youtube://www.youtube.com/@bbhaluka"; // Deep link for YouTube app
      const String fallbackUrl =
          "https://www.youtube.com/@bbhaluka"; // Fallback URL for browser

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

    /// Opens a YouTube video by URL
    Future<void> shareApp() async {
      Share.share(
          'Check out this বিউটিফুল ভালুকা app! Download it here: https://play.google.com/store/apps/details?id=com.devsvally.beautifullbhaluka',
          subject: 'বিউটিফুল ভালুকা');
    }

    /// Opens a YouTube video by URL
    Future<void> rateUs() async {
      const url =
          'https://play.google.com/store/apps/details?id=com.devsvally.beautifullbhaluka'; // Replace with your app's package name
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the app store')),
        );
      }
    }

    return NavigationDrawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      children: [
        Column(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 120,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'বিউটিফুল ভালুকা স্মার্ট অ্যাপ একের ভিতর সব। ভালুকার প্রয়োজনীয় সব কিছু এখন বিউটিফুল ভালুকা স্মার্ট অ্যাপে।',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'Solaiman Lipi'),
              ),
            )
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(
            FontAwesomeIcons.house,
            color: Colors.grey,
          ),
          title: Text('HOME'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const InAppBrowserExampleScreen(), // Replace with your next screen widget
              ),
            );
          },
        ),

        // Notifications Toggle

        ListTile(
          leading: const Icon(
            FontAwesomeIcons.facebook,
            color: Colors.grey,
          ),
          title: Text(
            'Facebook Page',
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 15,
          ),
          onTap: () {
            Navigator.of(context).pop();
            openFacebook('beautifulbhaluka2');
          },
        ),

        ListTile(
          leading: const Icon(
            FontAwesomeIcons.facebook,
            color: Colors.grey,
          ),
          title: Text(
            'Facebook Page 2.0',
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 15,
          ),
          onTap: () {
            Navigator.of(context).pop();
            openFacebook('beautifulbhaluka4');
          },
        ),

        ListTile(
          leading: const Icon(
            FontAwesomeIcons.youtube,
            color: Colors.grey,
          ),
          title: Text(
            'Youtube',
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.of(context).pop();
            openYouTube('https://www.youtube.com/@bbhaluka');
          },
        ),

        ListTile(
          leading: const Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.grey,
          ),
          title: Text(
            'Whatsapp',
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.of(context).pop();
            openWhatsApp('+18053159616');
          },
        ),

        // ListTile(
        //   leading: const Icon(
        //     FontAwesomeIcons.info,
        //     color: Colors.grey,
        //   ),
        //   onTap: () {},
        //   title: Text(
        //     'App Info',
        //   ),
        //   trailing: const Icon(
        //     Icons.arrow_forward_ios,
        //     color: Colors.grey,
        //     size: 15,
        //   ),
        // ),

        ListTile(
          leading: Icon(
            FontAwesomeIcons.share,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.of(context).pop();
            shareApp();
          },
          title: Text(
            'Share App',
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 15,
          ),
        ),

        ListTile(
          leading: const Icon(
            FontAwesomeIcons.star,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.of(context).pop();
            rateUs();
          },
          title: Text(
            'Rate Us',
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 15,
          ),
        ),

        // Logout
        ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.redAccent,
          ),
          title: Text(
            'Exit',
          ),
          onTap: () {
            // Add logout functionality
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      exit(0);
                      // Perform logout operation
                      // Navigator.of(context).pop();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
