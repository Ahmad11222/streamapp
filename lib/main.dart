import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:streamapp/pages/streamingSound.dart';
import 'package:streamapp/pages/testaudio.dart';
import '../auth/AppUser.dart';
import 'global/globalConfig.dart';
import 'mainPages/homePage.dart';
import 'mainPages/myNav.dart';
import 'translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

const myAppTitle = 'Appraisal';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await getMainColor();
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  } catch (e) {}
  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Keep it transparent
      statusBarIconBrightness: Brightness.light, // Icons & text in white
      statusBarBrightness: Brightness.dark, // For iOS
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging FCMmessaging;

  Future<void> _requestMediaPermissions() async {
    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cam = statuses[Permission.camera];
      final mic = statuses[Permission.microphone];

      // If permanently denied, guide user to settings
      if ((cam?.isPermanentlyDenied ?? false) ||
          (mic?.isPermanentlyDenied ?? false)) {
        if (mounted) {
          Get.snackbar(
            'Permissions required',
            'Please enable Camera and Microphone permissions in App Settings.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: mySubColor,
            colorText: myBlackColor,
            duration: Duration(seconds: 6),
            mainButton: TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(color: myBlackColor),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Ignore permission errors at startup; request again when needed
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      FCMmessaging = FirebaseMessaging.instance;
      FCMmessaging.subscribeToTopic((isLive ? 'ALL' : 'ALL-test'));
      FCMmessaging.getToken().then((googleToken) async {
        await setLocalData('fcmtoken', googleToken ?? '');
        String fcmtoken = await getLocalData('fcmtoken');
        print('FCM token: ' + fcmtoken);

        NotificationSettings settings = await FCMmessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        AuthorizationStatus authStatus = settings.authorizationStatus;
        var showdialog = await getLocalData('showdialog');

        print('FCM Show dialog: ' + showdialog.toString());

        if (Platform.isAndroid) {
          if (showdialog != 'F') {
            if (authStatus == AuthorizationStatus.authorized) {
              await setLocalData('showdialog', 'F');
            } else {
              await setLocalData('showdialog', 'T');
            }
          }
        } else {
          await setLocalData('showdialog', 'F');
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Get.snackbar(
          message.notification!.title!,
          message.notification!.body!,
          icon: Icon(Icons.notifications, color: mySubColor),
          snackPosition: SnackPosition.TOP,
          backgroundColor: myMainColor,
          colorText: mySubColor,
          duration: Duration(seconds: 5),
        );
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {});
    } catch (e) {
      print('FCM Error!');
    }

    // Request Camera & Microphone permissions after first frame to ensure overlays are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestMediaPermissions();
    });
  }

  AppUser auth = Get.put(AppUser());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetMaterialApp(
      translations: Mytrans(),
      supportedLocales: [Locale('en'), Locale('ar')],
      locale: Locale('en'),
      localizationsDelegates: [
        for (int i = 0; i < GlobalMaterialLocalizations.delegates.length; i++)
          GlobalMaterialLocalizations.delegates[i],
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: myAppTitle,
      theme: ThemeData(
        fontFamily: getCurrentLocaleString() == 'ar' ? 'font-ar' : 'font-en',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.light(
          primary: myMainColor,
          secondary: mySubColor,
        ),
      ),
      home: myNav(navChoice: GeminiLiveDuplexPage()),

      // SplashScreen(
      //   changeLocale: null,
      // )
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
