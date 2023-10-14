// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvertisementBanner extends StatelessWidget {
  final String title;
  final String subTitle;
  final String url;
  final String mobile;
  const AdvertisementBanner({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.url,
    required this.mobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (url.isNotEmpty) {
          await launchUrl(
            Uri(scheme: 'https', path: url),
          );
        }

        // await launchUrl(
        //   Uri(scheme: 'tel', path: mobile),
        // );
      },
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0061ff),
              Color(0xFF60efff)
            ], // Gradient background color
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          trailing: GestureDetector(
            onTap: () async {
              if (mobile.isNotEmpty) {
                await launchUrl(
                  Uri(scheme: 'tel', path: mobile),
                );
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(
                Icons.call,
                color: Colors.black,
              ),
            ),
          ),
          subtitle: Text(
            subTitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
