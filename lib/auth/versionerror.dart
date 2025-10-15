import 'dart:io';
import '../global/globalConfig.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/globalWidgets.dart';

late bool _AboutAppError;
late List _tearms;

class versionerror extends StatefulWidget {
  String androidLink;
  String iosLinlk;
  versionerror({required this.androidLink, required this.iosLinlk}) {}
  @override
  _versionerrorState createState() => _versionerrorState();
}

class _versionerrorState extends State<versionerror> {
  @override
  void initState() {}

  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage('images/mofaBG.png'),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Scaffold(
        body: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                  border: Border.all(color: mySubColor),
                  color: mySubColor,
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Icon(FontAwesomeIcons.triangleExclamation,
                        size: 100, color: myWhiteColor),
                    SizedBox(
                      height: 20,
                    ),
                    myLable(
                      text: 'Update the mobile app',
                      maxline: 4,
                      textSize: 16,
                      textColor: myWhiteColor,
                      isbold: true,
                      iscenter: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    myButton(
                        buttonType: 'simple',
                        text: //'updatApp'.tr,
                            'اضغط للتحديث  Click to update',
                        textSize: 18,
                        bordercolor: myBlackColor,
                        buttonColor: myWhiteColor,
                        textColor: mySubColor,
                        onpressed: () async {
                          try {
                            if (Platform.isIOS) {
                              if (!await launchUrl(Uri.parse(widget.iosLinlk),
                                  mode: LaunchMode.externalApplication)) {
                                throw Exception('Could not launch');
                              }
                            } else if (Platform.isAndroid) {
                              if (!await launchUrl(
                                  Uri.parse(widget.androidLink),
                                  mode: LaunchMode.externalApplication)) {
                                throw Exception('Could not launch');
                              }
                            }
                          } catch (e) {}
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
