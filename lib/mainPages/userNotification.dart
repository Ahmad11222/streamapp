import 'dart:convert';

import '../global/globalWidgets.dart';
import '../global/globalConfig.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../auth/AppUser.dart';
import 'NotificationDetails.dart';
import 'myNav.dart';

final AppUser _auth = Get.find();
late List _notificationlist;
late bool _notificationloading;

class userNotification extends StatefulWidget {
  bool showAppBar;
  userNotification({required this.showAppBar});

  @override
  State<userNotification> createState() => _userNotificationState();
}

class _userNotificationState extends State<userNotification> {
  Future updateNotification() async {
    var _savedtoken = await getLocalData('token');
    try {
      final resp = await http.put(
        Uri.parse(myMainAPILink + 'updateunseennotif'),
        headers: {
          'Accept': 'application/json',
          'username': _auth.getUserName(),
          'ctoken': _savedtoken
        },
      );
    } catch (e) {}
  }

  Future updateActiveNotification({required String syncID}) async {
    String _savedToken = await getLocalData('token');
    String _savedUsername = await getLocalData('username');
    try {
      final resp = await http.put(
        Uri.parse(myIntegrationAPILink + 'updateactivenoti'),
        headers: {
          'Accept': 'application/json',
          'username': _savedUsername,
          'ctoken': _savedToken,
          'syncid': syncID
        },
      );
    } catch (e) {}
  }

  Future getnotifications() async {
    String _savedToken = await getLocalData('token');
    String _savedUsername = await getLocalData('username');
    try {
      print(myIntegrationAPILink + 'getusernotification');
      final resp = await http.get(
        Uri.parse(myIntegrationAPILink + 'getusernotification'),
        headers: {
          'Accept': 'application/json',
          'username': _savedUsername,
          'usertoken': _savedToken
        },
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));

      return result['items'];
    } catch (e) {
      return [];
    }
  }

  Widget notificationlist(List data) {
    return ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Dismissible(
            direction: DismissDirection.endToStart,
            key: Key(data[index]['syncid']
                .toString()), // Provide a unique key for each item
            onDismissed: (direction) {
              // Remove the item from the data source
              updateActiveNotification(
                  syncID: data[index]['syncid'].toString());
              setState(() {
                data.removeAt(index);
              });
            },
            background: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: myFailedColor),
                // Background color when swiping
                child: Icon(Icons.delete, color: Colors.white),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
              ),
            ),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: myWhiteColor,
                        // border: Border.all(color: myMidGreyColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: myLine(
                          isVerticalTop: true,
                          isStart: true,
                          widgetsList: [
                            Container(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                myLable(
                                  text: data[index]['title'],
                                  textSize: 14,
                                  maxline: 1,
                                  textColor: myMainColor,
                                  isbold: true,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                myLine(widgetsList: [
                                  myLable(
                                      text: data[index]['body'],
                                      textSize: 14,
                                      maxline: 2,
                                      minTextSize: 12),
                                  data[index]['pagetype'] == 'PAYM'
                                      ? TextButton(
                                          child: myLable(
                                              text: 'PAY NOW',
                                              textSize: 12,
                                              isUnderline: true),
                                          onPressed: () {},
                                        )
                                      : Container()
                                ], flexList: [
                                  3,
                                  1
                                ], isSpaceBetween: true)
                              ],
                            ),
                          ],
                          flexList: [0, 10],
                        ),
                      ),
                    ),
                    myLable(text: data[index]['syncdate'], textSize: 12),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    myDevider(divColor: myMidGreyColor, thickness: 1)
                  ],
                ),
              ),
              onTap: () {
                NotificationTap(
                    pageType: data[index]['pagetype'],
                    context: context,
                    insideNotificationsPage: true,
                    pageID: data[index]['pageid'].toString(),
                    title: data[index]['title'],
                    body: data[index]['body'],
                    imagepath: data[index]['imagename']);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 2));
    updateNotification();
    getnotifications().then((value) {
      _notificationlist = value;
      if (mounted)
        setState(() {
          _notificationloading = false;
        });
    });
  }

  @override
  void initState() {
    _notificationlist = [];
    _notificationloading = true;
    updateNotification();
    getnotifications().then((value) {
      _notificationlist = value;
      if (mounted)
        setState(() {
          _notificationloading = false;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: myWhiteColor,
      appBar: widget.showAppBar
          ? myAppBar(titleText: "main_notification".tr)
          : null,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _notificationloading
            ? Center(child: myLoading())
            : _notificationlist.length == 0
                ? Center(
                    child: myLable(text: "main_nodata".tr),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        notificationlist(_notificationlist),
                      ],
                    ),
                  ),
      ),
    );
  }
}

NotificationTap(
    {required String pageType,
    required BuildContext context,
    bool insideNotificationsPage = false,
    String? pageID,
    String title = '',
    String body = '',
    String imagepath = ''}) {
  // if (pageType == 'EVNT') {
  //   Get.to(eventReqDetails(eventReqId: pageID.toString()));
  // } else if (pageType == 'AMMI') {
  //   Get.to(amenitiesReqDetails(amenitiesReqId: pageID.toString()));
  // } else if (pageType == 'SERV') {
  //   Get.to(RequestDetails(reqID: pageID.toString()));
  // } else if (pageType == 'REQMESS') {
  //   Get.to(RequestDetails(reqID: pageID.toString()));
  //   Get.to(CommentsPage(
  //     chatType: 'REQ',
  //     reqID: pageID.toString(),
  //   ));
  // } else {
  if (insideNotificationsPage) {
    Get.to(
        NotificationDetails(title: title, details: body, imageLink: imagepath));
  } else {
    Get.offAll(myNav(navChoice: userNotification(showAppBar: true)));
  }
  // }
}
