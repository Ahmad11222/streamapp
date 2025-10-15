import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';

class NotificationDetails extends StatefulWidget {
  final String title;
  final String details;
  final String imageLink;
  NotificationDetails(
      {required this.title, required this.details, required this.imageLink});
  @override
  State<NotificationDetails> createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {
  void _handleURLClick(String url) async {
    launchUrlString(url);
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  TextSpan _buildTextWithLinks(String text) {
    final RegExp urlRegExp = RegExp(
      r'((https?:\/\/)?([a-zA-Z0-9.-]+)\.[a-zA-Z]{2,}(\/\S*)?)',
      caseSensitive: false,
    );

    final List<TextSpan> children = [];
    text.splitMapJoin(
      urlRegExp,
      onMatch: (Match match) {
        final String url = match.group(0)!;
        children.add(
          TextSpan(
            text: url,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _handleURLClick(url),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        children.add(
            TextSpan(text: nonMatch, style: TextStyle(color: myMainColor)));
        return '';
      },
    );

    return TextSpan(children: children);
  }

  void _openImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: PhotoView(
            imageProvider: NetworkImage(imageUrl),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    print(widget.imageLink);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(titleText: 'annoucment'.tr),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                widget.imageLink == ''
                    ? Container()
                    : GestureDetector(
                        onTap: () => _openImage(context, widget.imageLink),
                        child: myImage(
                          imageSource: 'url',
                          imagePath: widget.imageLink,
                          height: 150,
                          width: double.infinity,
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                myLable(text: widget.title, textSize: 14),
                SizedBox(
                  height: 10,
                ),
                RichText(
                  text: _buildTextWithLinks(widget.details),
                ),
                // myLable(text: widget.details, textSize: 12)
              ],
            ),
          ),
        ));
  }
}
