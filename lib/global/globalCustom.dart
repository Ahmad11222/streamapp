import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../global/globalWidgets.dart';
import '../global/globalConfig.dart';
import 'globalSheets.dart';

Widget myInfoContainer(
    {required String title,
    required String details,
    required IconData icon,
    double titleSize = 18,
    double detailsSize = 13,
    double iconSize = 25,
    Color? containerColor,
    Color titleColor = myWhiteColor,
    Color detailsColor = myWhiteColor,
    Color iconColor = myWhiteColor,
    double spaceSize = 40,
    ontap}) {
  return InkWell(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: containerColor ?? myMainColor,
            border: Border.all(color: containerColor ?? myMainColor),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              SizedBox(
                height: spaceSize * 2 / 5,
              ),
              myLine(widgetsList: [
                Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    myLable(
                        maxline: 1,
                        text: title,
                        textColor: titleColor,
                        isbold: true,
                        textSize: titleSize),
                    SizedBox(
                      height: spaceSize * 1 / 5,
                    ),
                    myLable(
                        maxline: 1000,
                        text: details,
                        textColor: detailsColor,
                        textSize: detailsSize),
                  ],
                )
              ], flexList: [
                1,
                1,
                10
              ], isStart: true),
              SizedBox(
                height: spaceSize * 2 / 5,
              )
            ],
          ),
        ),
      ),
    ),
    onTap: ontap,
  );
}

myPhoneApply(
    {required TextEditingController? phoneTextController,
    required TextEditingController? countryTextController,
    required phoneLabel,
    required countryLabel,
    required countryImageText,
    bool textJustRead = false,
    borederColor = myDarkGreyColor,
    onCountrySelect,
    bool countryListReadOnly = false,
    bool canBeEmpty = true}) {
  return myLine(
    widgetsList: [
      myCountriesWidget(
        widthbtween: 4.0,
        textController: countryTextController,
        label: countryLabel,
        imageText: countryImageText,
        tapfunction: onCountrySelect,
        bordercolor: borederColor,
        readonly: countryListReadOnly,
        canBeEmpty: canBeEmpty,
      ),
      myTextField(
          justRead: textJustRead,
          label: phoneLabel,
          canBeEmpty: canBeEmpty,
          textController: phoneTextController,
          inputType: 'phone',
          borderColor: borederColor),
    ],
    flexList: [2, 3],
  );
}

Future myalertdialog(BuildContext context,
    {required String assestimage,
    required String Title,
    required String Details}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(48))),
          elevation: 10,
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         Get.back();
          //       },
          //       icon: Icon(FontAwesomeIcons.cross))
          // ],
          content: Container(
            // height: myDeviceSize(context, 'H') *
            //     0.5, // Change as per your requirement
            width: myDeviceSize(context, 'W') * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(FontAwesomeIcons.xmark),
                  ),
                  onTap: () {
                    Get.back();
                  },
                ),
                Center(
                  child: Container(
                    height: myDeviceSize(context, 'W') * 0.45,
                    width: myDeviceSize(context, 'W') * 0.45,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              assestimage,
                            ),
                            fit: BoxFit.fill)),
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
                Center(
                  child: myLable(
                      text: Title,
                      textSize: 18,
                      textColor: myMainColor,
                      isbold: true,
                      iscenter: true,
                      maxline: 2),
                ),
                SizedBox(
                  height: 10,
                ),
                // Center(
                //   child: myLable(
                //       text: Details,
                //       textSize: 16,
                //       minSize: 16,
                //       textColor: blackColor,
                //       maxline: 6,
                //       iscenter: true),
                // ),
              ],
            ),
          ),
        );
      });
}

Widget myServCardWidget(
    {required String title,
    required imagePath,
    String imageSource = 'url',
    double height = 18,
    double width = 18,
    required Function onTap}) {
  return InkWell(
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: myLightGreyColor),
          color: myWhiteColor,
          boxShadow: [
            // BoxShadow(
            //   color: blueColor.withOpacity(0.2),
            //   spreadRadius: 0.1,
            //   blurRadius: 10,
            //   offset: Offset(0, 3),
            // ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12),
          child: myLine(widgetsList: [
            myLine(widgetsList: [
              myImage(
                  imageSource: imageSource,
                  imagePath: imagePath,
                  height: height,
                  width: width,
                  color: myBlackColor),
              SizedBox(),
              myLable(
                  text: title,
                  // textColor: myMainColor,
                  isbold: false,
                  textSize: 14),
            ], flexList: [
              -28,
              -16,
              1
            ], isStart: true),
            Icon(Icons.arrow_forward_ios, color: myBlackColor, size: 18),
          ], flexList: [
            3,
            1
          ], isSpaceBetween: true)),
    ),
    onTap: () => onTap(),
  );
}
