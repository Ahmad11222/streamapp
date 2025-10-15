import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../mainPages/homePage.dart';
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';
import '../mainPages/myNav.dart';
import 'package:get/get.dart';
import 'AppUser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, utf8;
import 'changePassword.dart';
import 'otpPage.dart';
// import 'package:video_player/video_player.dart';

late var _loginkey;
late TextEditingController _userNameField;
late TextEditingController _pinField;
late String _savedUserName;
late String _savedFullName;
late FirebaseMessaging _FCMmessaging;

LocalAuthentication localAuth = LocalAuthentication();
bool biofound = false;
bool bioAuthorized = false;
late bool _loginloading;
final AppUser _auth = Get.find();
late bool _pageLoading;
late String _savedToken;
// late VideoPlayerController _controller;
late bool _canclick;
late Future<String?> _imageNameFuture;

// ignore: must_be_immutable
class loginPage extends StatefulWidget {
  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  Future login(type) async {
    try {
      String fcmtoken = await getLocalData('fcmtoken');
      String _savedtoken = await getLocalData('token');
      Map<String, String> loginHeaders = {
        "Accept": "application/json",
        "username": _savedtoken == '' ? _userNameField.text : _savedUserName,
        "pin": _pinField.text,
        "auth": _savedtoken == '' ? 'N' : (type == 'password' ? 'F' : 'T'),
        "fcmtoken": fcmtoken,
        "token": _savedtoken,
        "lang": getCurrentLocaleString(),
        'mobiletype': 'COMM'
      };
      log({
        "Accept": "application/json",
        "username": _savedtoken == '' ? _userNameField.text : _savedUserName,
        "pin": _pinField.text,
        "auth": _savedtoken == '' ? 'N' : (type == 'password' ? 'F' : 'T'),
        "fcmtoken": fcmtoken,
        "token": _savedtoken,
        "lang": getCurrentLocaleString(),
        'mobiletype': 'COMM'
      }.toString());
      var resp = await http.get(Uri.parse(myMainAPILink + "login"),
          headers: loginHeaders);

      var result = json.decode(utf8.decode(resp.bodyBytes));
      log(result.toString());
      return result;
    } catch (e) {
      setState(() {
        myLogError('error' + e.toString() + _pinField.text);
        _loginloading = false;
      });
      return {};
    }
  }

  void doLogin(value) async {
    Map<String, dynamic> _loginMap = value;
    if (_loginMap['successFlag'] == 'T') {
      Map<String, dynamic> userLoginResultMap = await _auth.getDataAndLogin();
      if (userLoginResultMap['successFlag'] == 'T') {
        var _savedusername = await getLocalData('username');
        _FCMmessaging.subscribeToTopic(_savedusername.toUpperCase().toString());
        if (_loginMap['passwordchanged'] == 'F') {
          Get.offAll(changePassword());
        } else {
          Get.offAll(myNav(navChoice: homePage()));
        }
      } else {
        myAPIResultDialog(responseMap: userLoginResultMap, context: context);
        if (mounted)
          setState(() {
            _loginloading = false;
          });
      }
    } else if (_loginMap['successFlag'] == 'O') {
      Get.offAll(otpPage(
        username: _userNameField.text,
        changepassword: _loginMap['passwordchanged'],
        otpSentTo: _loginMap['otpsentto'],
        otptime: _loginMap['otptime'],
      ));
    } else {
      myAPIResultDialog(responseMap: _loginMap, context: context);
      if (mounted)
        setState(() {
          _loginloading = false;
        });
    }
  }

  Future<void> bioCheck() async {
    bool mycheck;
    try {
      mycheck = await localAuth.canCheckBiometrics;

      if (mounted)
        setState(() {
          biofound = mycheck;
        });
    } catch (e) {}
  }

  Future<void> getBioAuthorized() async {
    bool isAuthorized = false;
    try {
      isAuthorized = await localAuth.authenticate(
        localizedReason: 'main_finger'.tr,
        options: const AuthenticationOptions(
            biometricOnly: true, useErrorDialogs: true, stickyAuth: true),
      );

      if (mounted)
        setState(() {
          bioAuthorized = isAuthorized;
        });
    } catch (e) {}
  }

  void doBioCheck() {
    bioCheck().then((value) {
      if (!biofound) {
        myDialog(
          statusCode: "F",
          context: context,
          textTitle: 'main_error'.tr,
          textDetails: 'main_pleasecheck'.tr,
        );
      } else {
        getBioAuthorized().then((value) async {
          if (!bioAuthorized)
            myDialog(
              statusCode: "F",
              context: context,
              textTitle: 'main_error'.tr,
              textDetails: 'main_pleasecheckagain'.tr,
            );
          else {
            setState(() {
              _loginloading = true;
            });
            login('finger').then((value) {
              doLogin(value);
            });
          }
        });
      }
    });
  }

  Future<void> initChecks() async {
    _savedToken = await getLocalData('token');
    _savedUserName = await getLocalData('username');
    _savedFullName = await getLocalData('fullname');

    // myLog('saved token: ' +
    //     _savedToken +
    //     ' - ' +
    //     _savedUserName +
    //     ' - ' +
    //     _savedFullName);
  }

  void initState() {
    _FCMmessaging = FirebaseMessaging.instance;
    _canclick = false;
    _savedToken = '';
    _pageLoading = true;
    _loginkey = GlobalKey<FormState>();
    _userNameField = TextEditingController();
    _pinField = TextEditingController();
    _loginloading = false;
    _imageNameFuture = getLocalData('imagename');
    initChecks().then((value) {
      setState(() {
        _pageLoading = false;
        //doBioCheck(); //uncomment to call faceID on page open
      });
    });

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

  @override
  void dispose() {
    super.dispose();
    // _controller.pause();
    // _controller.dispose();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(children: [
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
        Container(
          child: Scaffold(
              backgroundColor: myLightGreyColor,
              body: _pageLoading
                  ? Center(child: myLoading())
                  : Form(
                      key: _loginkey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: _savedToken == ''
                                  ? myDeviceSize(context, 'H') * 0.3
                                  : myDeviceSize(context, 'H') * 0.2,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: myWhiteColor,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 19.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Center(
                                        child: Column(
                                          children: [
                                            FutureBuilder(
                                              future: _imageNameFuture,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return myLoading();
                                                }
                                                if (!snapshot.hasData ||
                                                    snapshot.data == '') {
                                                  return myImage(
                                                    imageSource: 'asset',
                                                    imagePath:
                                                        'icons/appicon.png',
                                                    height: 109,
                                                    width: 227,
                                                  );
                                                } else {
                                                  return Image.network(
                                                    myCloudImagesLink +
                                                        snapshot.data!,
                                                  );
                                                }
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            myLable(
                                                text: 'login_title'.tr,
                                                textSize: 18,
                                                textColor: myBlackColor,
                                                isbold: true),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            myLable(
                                                text: _savedToken == ''
                                                    ? 'login_instruction_register'
                                                        .tr
                                                    : 'login_instruction_password'
                                                        .tr,
                                                iscenter: true,
                                                textSize: 14)
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 32,
                                      ),
                                      _savedToken == ''
                                          ? Container()
                                          : myLable(
                                              text: 'main_welcome'.tr +
                                                  ':  ' +
                                                  _savedFullName,
                                              textSize: 12,
                                              minTextSize: 12,
                                              maxline: 1,
                                              iscenter: true,
                                              isbold: true),
                                      _savedToken == ''
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                myTextField(
                                                    label: 'phone_number'.tr,
                                                    elevation: 0,
                                                    hasborder: true,
                                                    borderColor: mySubTowColor,
                                                    filled: false,
                                                    canBeEmpty: false,
                                                    textColor: myBlackColor,
                                                    labelColor: myBlackColor,
                                                    textController:
                                                        _userNameField,
                                                    // inputType: 'phone',
                                                    changeFunction: (String v) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _canclick =
                                                              v.length != 0;
                                                        });
                                                      }
                                                    }),
                                              ],
                                            )
                                          : Container(),
                                      _savedToken == ''
                                          ? Container()
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                myTextField(
                                                    label: 'password'.tr,
                                                    borderColor: mySubTowColor,
                                                    filled: false,
                                                    elevation: 0,
                                                    canBeEmpty: false,
                                                    hasborder: true,
                                                    textColor: myBlackColor,
                                                    labelColor: myBlackColor,
                                                    textController: _pinField,
                                                    inputType: 'number',
                                                    hideText: true,
                                                    prefix: Icon(
                                                      Icons.lock,
                                                      color: myMainColor,
                                                    ),
                                                    changeFunction: (String v) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _canclick =
                                                              v.length != 0;
                                                        });
                                                      }
                                                    }),
                                              ],
                                            ),
                                      SizedBox(
                                        height: 18,
                                      ),
                                      _loginloading
                                          ? myLoading()
                                          : Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  myButton(
                                                    elevation: 0,
                                                    buttonType: 'simple',
                                                    onpressed: !_canclick
                                                        ? null
                                                        : () {
                                                            if (_loginkey
                                                                .currentState!
                                                                .validate()) {
                                                              setState(() {
                                                                _loginloading =
                                                                    true;
                                                              });
                                                              login('password')
                                                                  .then(
                                                                      (value) {
                                                                doLogin(value);
                                                              });
                                                            }
                                                          },
                                                    text: "main_sginin".tr,
                                                    widget: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                              color: _canclick
                                                                  ? myMainColor
                                                                  : myMidGreyColor
                                                                      .withOpacity(
                                                                          0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100)),
                                                          child: Center(
                                                              child: Icon(Icons
                                                                  .arrow_forward_ios)),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        myLable(
                                                            text: 'enter_button'
                                                                .tr,
                                                            textColor: _canclick
                                                                ? myMainColor
                                                                : myMidGreyColor
                                                                    .withOpacity(
                                                                        0.5))
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 14,
                                                  ),
                                                  _savedToken == ''
                                                      ? Container()
                                                      : myLable(
                                                          text: "main_or".tr,
                                                        ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  _savedToken == ''
                                                      ? Container()
                                                      : myButton(
                                                          buttonType: 'widget',
                                                          widget: myImage(
                                                              color:
                                                                  myMainColor,
                                                              imageSource:
                                                                  Platform.isIOS
                                                                      ? 'asset'
                                                                      : 'icon',
                                                              imagePath: Platform
                                                                      .isIOS
                                                                  ? "icons/faceid.png"
                                                                  : Icons
                                                                      .fingerprint,
                                                              height: 70,
                                                              width: 70),
                                                          onpressed: () {
                                                            doBioCheck();
                                                          },
                                                        ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            Center(
                              child: myLable(
                                iscenter: true,
                                text: 'privacy_note'.tr,
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
        ),
      ]),
    );
  }
}
