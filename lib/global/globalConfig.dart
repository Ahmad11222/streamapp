import 'dart:convert';
import 'dart:io';
import '../auth/loginPage.dart';
import '../mainPages/userNotification.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globalWidgets.dart';

bool isLive = false;
String myVersionId = '1';

bool authLoginNeeded = true;

String myLink = "http://18.224.8.111:8075/fid19c/gl/apis/";

var myMainAPILink = isLive
    ? "http://18.224.8.111:8080/fid19c/integration/main/"
    : "http://18.224.8.111:8080/fid19c/integration/main/";

var myCloudImagesLink = 'http://18.224.8.111:8080/cloudfiles/';

var myIntegrationAPILink =
    'http://18.224.8.111:8080/fid19c/integration/integration/';

String myWVTerms = 'https://www.google.com/';
String myWVPrivacy = 'https://www.google.com/';

///////////////////////////  Colors /////////////////////////////////////////
//Color.fromARGB(255, 86, 141, 173);

Color myMainColor = const Color(
    0xff0080FF); // Color(0xff114D2C); //Color(0xff011D48); // Color(0xff00317E);
const mySubColor = Color(0xffE6F2FF); // Color(0xff01327E);
const mySubTowColor = Color(0xff92A7C8);
const mySubThreeColor = Color(0xff00AAFF);
const myFilledColor = Color(0xffE6F7FF); //Color(0xffE6F7FF);

const myBlackColor = Color(0xff2C3E50); // Color.fromARGB(255, 0, 0, 0);2C3E50
const myDarkGreyColor = Color.fromARGB(255, 112, 110, 110);
const myMidGreyColor = Color.fromARGB(255, 180, 180, 180);
const myLightGreyColor = Color.fromARGB(255, 240, 240, 240);

const myScaffoldColor = Color(0xffF4F8FB);
const myWhiteColor = Color(0xffFFFFFF);
const myEmptyColor = Colors.transparent;

// const mySuccessColor = Color.fromARGB(255, 102, 185, 83);
const mySuccessColor = Color(0xff189B09);

const myFailedColor = Color(0xffF50000);

Color myInfoColor = myMainColor; //Color.fromARGB(255, 168, 145, 14);
const myBlueColor = Color(0xff263B6B);

//const myMainColor = Color(0xff005163);

const brownColor = Color(0xff847100);

const mentColor = Color(0xff263B6B);
const serviceColor = Color(0xffE7C792);
const postColor = Color(0xff5FC0A5);
const bookingColor = Color(0xff71BBD8);

const cardnotificationColor = Color(0xffF28D7E);
const cardpollsColor = Color(0xff3F99BC);
const cardRoomsColor = Color(0xff263B6B);
const cardsubscrColor = Color(0xffBA9F73);
const cardfeedsColor = Color(0xff4DB095);
const cardnewsColor = Color(0xffE8A968);

const chatsender = Color(0xff20A090);
const chatreciver = Color(0xffF2F7FB);

const pollscontainerColor = Color(0xff02343F);
const pollsselectorColor = Color(0xffF0EDCC);

const maincatigcolor = Color(0xff102F47);
const greenColor = Color(0xff40A629);
const lightGreenColor = Color(0xff2ec650);
//const mySubColor = Color.fromARGB(255, 204, 204, 204);
const lightsubColor = Color.fromARGB(255, 86, 141, 173);
const redColor = Color(0xffC2000B);
const LightRedColor = Color.fromARGB(255, 187, 84, 89);
const blueColor = Color(0xff263B6B);
const lightblueColor = Color(0xff71BBD8);
const skyColor = Color(0xff71BBD833);
const appbarColor = Color(0xff729AB9);
const homepagecontainerColor = Color(0xffFBF0D880);
const cardcolor = Color(0xffffffff);
const subcardcolor = Color(0xff231F20);

//Color.fromARGB(255, 1, 30, 77);
// const subtestcolor = Color(0xff61A2C8);

//////////////////////////////////////////////////////////////////////////////

//"D" for Default // "S" for success // "F" for failed // "I" for information // 'N' for notifications
Color myGetStatusColor(String statusCode) {
  if (statusCode == "S") return mySuccessColor;
  if (statusCode == "F") return myFailedColor;
  if (statusCode == "I") return myInfoColor;
  if (statusCode == "N") return myWhiteColor;
  if (statusCode == "D") return myMainColor;
  return myMainColor;
}

IconData myGetStatusIcon(String statusCode) {
  if (statusCode == "S") return Icons.check;
  if (statusCode == "F") return Icons.close;
  if (statusCode == "I") return Icons.info;
  if (statusCode == "N") return Icons.notifications;
  if (statusCode == "D") return Icons.info;
  return Icons.info;
}

var myOnPayLink = isLive
    ? 'http://3.145.126.175:8080/mpay/'
    : 'http://3.145.126.175:8080/mpay/';

var myPaymentDetailsLink = isLive
    ? 'http://3.145.126.175:8080/edu/apis/fid/payments/'
    : 'http://3.145.126.175:8080/edu/apis/fid/payments/';

var myOnPayBuyLink = myOnPayLink + 'buy.jsp?';

List<String> myOnPayBackLinks = [
  myOnPayLink + 'paydone.jsp',
];

List accessList = [
  {'id': 'O', 'title': 'Once'},
  {'id': 'U', 'title': 'Unlimited'}
];
List guestTypes = [
  {'id': 'F', 'title': 'Family'},
  {'id': 'R', 'title': 'Friends'},
  {'id': 'O', 'title': 'Other'},
];

String myDateFormatText = 'dd/MM/yyyy';
String myDateTimeFormatText = 'dd/MM/yyyy HH:mm:ss';

Map<String, num> myWeekDays = {
  'SUN': 7,
  'MON': 1,
  'TUE': 2,
  'WED': 3,
  'THU': 4,
  'FRI': 5,
  'SAT': 6,
};

int myinfoPagesCount = 3;
// Write the text of each page translation key.
// Make sure to have photos inside icons folder with same count starting from info1.png
// Make sure to have keys inside translation.dart with same count starting from main_infopage_1

int myAPITimeout = 20;

Map<String, dynamic> myErrorMap = {
  "successFlag": "F",
  "resultMessage": "main_error_details".tr,
};

void myLog(String logText) {
  var mylog = Logger();
  mylog.t(logText);
}

void myLogError(String logText) {
  var mylog = Logger();
  mylog.w(logText);
}

int myWidgetLineCount(BuildContext context) {
  num deviceWidth = myDeviceSize(context, 'w');

  return deviceWidth < 600 ? 3 : (myDeviceSize(context, 'w') / 200).ceil();
}

num myDeviceSize(BuildContext context, String type) {
  num val = 0;

  if (type.toUpperCase() == 'H')
    val = MediaQuery.of(context).size.height;
  else if (type.toUpperCase() == 'W')
    val = MediaQuery.of(context).size.width;
  else if (type.toUpperCase() == 'MIN')
    val = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
  else if (type.toUpperCase() == 'MAX')
    val = max(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

  return val;
}

Future<void> setLocalData(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String> getLocalData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? '';
}

Future<void> clearCompletlyLocalData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> clearLocalData() async {
  String fcmtoken = await getLocalData('fcmtoken');
  await clearCompletlyLocalData();
  await setLocalData('fcmtoken', fcmtoken);
}

Future<void> cleareDataByKey(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.remove(key);
}

Future<bool> checkLocalDataExists(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(key);
}

////////////////////// Locales ////////////////////////////////
List<String> myLanguagesList = ['ar', 'en'];

String getCurrentLocaleString() {
  return Get.locale == Locale('ar') ? 'ar' : 'en';
}

String getCurrentLocaleLongString() {
  return Get.locale == Locale('ar') ? 'عربي' : 'English';
}

String getLocaleLongString(String key) {
  return key == 'ar' ? 'عربي' : 'English';
}

Future<Locale> getSavedLocale() async {
  await Future.delayed(Duration(seconds: 1));
  String savedString = await getLocalData('lang');
  if (savedString == '') {
    return Locale('en');
  } else if (savedString == 'ar') {
    return Locale('ar');
  } else if (savedString == 'en') {
    return Locale('en');
  }
  return Locale('en');
}

String getfontFamily() {
  return getCurrentLocaleString() == 'ar' ? 'font-ar' : 'font-en';
}
///////////////////////////////////////////////////////////////

String getSubstring(String text, int textLength) {
  return text.length > (textLength + 1)
      ? text.substring(0, textLength) + '...'
      : text.toString();
}

String getMultiLineString(String pageName,
    {required String text, int lineLength = 10}) {
  //return text.replaceAll(RegExp(r'\s+'), '\n'); to seperate each word in one line
  List<String> lines = [];
  List<String> words = text.split(' ');

  String currentLine = '';
  for (String word in words) {
    if ((currentLine.length + word.length) <= lineLength) {
      currentLine += '$word ';
    } else {
      lines.add(currentLine.trim());
      currentLine = '$word ';
    }
  }

  // Add the remaining part if any
  if (currentLine.isNotEmpty) {
    lines.add(currentLine.trim());
  }

  return lines.join('\n');
}

String getRandomValue({int length = 7, bool addMilSec = true}) {
  String val = '';

  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  Random _rnd = Random();

  val = String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  if (addMilSec) {
    val += DateTime.now().millisecondsSinceEpoch.toString();
  }
  return val;
}

String myFileToBase64(String fiLePath) {
  final bytes = File(fiLePath).readAsBytesSync();
  String vbase = base64Encode(bytes);
  return vbase;
}

PreferredSizeWidget? myAppBar({
  Color appBarColor = myWhiteColor,
  String titleText = '',
  Color titleColor = myBlackColor,
  Color? navButtonColor,
  bool showAppBar = true,
  double height = 55.0,
  bool hasEmergencyLabel = false,
  bool showChat = false,
  bool showNotifications = false,
  bool showGuest = false,
  bool showOut = false,
  bool showLogo = false,
  clickWidget,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(showAppBar ? height : 0),
    child: ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(12),
      ),
      child: AppBar(
        iconTheme: IconThemeData(color: myBlackColor, size: 25),
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: false, // Align title to the left
        titleSpacing: 16, // Optional: reduce left padding
        title: FutureBuilder<String>(
          future: getLocalData('imagename'),
          builder: (context, snapshot) {
            String imageName = snapshot.data ?? '';
            return myLine(widgetsList: [
              imageName == ''
                  ? myImage(
                      imageSource: 'asset',
                      imagePath: 'icons/appicon.png',
                      height: 30,
                      width: 30)
                  : myImage(
                      imageSource: 'url',
                      imagePath: myCloudImagesLink + imageName,
                      height: 30,
                      width: 30),
              SizedBox(),
              myLable(
                text: titleText,
                textColor: titleColor,
                textSize: 18,
                minTextSize: 16,
                isbold: false,
                maxline: 1,
              ),
            ], flexList: [
              showLogo ? 1 : 0,
              -8,
              1
            ], isStart: true);
          },
        ),
        actions: [
          showNotifications
              ? Padding(
                  padding: getCurrentLocaleString() == 'en'
                      ? EdgeInsets.only(right: 15.0, bottom: 10, top: 8)
                      : EdgeInsets.only(left: 15.0, bottom: 10, top: 8),
                  child: Container(
                    height: 44,
                    width: 44,
                    // decoration: BoxDecoration(
                    //     color: mySubColor,
                    //     borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      onPressed: () {
                        Get.to(userNotification(
                          showAppBar: true,
                        ));
                      },
                      icon: ImageIcon(
                          size: 55,
                          color: myBlackColor,
                          AssetImage('icons/notification.png')),
                    ),
                  ),
                )
              : clickWidget ?? Container(),
          showOut
              ? Padding(
                  padding: getCurrentLocaleString() == 'en'
                      ? EdgeInsets.only(right: 15.0, bottom: 10, top: 8)
                      : EdgeInsets.only(left: 15.0, bottom: 10, top: 8),
                  child: Container(
                    height: 44,
                    width: 44,
                    // decoration: BoxDecoration(
                    //     color: mySubColor,
                    //     borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      onPressed: () {
                        // _auth.logOut();
                        Get.offAll(loginPage());
                      },
                      icon: ImageIcon(
                        color: myBlackColor,
                        AssetImage('icons/logout.png'),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    ),
  );
}

Future getMainColor() async {
  myMainColor = await getLocalData('maincolor') == ''
      ? const Color(0xff0080FF)
      : Color(int.parse(await getLocalData('maincolor')));
}
