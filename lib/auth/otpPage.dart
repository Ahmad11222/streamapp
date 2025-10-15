import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
import '../mainPages/homePage.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, utf8;
import 'package:slide_countdown/slide_countdown.dart';
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';
import '../mainPages/myNav.dart';
import 'AppUser.dart';
import 'changePassword.dart';

final AppUser _auth = Get.find();
late bool _canresend;
late StreamDuration _streamDuration;
late TextEditingController _pinTE;
late bool _otpLoading;
late FirebaseMessaging _FCMmessaging;
// late VideoPlayerController _controller;

class otpPage extends StatefulWidget {
  final String username;
  final String changepassword;
  final String otpSentTo;
  final int otptime;
  @override
  otpPage(
      {required this.username,
      required this.changepassword,
      required this.otpSentTo,
      required this.otptime});
  State<otpPage> createState() => _otpPageState();
}

class _otpPageState extends State<otpPage> {
  final defaultPinTheme = PinTheme(
    width: 57,
    height: 64,
    textStyle: TextStyle(
        fontSize: 20, color: mySubTowColor, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      color: myWhiteColor,
      border: Border.all(color: mySubTowColor),
      borderRadius: BorderRadius.circular(12),
    ),
  );
  Future checkotpcode(otpcode) async {
    try {
      String fcmtoken = await getLocalData('fcmtoken');
      String token = await getLocalData('token');

      final resp = await http.get(
        Uri.parse(myMainAPILink + 'checkotp'),
        headers: {
          'Accept': 'application/json',
          'fcmtoken': fcmtoken,
          'username': widget.username,
          'otpcode': otpcode,
          'lang': getCurrentLocaleString(),
          'ctoken': token,
        },
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));
      myLog(result.toString());
      return result;
    } catch (e) {
      setState(() {
        _otpLoading = false;
      });
      return [];
    }
  }

  Future getclientbrand() async {
    try {
      final resp = await http.get(
        Uri.parse(myMainAPILink + 'getclientbrand'),
        headers: {
          'Accept': 'application/json',
          'username': widget.username,
        },
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));
      myLog(result.toString());
      return result;
    } catch (e) {
      setState(() {
        _otpLoading = false;
      });
      return [];
    }
  }

  Future createotp() async {
    try {
      final resp = await http.get(
        Uri.parse(myMainAPILink + 'createotp'),
        headers: {
          'Accept': 'application/json',
          'username': widget.username,
        },
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));
      // myLog(result);
      return result;
    } catch (e) {
      return [];
    }
  }

  resetStream() {
    _streamDuration = StreamDuration(
        config: StreamDurationConfig(
      countDownConfig:
          CountDownConfig(duration: Duration(minutes: widget.otptime)),
      onDone: () {
        setState(() {
          _streamDuration.dispose();
          _canresend = true;
        });
      },
    ));
  }

  @override
  void initState() {
    _FCMmessaging = FirebaseMessaging.instance;
    _canresend = false;
    _pinTE = TextEditingController();
    _otpLoading = false;
    resetStream();
    super.initState();
    // _controller = VideoPlayerController.asset('icons/loginvid.mp4')
    //   ..initialize().then((_) {
    //     setState(() {
    //       _controller.play();
    //       _controller.setLooping(true);
    //       _controller.setVolume(0.0);
    //     });
    //   });
  }

  void dispose() {
    super.dispose();
    _streamDuration.dispose();
    // _controller.pause();
    // _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // SizedBox.expand(
        //   child: FittedBox(
        //     fit: BoxFit.cover,
        //     child: SizedBox(
        //       width: _controller.value.size.width ?? 0,
        //       height: _controller.value.size.height ?? 0,
        //       child: VideoPlayer(_controller),
        //     ),
        //   ),
        // ),
        Scaffold(
            backgroundColor: mySubColor,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: myDeviceSize(context, 'H') * 0.3,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: myWhiteColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Column(
                                children: [
                                  myImage(
                                      imageSource: 'asset',
                                      imagePath: 'icons/appicon.png',
                                      height: 109,
                                      width: 227),
                                  myLable(
                                      text: 'verify_title'.tr,
                                      textSize: 18,
                                      isbold: true),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  myLable(
                                      text: 'verify_instruction'.tr +
                                          widget.otpSentTo,
                                      iscenter: true,
                                      textSize: 14)
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            Container(
                              height: 64,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Pinput(
                                  closeKeyboardWhenCompleted: true,
                                  keyboardType: TextInputType.number,
                                  length: 5,
                                  autofocus: true,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: defaultPinTheme.copyWith(
                                      height: 64,
                                      decoration:
                                          defaultPinTheme.decoration?.copyWith(
                                        borderRadius: BorderRadius.circular(12),
                                        color: myWhiteColor,
                                      )),
                                  submittedPinTheme: defaultPinTheme.copyWith(
                                      decoration:
                                          defaultPinTheme.decoration?.copyWith(
                                        borderRadius: BorderRadius.circular(12),
                                        color: myWhiteColor,
                                      ),
                                      height: 64),
                                  pinputAutovalidateMode:
                                      PinputAutovalidateMode.onSubmit,
                                  showCursor: true,
                                  controller: _pinTE,
                                  // onCompleted: (pin) async {
                                  //   Map<String, dynamic> otpResultMap =
                                  //       await checkotpcode(pin);
                                  //   // myLog('otpResultMap: ' + otpResultMap.toString());
                                  //   if (otpResultMap['successFlag'] == 'T') {
                                  //     Get.offAll(userClients(
                                  //         userName: widget.username,
                                  //         cToken: otpResultMap['token'],
                                  //         userFullName:
                                  //             otpResultMap['fullname'],
                                  //         changePassword:
                                  //             widget.changepassword));
                                  //   } else {
                                  //     setState(() {
                                  //       _pinTE.text = '';
                                  //     });
                                  //     myToast(
                                  //         statusCode: 'F',
                                  //         text: otpResultMap['resultMessage'],
                                  //         context: context);
                                  //   }
                                  // },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            _otpLoading
                                ? myLoading()
                                : myButton(
                                    elevation: 0,
                                    buttonType: 'simple',
                                    text: 'verify_button'.tr,
                                    buttonColor: myMainColor,
                                    bordercolor: myMainColor,
                                    onpressed: _pinTE.length == 5
                                        ? () async {
                                            setState(() {
                                              _otpLoading = true;
                                            });
                                            Map<String, dynamic> otpResultMap =
                                                await checkotpcode(_pinTE.text);
                                            // myLog(widget.username);
                                            if (otpResultMap['successFlag'] ==
                                                'T') {
                                              getclientbrand()
                                                  .then((userbrand) async {
                                                print(userbrand.toString());
                                                await setLocalData('token',
                                                    otpResultMap['token']);
                                                await setLocalData('username',
                                                    widget.username);
                                                await setLocalData('fullname',
                                                    otpResultMap['fullname']);
                                                await setLocalData(
                                                    'clientname',
                                                    otpResultMap[
                                                            'clientname'] ??
                                                        '');
                                                await setLocalData('imagename',
                                                    userbrand['imagename']);
                                                await setLocalData('maincolor',
                                                    userbrand['maincolor']);
                                                await getMainColor();
                                                Map<String, dynamic>
                                                    userLoginResultMap =
                                                    await _auth
                                                        .getDataAndLogin();
                                                if (userLoginResultMap[
                                                        'successFlag'] ==
                                                    'T') {
                                                  var _savedusername =
                                                      await getLocalData(
                                                          'username');
                                                  _FCMmessaging
                                                      .subscribeToTopic(
                                                          _savedusername
                                                              .toUpperCase()
                                                              .toString());
                                                  Get.offAll(
                                                      widget.changepassword ==
                                                              'F'
                                                          ? changePassword()
                                                          : myNav(
                                                              navChoice:
                                                                  homePage()));
                                                } else {
                                                  setState(() {
                                                    _otpLoading = false;
                                                  });
                                                  myToast(
                                                      statusCode: 'F',
                                                      text: userLoginResultMap[
                                                              'resultMessage']
                                                          .toString(),
                                                      context: context);
                                                }
                                                // Get.offAll(userClients(
                                                //     userName: widget.username,
                                                //     cToken: otpResultMap['token'],
                                                //     userFullName:
                                                //         otpResultMap['fullname'],
                                                //     changePassword:
                                                //         widget.changepassword));
                                              });
                                            } else {
                                              setState(() {
                                                _pinTE.text = '';
                                                _otpLoading = false;
                                              });
                                              myToast(
                                                  statusCode: 'F',
                                                  text: otpResultMap[
                                                      'resultMessage'],
                                                  context: context);
                                            }
                                          }
                                        : null),
                            SizedBox(
                              height: 13,
                            ),
                            myLine(widgetsList: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: myLable(
                                    text: 'resend_code'.tr,
                                    isbold: false,
                                    iscenter: true,
                                    textSize: 16),
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: SlideCountdown(
                                  streamDuration: _streamDuration,
                                  separatorPadding: EdgeInsets.all(6.0),
                                  shouldShowDays: (d) {
                                    return false;
                                  },
                                  shouldShowHours: (h) {
                                    return false;
                                  },
                                  separatorStyle:
                                      TextStyle(color: mySubThreeColor),
                                  showZeroValue: true,
                                  slideDirection: SlideDirection.up,
                                  decoration: BoxDecoration(
                                      color: myEmptyColor,
                                      borderRadius: BorderRadius.circular(20)),
                                  style: TextStyle(
                                    color: mySubThreeColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              myButton(
                                buttonType: 'link',
                                text: "main_resend".tr,
                                textSize: 16,
                                textColor: mySubThreeColor,
                                isbold: false,
                                isUnderline: true,
                                onpressed: () {
                                  createotp().then((value) {
                                    setState(() {
                                      _canresend = false;
                                      resetStream();
                                    });
                                  });
                                },
                              )
                            ], flexList: [
                              2,
                              _canresend ? 0 : 1,
                              _canresend ? 1 : 0,
                            ], iscenter: true),
                            SizedBox(
                              height: 13,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
