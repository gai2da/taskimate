import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';

import '../managers/theme_Manager.dart';

class Resources extends StatelessWidget {
  final List<Map<String, String>> resources = [
    {
      "title": "ADHD Power Tools (YouTube)",
      "image": "assets/logoYoutube.png",
      "description": "\nA YouTube playlist with practical ADHD advice.",
      "url":
          "https://www.youtube.com/playlist?list=PLwIWvBSZXR4agGgS5b7dvbvZ0ayTXHqwQ"
    },
    {
      "title": "ADHD Alien (Comics)",
      "image": "assets/adhdAlien.jpg",
      "description":
          "\nA collection of comic strips about the emotional aspects of ADHD.",
      "url": "https://adhd-alien.com/"
    },
    {
      "title": "ADHD Adult UK (Resources)",
      "image": "assets/adhdadultUK.png",
      "description":
          "\nA comprehensive collection of ADHD resources, including expert advice and practical tools.",
      "url": "https://www.adhdadult.uk/resources/"
    },
    {
      "title": "ADHD UK (Resources)",
      "image": "assets/adhduk.png",
      "description":
          "\nA collection of helpful resources and support for individuals with ADHD.",
      "url": "https://adhduk.co.uk/adhd-useful-resources/"
    }
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      SemanticsService.announce("Opening ${uri.toString()}", TextDirection.ltr);
    } else {
      print('could not open url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Resources",
        style: TextStyle(
          fontSize: themeManager.fontSize,
          fontWeight: FontWeight.bold,
        ),
      )),
      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];

          return Semantics(
            button: true,
            label: "Open ${resource["title"]}",
            child: GestureDetector(
              onTap: () => _launchURL(resource["url"]!),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              label: resource["title"],
                              child: Text(
                                resource["title"]!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Semantics(
                              label: "Description: ${resource["description"]}",
                              child: Text(
                                resource["description"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          resource["image"]!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
