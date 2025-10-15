import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mainPages/AppUtils.dart';
import '../global/globalWidgets.dart';
import '../global/globalConfig.dart';
import '../auth/loginPage.dart';

late int _currentpage;
late List<String> _infoPageList;

class infoPage extends StatefulWidget {
  @override
  State<infoPage> createState() => _infoPageState();
}

class _infoPageState extends State<infoPage> {
  @override
  void initState() {
    utilNotificationcheck(context: context);

    _infoPageList = [];

    for (int i = 1; i <= myinfoPagesCount; i++) {
      _infoPageList.add('main_infopage_' + i.toString());
    }

    _currentpage = 0;

    super.initState();
  }

  final PageController controller = PageController();

  Widget infoPagePhotos() {
    return Container(
      child: PageView(
        onPageChanged: (index) {
          setState(() {
            _currentpage = index;
          });
        },
        controller: controller,
        children: _infoPageList
            .map((pagetext) => Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: myDeviceSize(context, 'H') * 0.72,
                            width: myDeviceSize(context, 'W') * 1,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('icons/info' +
                                    (_infoPageList.indexOf(pagetext) + 1)
                                        .toString() +
                                    '.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: myBlackColor.withOpacity(0.5),
                                spreadRadius: 0.1,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: myWhiteColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                        height: myDeviceSize(context, 'H') * 0.30,
                        width: myDeviceSize(context, 'W') * 1,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 32,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: myLable(
                                    text: _infoPageList.indexOf(pagetext) == 0
                                        ? 'Your Rent, Now Fully Digital'
                                        : _infoPageList.indexOf(pagetext) == 1
                                            ? 'YOUR PERSONAL POCKET ASSISTANT'
                                            : 'YOUR LUXURY LIFESTYLE AWAITS',
                                    textSize: 28,
                                    minTextSize: 8,
                                    maxline: 2,
                                    textColor: myBlackColor,
                                    isbold: true),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView(
                                    padding: EdgeInsets.all(0),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: myLable(
                                            text: pagetext.tr,
                                            textColor: myBlackColor,
                                            maxline: _currentpage ==
                                                    (_infoPageList.length - 1)
                                                ? 5
                                                : 1000,
                                            textSize: 16,
                                            isbold: false),
                                      ),
                                    ]),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 16),
                                  child: myLine(widgetsList: [
                                    myPageViewController(
                                        controller: controller,
                                        count: _infoPageList.length),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 150.0),
                                      child: myButton(
                                          buttonType: 'simple',
                                          text: _currentpage ==
                                                  (_infoPageList.length - 1)
                                              ? 'Start'
                                              : 'Next',
                                          buttonColor: myMainColor,
                                          bordercolor: myMainColor,
                                          elevation: 0,
                                          onpressed: () {
                                            if (_currentpage ==
                                                (_infoPageList.length - 1)) {
                                              Get.offAll(
                                                loginPage(),
                                                transition:
                                                    Transition.leftToRight,
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                              );
                                            } else {
                                              controller.nextPage(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  curve: Curves.ease);
                                            }
                                          }),
                                    )
                                  ], flexList: [
                                    1,
                                    3,
                                  ], isSpaceBetween: true))
                            ],
                          ),
                        )),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget FloatingNavigationWidget() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
        child: myLine(widgetsList: [
          myPageViewController(
              controller: controller, count: _infoPageList.length),
          Padding(
            padding: const EdgeInsets.only(left: 150.0),
            child: myButton(
                buttonType: 'simple',
                text: _currentpage == (_infoPageList.length - 1)
                    ? 'Start'
                    : 'Next',
                buttonColor: mySubColor,
                bordercolor: mySubColor,
                onpressed: () {
                  if (_currentpage == (_infoPageList.length - 1)) {
                    Get.offAll(
                      loginPage(),
                      transition: Transition.leftToRight,
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                    );
                  } else {
                    controller.nextPage(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        curve: Curves.ease);
                  }
                }),
          )
        ], flexList: [
          1,
          3,
        ], isSpaceBetween: true));
  }

  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        //floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        // floatingActionButton: FloatingNavigationWidget(),
        body: Stack(children: [
          infoPagePhotos(),
          myChangeLanguage(
              context: context,
              ShowSkip: true,
              showLang: false,
              SkipColor: myWhiteColor),
        ]),
      ),
    );
  }
}
