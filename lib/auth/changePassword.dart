import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../mainPages/homePage.dart';
import 'dart:convert' show json, utf8;
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';
import '../mainPages/myNav.dart';
import 'AppUser.dart';

late TextEditingController _newpassword;
late TextEditingController _confirmpasswordpassword;
late FToast fToast;
final AppUser _auth = Get.find();
late bool _changeLoading;

class changePassword extends StatefulWidget {
  @override
  State<changePassword> createState() => _changePasswordState();
}

class _changePasswordState extends State<changePassword> {
  Future changepassword() async {
    try {
      String _savedtoken = await getLocalData('token');
      var resp =
          await http.get(Uri.parse(myMainAPILink + "changepassword"), headers: {
        "Accept": "application/json",
        "newpassword": _newpassword.text,
        "token": _savedtoken,
        "lang": getCurrentLocaleString()
      });
      var result = json.decode(utf8.decode(resp.bodyBytes));

      return result;
    } catch (e) {
      setState(() {
        myLogError('error');
      });
      return [];
    }
  }

  @override
  void initState() {
    _newpassword = TextEditingController();
    _confirmpasswordpassword = TextEditingController();
    _changeLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: myAppBar(titleText: "main_chnagepassword".tr),
          body: SingleChildScrollView(
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  myTextField(
                      label: "main_New Password".tr,
                      textController: _newpassword,
                      inputType: 'pin',
                      elevation: 0,
                      hideText: true),
                  myTextField(
                      label: "main_Confirm Password".tr,
                      textController: _confirmpasswordpassword,
                      inputType: 'pin',
                      elevation: 0,
                      hideText: true),
                  SizedBox(
                    height: 30,
                  ),
                  _changeLoading
                      ? myLoading()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: myButton(
                            text: 'main_confirm'.tr,
                            textColor: myWhiteColor,
                            elevation: 0,
                            isbold: false,
                            buttonType: 'simple',
                            onpressed: () {
                              if (_newpassword.text ==
                                  _confirmpasswordpassword.text) {
                                if (mounted)
                                  setState(() {
                                    _changeLoading = true;
                                  });
                                changepassword().then((value) {
                                  if (value['successFlag'] == 'T') {
                                    myToast(
                                        statusCode: 'S',
                                        text: value['resultMessage'],
                                        context: context);
                                    Get.offAll(myNav(navChoice: homePage()));
                                  } else {
                                    myToast(
                                        context: context,
                                        statusCode: 'F',
                                        text: value['resultMessage']);
                                  }
                                  if (mounted)
                                    setState(() {
                                      _changeLoading = false;
                                    });
                                });
                              } else {
                                myToast(
                                    context: context,
                                    statusCode: 'F',
                                    text: 'main_Passwordsmatch'.tr);
                              }
                            },
                          ),
                        )
                ],
              ),
            )),
          )),
    );
  }
}
