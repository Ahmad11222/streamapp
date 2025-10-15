import 'dart:convert' show json, utf8, jsonEncode;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../auth/AppUser.dart';
import '../mainPages/SplashScreen.dart';
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';

// Future<bool> utilNotificationsAuthenticated() async {
//   PermissionStatus prm;
//   prm = await NotificationPermissions.getNotificationPermissionStatus();

//   if (prm == PermissionStatus.granted) {
//     return true;
//   }

//   return false;
// }

Future utilNotificationcheck({required BuildContext context}) async {
  // bool isIOS = Platform.isIOS;
  // bool hasAuthenticated = await utilNotificationsAuthenticated();
  // myLog(isIOS.toString() +
  //     ' / ' +
  //     hasAuthenticated.toString() +
  //     ' / ');

  FirebaseMessaging FCMmessaging = FirebaseMessaging.instance;

  NotificationSettings settings = await FCMmessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // PermissionStatus prm;
  // prm = await NotificationPermissions.getNotificationPermissionStatus();
  AuthorizationStatus authStatus = settings.authorizationStatus;
  myLog(authStatus.toString());
}

utilChangeLanguage(BuildContext context) {
  mySheet(context: context, widgetsList: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
      child: Column(
        children: [
          Center(
            child:
                myLable(text: "main_chooselang".tr, textSize: 22, isbold: true),
          ),
          SizedBox(
            height: 20,
          ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: myLanguagesList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int indx) {
                bool isCurrentLocale =
                    (getCurrentLocaleString() == myLanguagesList[indx]);
                return myButton(
                    buttonType: 'simple',
                    text: getLocaleLongString(myLanguagesList[indx]),
                    textColor: isCurrentLocale ? myWhiteColor : myBlackColor,
                    bordercolor:
                        isCurrentLocale ? myMainColor : myLightGreyColor,
                    elevation: 0,
                    buttonColor:
                        isCurrentLocale ? myMainColor : myLightGreyColor,
                    imageSource: 'icon',
                    imagePath: isCurrentLocale ? Icons.check_circle : null,
                    imageColor: myWhiteColor,
                    onpressed: () async {
                      Get.back();
                      await Get.updateLocale(Locale(myLanguagesList[indx]));
                      await setLocalData('lang', myLanguagesList[indx]);
                      // Get.offAll(SplashScreen(
                      //     changeLocale: Locale(myLanguagesList[indx])));
                    });
              }),
        ],
      ),
    )
  ]);
}

utilDeleteAccount(BuildContext context) {
  Future _deleteAccountAPI() async {
    var _savedtoken = await getLocalData('token');
    try {
      final resp = await http.get(
        Uri.parse(myMainAPILink + 'changeAccountStatus'),
        headers: {
          'Accept': 'application/json',
          'auth_token': _savedtoken,
          'is_active': 'F',
          'lang': getCurrentLocaleString()
        },
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));

      return result;
    } catch (e) {
      return [];
    }
  }

  bool _isChecked = false;
  TextEditingController accountTE = TextEditingController();
  final AppUser _auth = Get.find();

  mySheet(
    context: context,
    widgetsList: [
      Center(
        child: myLable(
            text: "main_delete_account".tr,
            isbold: true,
            iscenter: true,
            textSize: 22,
            textColor: myFailedColor),
      ),
      SizedBox(height: 10),
      StatefulBuilder(builder: (context, sheetsetState) {
        return myCheckBoxTile(
            label: 'main_deletemyacc'.tr,
            isBold: true,
            isChecked: _isChecked,
            activeColor: myFailedColor,
            changeFunction: (value) {
              sheetsetState(() {
                _isChecked = value ?? false;
              });
            });
      }),
      SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child:
            myLable(text: 'main_enterusername'.tr, isbold: true, textSize: 16),
      ),
      SizedBox(height: 5),
      myTextField(
          label: '',
          hideText: false,
          textController: accountTE,
          textColor: myFailedColor,
          filled: true,
          fillingColor: myFailedColor,
          borderColor: myFailedColor,
          hint: _auth.getUserName()),
      myButton(
          buttonType: 'simple',
          text: "main_deletemyacc".tr,
          buttonColor: myFailedColor,
          imageSource: 'icon',
          imagePath: Icons.person_remove,
          imageColor: myBlackColor,
          onpressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (_isChecked & (accountTE.text == _auth.getUserName())) {
              myDialog(
                  context: context,
                  statusCode: 'F',
                  textTitle: "main_accountwillbe".tr,
                  textDetails: "main_areyousure".tr,
                  confirmAction: () {
                    _deleteAccountAPI().then((value) async {
                      if (value['successFlag'] == 'T') {
                        _auth.logOut();
                        clearLocalData();
                        Get.offAll(SplashScreen(
                          changeLocale: null,
                        ));
                      } else {}
                    });
                  });
            } else {
              myToast(
                  duartion: 5,
                  context: context,
                  text: 'main_confirmdelete'.tr,
                  statusCode: 'I');
            }
          })
    ],
  );
}
