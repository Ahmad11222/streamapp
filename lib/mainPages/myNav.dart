import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamapp/pages/codeTemp.dart';
import 'package:streamapp/pages/streamingSound.dart';
import 'package:streamapp/pages/testaudio.dart';
import '../mainPages/homePage.dart';
import '../auth/AppUser.dart';
import '../auth/loginPage.dart';
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';
import '../pages/getSample.dart';
import '../pages/postSample.dart';

late AppUser _auth;
late int _currentNavBarIndex;
late bool _isLoggedIn;
var canCloseTime;

class myNav extends StatefulWidget {
  var navChoice;
  int currentIndex;
  String? title;
  myNav({required this.navChoice, this.currentIndex = 0, this.title});
  @override
  _myNavState createState() => _myNavState();
}

class _myNavState extends State<myNav> {
  Widget navChoice = Container();
  @override
  void initState() {
    _auth = Get.find();
    _isLoggedIn = _auth.getLogStat();
    _currentNavBarIndex = widget.currentIndex;
    navChoice = homePage();
    if (widget.navChoice != null) {
      navChoice = widget.navChoice;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _navigationButtons = [
      {
        'label': 'Gemeni DB',
        "imageSource":
            'asset', // check myImage to know how to send source and path
        'imagePath': 'icons/contractclient.png',
        'imageHeight': 24,
        'imageWidth': 24,
        'needLogin': false,
        'targetPage':
            GeminiLiveDuplexPage(), // send targetpage to change mynav body or send null here and specify function of click action
        'clickaction': null,
        'activeColor': myMainColor,
        'activeImagePath': 'icons/activehome.png',
      },
      {
        'label': "Voice Assistant2",
        "imageSource": 'asset',
        'imagePath': 'icons/contractclient.png', // Add a microphone icon
        'imageHeight': 24,
        'imageWidth': 24,
        'needLogin': false, // Set to true if login is required
        'targetPage': StreamingSoundScreen(),
        'clickaction': null,
        'activeColor': myMainColor,
        'activeImagePath': 'icons/activehome.png',
      },
      {
        'label': "home".tr,
        "imageSource":
            'asset', // check myImage to know how to send source and path
        'imagePath': 'icons/home.png',
        'imageHeight': 24,
        'imageWidth': 24,
        'needLogin': false,
        'targetPage':
            homePage(), // send targetpage to change mynav body or send null here and specify function of click action
        'clickaction': null,
        'activeColor': myMainColor,
        'activeImagePath': 'icons/activehome.png',
      },
      {
        'label': 'Get API',
        "imageSource":
            'asset', // check myImage to know how to send source and path
        'imagePath': 'icons/contractclient.png',
        'imageHeight': 24,
        'imageWidth': 24,
        'needLogin': false,
        'targetPage':
            getSamplePage(), // send targetpage to change mynav body or send null here and specify function of click action
        'clickaction': null,
        'activeColor': myMainColor,
        'activeImagePath': 'icons/activehome.png',
      },

      {
        'label': "Voice Assistant",
        "imageSource": 'asset',
        'imagePath': 'icons/contractclient.png', // Add a microphone icon
        'imageHeight': 24,
        'imageWidth': 24,
        'needLogin': false, // Set to true if login is required
        'targetPage': LiveAgentScreen(),
        'clickaction': null,
        'activeColor': myMainColor,
        'activeImagePath': 'icons/activehome.png',
      },
    ];
    Widget navigationButton({
      required int index,
      required String label,
      required String imageSource,
      required imagePath,
      required bool needLogin,
      required num imageHeight,
      required num imageWidth,
      targetPage,
      clickAction,
      required Color activeColor,
      required activeImagePath,
    }) {
      return Theme(
        data: ThemeData(
          splashColor: myEmptyColor,
          highlightColor: myEmptyColor,
        ),
        child: InkWell(
          onTap: () {
            if (needLogin && !_isLoggedIn) {
              myDialog(
                statusCode: 'F',
                context: context,
                textTitle: 'main_cant_complete'.tr,
                textDetails: 'main_need_login'.tr,
                confirmText: "main_login".tr,
                confirmAction: () {
                  Get.offAll(
                    loginPage(),
                    transition: Transition.fade,
                    duration: const Duration(milliseconds: 2500),
                  );
                },
              );
            } else {
              if (targetPage != null) {
                if (mounted)
                  setState(() {
                    _currentNavBarIndex = index;
                    navChoice = targetPage;
                  });
              } else {
                clickAction();
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              myImage(
                imageSource: imageSource,
                imagePath: _currentNavBarIndex == index
                    ? activeImagePath
                    : imagePath,
                height: imageHeight * 1.0,
                width: imageWidth * 1.0,
                color: _currentNavBarIndex == index
                    ? activeColor
                    : myMidGreyColor,
              ),
              SizedBox(height: 8),
              label == ''
                  ? Container(width: 70)
                  : Container(
                      width: 70,
                      child: myLable(
                        text: label,
                        isbold: true,
                        iscenter: true,
                        maxline: 1,
                        textSize: 12,
                        textColor: _currentNavBarIndex == index
                            ? activeColor
                            : myMidGreyColor,
                      ),
                    ),
            ],
          ),
        ),
      );
    }

    // bool _showDrawerDivider(int indx) {
    //   List<Map<String, dynamic>> hasOnlyLoginList = _drawerButtons
    //       .where((element) => element['showOnlyLogin'])
    //       .toList(); // to count if showOnlyLogin button exists
    //   if (hasOnlyLoginList.length == 0 ||
    //       (hasOnlyLoginList.length > 0 &&
    //           _isLoggedIn)) // no showOnlyLogin or user already _isLoggedIn
    //   {
    //     return indx !=
    //         _drawerButtons.length - 1; // Last drawer button has no divider
    //   }

    //   int lastIndexNotShowOnlyLogin = _drawerButtons.lastIndexWhere((element) =>
    //       !element[
    //           'showOnlyLogin']); // get the last index where not showOnlyLogin
    //   return indx <
    //       lastIndexNotShowOnlyLogin; // all elements after last not showOnlyLogin has no divider
    // }

    Widget drawerButton({
      required String label,
      required imagePath,
      required String imageSource,
      targetPage,
      tragetNavIndex,
      clickAction,
      required bool needLogin,
      required bool showOnlyLogin,
      required Color fontColor,
      required Color iconColor,
      required int ndx,
    }) {
      return Column(
        children: [
          (showOnlyLogin && !_isLoggedIn)
              ? Container()
              : InkWell(
                  onTap: (needLogin && !_isLoggedIn)
                      ? () {
                          myDialog(
                            statusCode: 'F',
                            context: context,
                            textTitle: 'main_cant_complete'.tr,
                            textDetails: 'main_need_login'.tr,
                            confirmText: "main_login".tr,
                            confirmAction: () {
                              Get.offAll(
                                loginPage(),
                                transition: Transition.fade,
                                duration: const Duration(milliseconds: 2500),
                              );
                            },
                          );
                        }
                      : () {
                          {
                            if (targetPage != null) {
                              if (mounted)
                                setState(() {
                                  Get.back();
                                  _currentNavBarIndex = tragetNavIndex;
                                  navChoice = targetPage;
                                });
                            } else {
                              Get.back();
                              clickAction();
                            }
                          }
                        },
                  child: Container(
                    height: 40,
                    child: myLine(
                      isStart: true,
                      widgetsList: [
                        myImage(
                          imageSource: imageSource,
                          imagePath: imagePath,
                          color: (needLogin && !_isLoggedIn)
                              ? myMidGreyColor
                              : iconColor,
                          height: 22,
                          width: 22,
                        ),
                        SizedBox(width: 15),
                        myLable(
                          text: label,
                          textColor: (needLogin && !_isLoggedIn)
                              ? myMidGreyColor
                              : fontColor,
                          textSize: 14,
                          maxline: 1,
                          isbold: false,
                        ),
                      ],
                      flexList: [2, 2, 6],
                    ),
                  ),
                ),
          // _showDrawerDivider(ndx)
          //     ? Divider(
          //         thickness: 0.5,
          //         color: myMidGreyColor,
          //       )
          //     : Container()
        ],
      );
    }

    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (canCloseTime == null ||
            now.difference(canCloseTime) > Duration(seconds: 2)) {
          //add duration of press gap
          canCloseTime = now;
          myToast(
            duartion: 2,
            context: context,
            text: "main_close_app".tr,
            statusCode: 'I',
          );
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: myScaffoldColor,
          appBar: myAppBar(
            showNotifications: false,
            showOut: false,
            showLogo: true,
            titleText:
                'hello_user'.tr +
                (widget.title ?? _auth.getUserFullName()).toString(),
            showGuest: false,
            titleColor: myBlackColor,
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Container(
              height: 79,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: myBlackColor.withOpacity(0.2),
                    spreadRadius: 0.1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: BottomAppBar(
                  padding: EdgeInsets.only(top: 10.0),
                  elevation: 0,
                  color: myWhiteColor,
                  child: myLine(
                    isSpaceEvenly: true,
                    widgetsList: List.generate(_navigationButtons.length, (
                      navindx,
                    ) {
                      return navigationButton(
                        index: navindx,
                        label: _navigationButtons[navindx]['label'],
                        imageSource: _navigationButtons[navindx]['imageSource'],
                        imagePath: _navigationButtons[navindx]['imagePath'],
                        needLogin: _navigationButtons[navindx]['needLogin'],
                        imageHeight: _navigationButtons[navindx]['imageHeight'],
                        imageWidth: _navigationButtons[navindx]['imageWidth'],
                        targetPage: _navigationButtons[navindx]['targetPage'],
                        clickAction: _navigationButtons[navindx]['clickaction'],
                        activeColor: _navigationButtons[navindx]['activeColor'],
                        activeImagePath:
                            _navigationButtons[navindx]['activeImagePath'],
                      );
                    }),
                    flexList: _navigationButtons.map((nav_flix) => 1).toList(),
                  ),
                ),
              ),
            ),
          ),
          body: navChoice,
        ),
      ),
    );
  }
}
