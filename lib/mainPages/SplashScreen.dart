import 'dart:developer';
import '../mainPages/homePage.dart';
import '../mainPages/infoPage.dart';
import '../mainPages/myNav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/AppUser.dart';
import '../auth/loginPage.dart';
import '../global/globalConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, utf8;
import '../auth/versionerror.dart';

late Map _versionlist;
final AppUser _auth = Get.find();
late String _savedtoken;

class SplashScreen extends StatefulWidget {
  Locale? changeLocale;
  SplashScreen({required changeLocale}) {
    this.changeLocale = changeLocale;
  }
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future mobileversion() async {
    try {
      log(myMainAPILink + "getmobileversion");
      var resp = await http.get(Uri.parse(myMainAPILink + "getmobileversion"),
          headers: {"Accept": "application/json", "vid": myVersionId});
      var result = json.decode(utf8.decode(resp.bodyBytes));
      return result;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<void> changeLoc() async {
    await Future.delayed(Duration(seconds: 1));
    if (widget.changeLocale == Locale('en')) {
      await setLocalData('lang', 'en');
      await Get.updateLocale(Locale('en'));
    } else {
      await setLocalData('lang', 'ar');
      await Get.updateLocale(Locale('ar'));
    }
  }

  Future checkTokenExists() async {
    try {
      final _username = await getLocalData('username');

      final resp = await http.get(
        Uri.parse(myMainAPILink + 'tokenexists'),
        headers: {
          'Accept': 'application/json',
          'authtoken': _savedtoken,
          'username': _username,
        },
      );
      // myLog({
      //   'Accept': 'application/json',
      //   'authtoken': _savedtoken,
      //   'username': _username,
      // }.toString());
      var result = json.decode(utf8.decode(resp.bodyBytes));
      // myLog(result.toString());
      return result;
    } catch (e) {
      return {'tokenexists': 'F'};
    }
  }

  Future initcheck() async {
    _savedtoken = await getLocalData('token');
  }

  @override
  void initState() {
    print('in splash');
    _savedtoken = '';
    initcheck();

    _versionlist = {};

    mobileversion().then((value) {
      _versionlist = value;
      print('_versionlist' + _versionlist.toString());
      if (_versionlist['successflag'] == 'T') {
        if (widget.changeLocale == null) {
          // moh notes one async function with waits
          getSavedLocale().then((value) {
            if (value != Get.locale) {
              Get.updateLocale(value);
            }
            if (_savedtoken == '') {
              Get.offAll(
                infoPage(),
              );
            } else {
              checkTokenExists().then((valuee) async {
                // myLog('token exists: ' + valuee['tokenexists']);
                if (valuee['tokenexists'] == 'T') {
                  authLoginNeeded
                      ? Get.offAll(loginPage())
                      : Get.offAll(myNav(navChoice: homePage()));
                } else {
                  await clearLocalData();
                  Get.offAll(loginPage());
                }
              });
            }
          });
        } else {
          changeLoc().then((value) {
            // moh notes why saved token not isLoggedin
            _savedtoken == ''
                ? Get.offAll(loginPage())
                : Get.offAll(myNav(navChoice: homePage()));
          });
        }
      } else {
        Get.offAll(
          versionerror(
              androidLink: _versionlist['androidlink'],
              iosLinlk: _versionlist['ioslink']),
        );
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: myWhiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('icons/appicon.png'),
          ],
        ),
      ),
    );
  }
}
