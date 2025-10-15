import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../global/globalConfig.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as pathPKG;
import '../mainPages/AppUtils.dart';
import '../mainPages/AppWebView.dart';
import '../auth/loginPage.dart';
import '../auth/validations.dart';
import '../templates/mainTemplates.dart';
import 'package:badges/badges.dart' as badges;
import 'package:photo_view/photo_view.dart';

const double _defaultVerticalPadding = 5.0;
const bool _defaultHasBorder = false;
const bool _defaultFilled = true;
final Color _defaultFillingColor = myMainColor;
const double _defaultFillingOpacity = 0.1;
const double _defaultButtonHeight = 42;

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

Widget myLable(
    {required String text,
    int maxline = 1000,
    num textSize = 14.0,
    num minTextSize = -1,
    Color textColor = myBlackColor,
    bool isbold = false,
    bool iscenter = false,
    bool isEnd = false,
    bool isUnderline = false,
    double latterSpace = 0.0}) {
  if (minTextSize == -1) {
    minTextSize = textSize;
  }
  return AutoSizeText(
    text,
    style: TextStyle(
      letterSpacing: latterSpace,
      fontSize: textSize.toDouble(),
      color: textColor,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
      fontWeight: isbold ? FontWeight.bold : FontWeight.normal,
      //letterSpacing: letterspace
    ),
    minFontSize: minTextSize.toDouble(),
    maxLines: maxline,
    wrapWords: false,
    overflow: TextOverflow.ellipsis,
    textAlign:
        iscenter ? TextAlign.center : (isEnd ? TextAlign.end : TextAlign.start),
  );
}

Widget myTextField(
    {required String label,
    inputType = 'text',
    String hint = '',
    TextEditingController? textController,
    double textSize = 16,
    bool justRead = false,
    bool canBeEmpty = true,
    bool hideText = false,
    int linesNo = 1,
    int maxlength = 0,
    bool showMaxLength = false,
    Color labelColor = myBlackColor, // color of text field label
    Color textColor = myDarkGreyColor, // color of text input
    Color hintColor = myMidGreyColor, // color of hint text
    bool filled = _defaultFilled,
    Color? fillingColor, // color of text field fill
    double fillingOpacity = _defaultFillingOpacity,
    bool hasborder = _defaultHasBorder,
    Color? borderColor, // color of border
    bool isCenterText = false,
    double radius = 10.0,
    Widget? prefix,
    suffix,
    Function(String)? changeFunction,
    var validators,
    double verticalPadding = _defaultVerticalPadding,
    double horizontalPadding = 2.0,
    double elevation = 4,
    OnTap,
    bool hasLabel = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      hasborder
          ? Container()
          : hasLabel
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: myLable(
                      text: canBeEmpty ? label : (label + '*'),
                      textSize: 14,
                      textColor: labelColor),
                )
              : Container(),
      Padding(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        child: PhysicalModel(
          borderRadius: BorderRadius.circular(radius),
          color: myWhiteColor,
          elevation: elevation,
          shadowColor: myMainColor.withOpacity(0.5),
          child: TextFormField(
            maxLength: showMaxLength ? maxlength : null,
            controller: textController,
            onTap: OnTap,
            focusNode: justRead ? new AlwaysDisabledFocusNode() : null,
            readOnly: justRead,
            maxLines: hideText ? 1 : (inputType == 'multi' ? null : linesNo),
            obscureText: hideText,
            obscuringCharacter: '*',
            style: TextStyle(color: textColor, fontSize: textSize),
            textAlign: isCenterText ? TextAlign.center : TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
            onChanged: changeFunction,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 12),
              fillColor: fillingColor ??
                  _defaultFillingColor.withOpacity(fillingOpacity),
              filled: filled,
              labelText: hasborder ? (canBeEmpty ? label : label + ' *') : '',
              labelStyle: TextStyle(
                color: labelColor,
                fontSize: textSize,
              ),
              alignLabelWithHint: true,
              floatingLabelBehavior: hasborder
                  ? FloatingLabelBehavior.auto
                  : FloatingLabelBehavior.never,
              floatingLabelStyle: TextStyle(
                color: labelColor,
                fontSize: textSize,
              ),
              prefixIcon: prefix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: prefix,
                    ),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: suffix,
                    ),
              border: OutlineInputBorder(
                  borderSide: hasborder
                      ? BorderSide(
                          color: borderColor ?? myMainColor, width: 1.0)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(radius)),
              enabledBorder: OutlineInputBorder(
                  borderSide: hasborder
                      ? BorderSide(
                          color: borderColor ?? myMainColor, width: 1.0)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(radius)),
              errorBorder: OutlineInputBorder(
                  borderSide: hasborder
                      ? BorderSide(color: myFailedColor, width: 1.0)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(radius)),
            ),
            keyboardType: inputType == 'number' ||
                    inputType == 'civilid' ||
                    inputType == 'pin'
                ? TextInputType.number
                : (inputType == 'phone'
                    ? TextInputType.phone
                    : (inputType == 'email'
                        ? TextInputType.emailAddress
                        : (inputType == 'multi'
                            ? TextInputType.multiline
                            : TextInputType.text))),
            validator: (value) {
              value = value ?? '';
              if (value.length == 0) {
                if (!canBeEmpty && !validateNotEmpty(value))
                  return 'main_not_empty'.tr;
              } else {
                if (maxlength > 0 && !validateMaxLength(value, maxlength)) {
                  return 'main_maxlength'.tr + maxlength.toString();
                }
                if (!validateEmail(value) && inputType == 'email') {
                  return "main_validate_email".tr;
                }
                if (!validateCivilID(value) && inputType == 'civilid') {
                  return "main_validate_civilid".tr;
                }
                if (!validatePhone(value) && inputType == 'phone') {
                  return "main_validate_phone".tr;
                }
                if (!validatePin(value) && inputType == 'pin') {
                  return "main_validate_pin".tr;
                }
                if (validators != null) {
                  String validationText = validateRegEx(value, validators);
                  if (validationText != 'S') {
                    return validationText;
                  }
                }
              }
              return null;
            },
          ),
        ),
      ),
    ],
  );
}

Widget myDropDownMenu(
    {required label,
    required Map<String, dynamic> valuesMap,
    selectedValue,
    canBeEmpty = true,
    justRead = false,
    changeFunction,
    double textSize = 16,
    Color? labelColor, // color of text field label
    Color textColor = myDarkGreyColor, // color of text input
    bool filled = _defaultFilled,
    Color? fillingColor, // color of text field fill
    double fillingOpacity = _defaultFillingOpacity,
    bool hasborder = _defaultHasBorder,
    Color? borderColor, // color of border
    double radius = 10.0,
    Icon? prefix,
    Icon? suffix,
    double verticalPadding = _defaultVerticalPadding,
    double horizontalPadding = 2.0,
    double elevation = 4.0}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: IgnorePointer(
        ignoring: justRead,
        child: PhysicalModel(
          borderRadius: BorderRadius.circular(radius),
          color: myWhiteColor,
          elevation: elevation,
          shadowColor: myMainColor.withOpacity(0.5),
          child: DropdownButtonFormField2(
            iconStyleData: IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down),
              iconEnabledColor: justRead ? myMidGreyColor : myMainColor,
              iconSize: 20,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  getCurrentLocaleString() == 'ar' ? 12 : 0,
                  8,
                  getCurrentLocaleString() == 'en' ? 12 : 0,
                  8),
              filled: filled,
              fillColor: fillingColor ??
                  _defaultFillingColor.withOpacity(fillingOpacity),
              alignLabelWithHint: true,
              labelText: '   ' + (canBeEmpty ? label : (label)),
              labelStyle: TextStyle(
                  color: labelColor ?? myMainColor, fontSize: textSize),
              floatingLabelBehavior: hasborder
                  ? FloatingLabelBehavior.auto
                  : FloatingLabelBehavior.never,
              floatingLabelStyle: TextStyle(
                color: labelColor ?? myMainColor,
                fontSize: textSize,
              ),
              prefixIcon: prefix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: prefix,
                    ),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: suffix,
                    ),
              border: OutlineInputBorder(
                  borderSide: hasborder
                      ? BorderSide(
                          color: borderColor ?? myMainColor, width: 1.0)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(radius)),
              enabledBorder: OutlineInputBorder(
                  borderSide: hasborder
                      ? BorderSide(
                          color: borderColor ?? myMainColor, width: 1.0)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(radius)),
              errorBorder: OutlineInputBorder(
                  borderSide: hasborder
                      ? BorderSide(color: myFailedColor, width: 1.0)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(radius)),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: myLightGreyColor,
              ),
              scrollbarTheme: ScrollbarThemeData().copyWith(
                thumbColor: MaterialStateProperty.all(myMainColor),
                mainAxisMargin: 8,
                crossAxisMargin: 6,
                radius: Radius.circular(radius),
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            items: List.generate(
              valuesMap.length,
              (index) => DropdownMenuItem<String>(
                value: valuesMap.keys.elementAt(index),
                child: myLable(
                    text: valuesMap.values.elementAt(index), maxline: 1),
              ),
            ),
            isExpanded: true,
            validator: (value) {
              if ((value == null || value == '') && !canBeEmpty) {
                return 'main_not_empty'.tr;
              }
              return null;
            },
            onChanged: changeFunction,
            value: selectedValue,
          ),
        )),
  );
}

Widget myDatePicker({
  required BuildContext context,
  required TextEditingController textController,
  String label = '',
  Color? labelColor,
  Color? TextColor,
  Color? iconColor,
  required changeFunc,
  bool allowPastDate = true,
  bool canBeEmpty = true,
  int firstYear = 1800,
  int lastYear = 2200,
  bool justRead = false,
  bool hasBorder = _defaultHasBorder,
  double verticalPadding = _defaultVerticalPadding,
  double horizontalPadding = 2.0,
}) {
  labelColor ??= myMainColor;
  TextColor ??= myMainColor;
  iconColor ??= myMainColor;

  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: InkWell(
      child: IgnorePointer(
        child: myTextField(
            verticalPadding: 0,
            horizontalPadding: 0,
            label: label,
            labelColor: labelColor,
            textColor: TextColor,
            textController: textController,
            canBeEmpty: canBeEmpty,
            prefix: Icon(
              Icons.calendar_month,
              color: iconColor,
            ),
            hasborder: hasBorder),
      ),
      onTap: justRead
          ? null
          : () {
              showDatePicker(
                context: context,
                initialDate: (textController.text == '')
                    ? DateTime.now()
                    : DateFormat(myDateFormatText).parse(textController.text),
                firstDate: allowPastDate ? DateTime(firstYear) : DateTime.now(),
                lastDate: DateTime(lastYear),
                locale: Get.locale,
              ).then(changeFunc);
            },
    ),
  );
}

Widget myDateTimePicker({
  required BuildContext context,
  required TextEditingController textController,
  String label = '',
  Color? labelColor,
  Color? TextColor,
  Color? iconColor,
  required Function(DateTime?) changeFunc,
  bool allowPastDate = true,
  bool canBeEmpty = true,
  int firstYear = 1800,
  int lastYear = 2200,
  bool justRead = false,
  bool hasBorder = _defaultHasBorder,
  double verticalPadding = _defaultVerticalPadding,
  double horizontalPadding = 2.0,
  String? dateTimeFormat, // Optional custom format
}) {
  labelColor ??= myMainColor;
  TextColor ??= myMainColor;
  iconColor ??= myMainColor;

  // Use custom format or default to DD-MM-YYYY HH24:MI:SS format
  String displayFormat = dateTimeFormat ?? 'dd-MM-yyyy HH:mm:ss';

  Future<void> _selectDateTime() async {
    if (justRead) return;

    // Parse current date/time from text controller if available
    DateTime initialDateTime = DateTime.now();
    if (textController.text.isNotEmpty) {
      try {
        // Try parsing with the display format first
        initialDateTime = DateFormat(displayFormat).parse(textController.text);
      } catch (e) {
        try {
          // Fallback to parsing just the date part
          initialDateTime =
              DateFormat(myDateFormatText).parse(textController.text);
        } catch (e2) {
          // If both fail, use current date/time
          initialDateTime = DateTime.now();
        }
      }
    }

    // First, show date picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: allowPastDate ? DateTime(firstYear) : DateTime.now(),
      lastDate: DateTime(lastYear),
      locale: Get.locale,
    );

    if (selectedDate != null) {
      // Then show time picker
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        builder: (context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        // Combine date and time
        DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
          0, // seconds
        );

        // Update text controller with formatted date/time
        textController.text =
            DateFormat(displayFormat).format(combinedDateTime);

        // Call the change function
        changeFunc(combinedDateTime);
      } else {
        // If user cancels time picker, still call changeFunc with selected date at current time
        DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          initialDateTime.hour,
          initialDateTime.minute,
          0, // seconds
        );

        textController.text =
            DateFormat(displayFormat).format(combinedDateTime);
        changeFunc(combinedDateTime);
      }
    }
  }

  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: InkWell(
      child: IgnorePointer(
        child: myTextField(
            verticalPadding: 0,
            horizontalPadding: 0,
            label: label,
            labelColor: labelColor,
            textColor: TextColor,
            textController: textController,
            canBeEmpty: canBeEmpty,
            prefix: Icon(
              Icons.calendar_today_outlined,
              color: iconColor,
            ),
            suffix: Icon(
              FontAwesomeIcons.clock,
              size: 16,
              color: iconColor,
            ),
            hasborder: hasBorder),
      ),
      onTap: _selectDateTime,
    ),
  );
}

Widget myMultiSelectContainer(
    {required BuildContext context,
    required List<MultiSelectCard<String>> items,
    MultiSelectController<String>? controller,
    String? label,
    int maxSelectCount = 1,
    double verticalPadding = 5}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      label == null
          ? Container()
          : Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
              child: myLable(
                text: label,
              ),
            ),
      MultiSelectContainer(
        itemsPadding: EdgeInsets.all(0),
        maxSelectableCount: maxSelectCount,
        onMaximumSelected: (allSelectedItems, selectedItem) {
          myToast(
              context: context,
              text: 'max_cbList_selected'.tr + maxSelectCount.toString(),
              statusCode: 'F');
        },
        controller: controller,
        items: items,
        onChange: (allSelectedItems, selectedItem) {},
        textStyles:
            MultiSelectTextStyles(textStyle: TextStyle(color: myMainColor)),
        prefix: MultiSelectPrefix(
            selectedPrefix: const Padding(
              padding: EdgeInsets.only(right: 5),
              child: Icon(
                Icons.check,
                color: myWhiteColor,
                size: 14,
              ),
            ),
            enabledPrefix: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Icon(
                Icons.add,
                color: myMainColor,
                size: 14,
              ),
            ),
            disabledPrefix: const Padding(
              padding: EdgeInsets.only(right: 5),
              child: Icon(
                Icons.do_disturb_alt_sharp,
                color: myFailedColor,
                size: 14,
              ),
            )),
        itemsDecoration: MultiSelectDecorations(
          decoration: BoxDecoration(
              color: myWhiteColor,
              // gradient: LinearGradient(colors: [mySubColor, myLightGreyColor]),
              border: Border.all(color: mySubColor),
              borderRadius: BorderRadius.circular(20)),
          selectedDecoration: BoxDecoration(
              // gradient: LinearGradient(colors: [
              //   myColorDarkness(color: mySuccessColor, percent: 60),
              //   myColorDarkness(color: mySuccessColor, percent: 30)
              // ]),
              color: myMainColor,
              border: Border.all(color: myMainColor),
              borderRadius: BorderRadius.circular(5)),
          disabledDecoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ],
  );
}

String getCurrentTimeString() {
  return DateFormat.jm(Get.locale.toString()).format(DateTime.now());
}

String getDateTimeString({required String date, required String time}) {
  TimeOfDay convertedTime =
      TimeOfDay.fromDateTime(DateFormat.jm(Get.locale.toString()).parse(time));
  String timeWithFormat = DateFormat('hh:mm a')
      .format(DateTime(2000, 1, 1, convertedTime.hour, convertedTime.minute));
  return date + ' ' + timeWithFormat;
}

Widget myTimePicker({
  required BuildContext context,
  required TextEditingController textController,
  String label = '',
  Color? labelColor,
  Color? TextColor,
  Color? iconColor,
  required changeFunc,
  bool canBeEmpty = true,
  bool justRead = false,
  bool hasBorder = _defaultHasBorder,
  double verticalPadding = _defaultVerticalPadding,
  double horizontalPadding = 2.0,
}) {
  labelColor ??= myMainColor;
  TextColor ??= myMainColor;
  iconColor ??= myMainColor;

  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: InkWell(
      child: IgnorePointer(
        child: myTextField(
            verticalPadding: 0,
            horizontalPadding: 0,
            label: label,
            labelColor: labelColor,
            textColor: TextColor,
            textController: textController,
            canBeEmpty: canBeEmpty,
            prefix: Icon(
              FontAwesomeIcons.clock,
              color: iconColor,
            ),
            hasborder: hasBorder),
      ),
      onTap: justRead
          ? null
          : () {
              showTimePicker(
                context: context,
                initialTime: textController.text.isEmpty
                    ? TimeOfDay.now()
                    : TimeOfDay.fromDateTime(
                        DateFormat.jm(Get.locale.toString())
                            .parse(textController.text)),
                builder: (context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: false),
                    child: child!,
                  );
                },
              ).then(changeFunc);
            },
    ),
  );
}

Widget myButton(
    {required String
        buttonType, // 'simple' = text & image, 'line', 'widget', 'link', 'image', 'icon'
    String? text,
    String imageSource = 'asset',
    imagePath, // text or iconData
    widgetsList,
    flexList,
    widget,
    onpressed,
    ///////////////////////////
    double textSize = 16.0,
    double minTextSize = 8.0,
    int maxline = 1000, // in case of 'link'
    Color textColor = myWhiteColor,
    Color imageColor = myWhiteColor,
    Color? buttonColor,
    Color? bordercolor,
    Color shadowColor = myBlackColor,
    double elevation = 5,
    double buttonHeight = _defaultButtonHeight,
    double borderRadius = 10.0,
    bool isMinSize = false,
    bool isStart = false,
    double verticalPadding = _defaultVerticalPadding,
    double horizontalPadding = 2.0,
    bool isbold = true,
    bool? isUnderline,
    double widthBetwwenTextIcon = 20.0,
    double imageHeight = 25.0,
    double imageWidth = 25.0}) {
  buttonColor ??= myMainColor;
  bordercolor ??= myMainColor;
  if ((buttonType == 'simple' && text == null && imagePath == null) ||
      (buttonType == 'line' && (widgetsList == null && flexList == null)) ||
      (buttonType == 'widget' && widget == null) ||
      (buttonType == 'link' && text == null) ||
      (buttonType == 'icon' && imagePath == null)) {
    myLogError('myButton Error for type: $buttonType');
    return myLable(text: '');
  }

  if (buttonType == 'simple') {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        child: Container(
          height: buttonHeight,
          child: ElevatedButton(
            child: myLine(widgetsList: [
              myLable(
                  text: text ?? '',
                  textColor: textColor,
                  iscenter: true,
                  isbold: isbold,
                  isUnderline: isUnderline ?? false,
                  maxline: 1,
                  textSize: textSize,
                  minTextSize: minTextSize),
              SizedBox(width: widthBetwwenTextIcon),
              imagePath == null
                  ? Container()
                  : myImage(
                      imageSource: imageSource,
                      imagePath: imagePath ?? '',
                      height: imageHeight,
                      width: imageWidth,
                      color: imageColor),
            ], flexList: [
              text != null ? ((text.length / 2).floor()) : 0,
              text != null && imagePath != null ? 1 : 0,
              imagePath != null ? 1 : 0,
            ], isStart: isStart, isMinSize: isMinSize, iscenter: true),
            onPressed: onpressed,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: mySubTowColor,
              shadowColor: shadowColor,
              elevation: elevation,
              backgroundColor: buttonColor,
              // splashFactory: NoSplash.splashFactory,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: onpressed == null ? mySubTowColor : bordercolor),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ));
  } else if (buttonType == 'line') {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        child: Container(
          height: buttonHeight,
          child: ElevatedButton(
            child: myLine(
                widgetsList: widgetsList,
                flexList: flexList,
                isStart: isStart,
                isMinSize: isMinSize),
            onPressed: onpressed,
            style: ElevatedButton.styleFrom(
              shadowColor: shadowColor,
              elevation: elevation,
              backgroundColor: buttonColor,
              // splashFactory: NoSplash.splashFactory,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: bordercolor),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ));
  } else if (buttonType == 'widget') {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: TextButton(
        onPressed: onpressed,
        child: widget,
      ),
    );
  } else if (buttonType == 'link') {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: TextButton(
        onPressed: onpressed,
        child: myLable(
            text: text ?? '',
            iscenter: true,
            isbold: isbold,
            isUnderline: isUnderline ?? true,
            textSize: textSize,
            textColor: myMainColor,
            minTextSize: minTextSize,
            maxline: maxline),
      ),
    );
  } else if (buttonType == 'icon') {
    return IconButton(
        onPressed: onpressed,
        icon: Icon(imagePath ?? '', size: imageHeight, color: imageColor));
  } else if (buttonType == 'image') {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: InkWell(
        child: myImage(
            imageSource: imageSource,
            imagePath: imagePath ?? '',
            height: imageHeight,
            width: imageWidth,
            color: imageColor),
        onTap: onpressed,
      ),
    );
  }

  myLogError(
    'Check Button Type',
  );
  return myLable(
    text: '',
  );
}

Widget myLine(
    {required List<Widget> widgetsList,
    required List<int> flexList,
    bool isMinSize = false,
    bool isStart = false,
    bool isEnd = false,
    bool isSpaceBetween = false,
    bool isSpaceEvenly = false,
    bool isVerticalEnd = false,
    bool isVerticalTop = false,
    iscenter = false}) {
  if (widgetsList.length != flexList.length) {
    myLogError(
        'Flex Error (widgets length = ${widgetsList.length}) (flex length = ${flexList.length})');
    return myLable(text: '');
  }

  List<int> nonZeroIndecies = [];

  for (int i = 0; i < flexList.length; i++) {
    if (flexList[i] != 0) {
      nonZeroIndecies.add(i);
    }
  }

  //// mylog('non zero indecies: ' + nonZeroIndecies.toString());

  return Row(
    mainAxisSize: isMinSize ? MainAxisSize.min : MainAxisSize.max,
    mainAxisAlignment: isMinSize
        ? MainAxisAlignment.center
        : (isStart
            ? MainAxisAlignment.start
            : (isEnd
                ? MainAxisAlignment.end
                : (isSpaceEvenly
                    ? MainAxisAlignment.spaceEvenly
                    : isSpaceBetween
                        ? MainAxisAlignment.spaceBetween
                        : iscenter
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween))),
    crossAxisAlignment: isVerticalEnd
        ? CrossAxisAlignment.end
        : isVerticalTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
    children: List.generate(nonZeroIndecies.length, (indx) {
      return flexList[nonZeroIndecies[indx]] > 0
          ? Flexible(
              flex: flexList[nonZeroIndecies[indx]],
              child: widgetsList[nonZeroIndecies[indx]],
            )
          : Container(
              width: (-1 * flexList[nonZeroIndecies[indx]]).toDouble(),
              child: widgetsList[nonZeroIndecies[indx]],
            );
    }),
  );
}

Widget myLoading({
  String loadingStatus = 'l',
  Color? spinColor,
//   {
//   'l': 'Loading',
//   'w': 'Waiting(short time)',
//   'lw': 'Long waiting(long time) Loading',
//   'n': 'No Data Found',
//   'e': 'Error'
//   'ce': Connection error
//   's': Success
//  }
}) {
  spinColor ??= myMainColor;
  loadingStatus = loadingStatus.toLowerCase();
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (loadingStatus == 'l' || loadingStatus == 'w' || loadingStatus == 'lw')
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: //SpinKitWave
                    SpinKitCircle(
                  color: spinColor,
                  size: 50.0,
                ))
            : Container(),
        (loadingStatus == 'w' || loadingStatus == 'lw')
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: myLable(
                    text: loadingStatus == 'lw'
                        ? 'main_loading_wait'.tr
                        : 'main_loading'.tr,
                    iscenter: true,
                    isbold: true,
                    textColor: myBlackColor,
                    textSize: 16),
              )
            : Container(),
        (loadingStatus == 'n' || loadingStatus == 'e' || loadingStatus == 'ce')
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: myLable(
                  text: loadingStatus == 'n'
                      ? "main_nodata".tr
                      : (loadingStatus == 'ce'
                          ? 'main_connectionerror'.tr
                          : 'main_dataerror'.tr),
                  iscenter: true,
                  isUnderline: true,
                  isbold: true,
                  textColor: loadingStatus == 'n' ? myInfoColor : myFailedColor,
                  textSize: 17,
                ),
              )
            : Container(),
      ]);
}

Widget myChangeLanguage(
    {required BuildContext context,
    double height = 5,
    bool ShowSkip = false,
    Color? SkipColor,
    bool showLang = true}) {
  SkipColor ??= myMainColor;
  return SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(10, height, 10, 0),
      child: myLine(widgetsList: [
        showLang
            ? myButton(
                buttonHeight: 30,
                isMinSize: true,
                textSize: 14,
                textColor: myMainColor,
                elevation: 0,
                buttonColor: myWhiteColor.withOpacity(0.7),
                buttonType: 'simple',
                imageSource: 'icon',
                widthBetwwenTextIcon: 5.0,
                imageWidth: 19,
                imageHeight: 19,
                imagePath: FontAwesomeIcons.globe,
                imageColor: myMainColor,
                text: getCurrentLocaleString(),
                onpressed: () {
                  utilChangeLanguage(context);
                })
            : Container(),
        TextButton(
            onPressed: () {
              Get.offAll(
                loginPage(),
                transition: Transition.fade,
                duration: const Duration(
                  milliseconds: 500,
                ),
              );
            },
            child: myLable(
                text: 'Skip', textColor: SkipColor, isbold: true, textSize: 16))
      ], flexList: [
        1,
        ShowSkip ? 1 : -0
      ], isSpaceBetween: true, isVerticalTop: true),
    ),
  );
}

Widget myAnimatedText(
    {required List<String> ListOfStrings,
    onTap,
    Color? textColor,
    int repeatCount = 0, // send 0 for infinite repeate
    int durationMilliSeconds = 100,
    double fontSize = 16,
    bool isBold = false,
    double verticalPadding = _defaultVerticalPadding}) {
  textColor ??= myMainColor;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: verticalPadding),
    child: AnimatedTextKit(
      repeatForever: repeatCount == 0 ? true : false,
      totalRepeatCount: repeatCount,
      animatedTexts: ListOfStrings.map((text) {
        return TyperAnimatedText(text,
            speed: Duration(milliseconds: durationMilliSeconds),
            textStyle: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal));
      }).toList(),
      onTap: onTap,
    ),
  );
}

Widget myCheckBoxTile(
    {required String label,
    required bool isChecked,
    required changeFunction,
    bool isBold = false,
    double textSize = 16,
    Color? activeColor,
    Color activeCheckColor = myWhiteColor,
    Color? textColor,
    int maxLine = 1,
    double minTextSize = -1,
    double verticalPadding = _defaultVerticalPadding,
    double horizontalPadding = 0,
    bool isStartBox = true,
    bool isCercle = false,
    secondaryWidget}) {
  activeColor ??= myMainColor;
  textColor ??= myMainColor;
  if (minTextSize == -1) {
    minTextSize = textSize;
  }
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: isStartBox
          ? ListTileControlAffinity.leading
          : ListTileControlAffinity.trailing,
      title: myLable(
          text: label,
          isbold: isBold,
          textSize: textSize,
          textColor: textColor,
          maxline: maxLine,
          minTextSize: minTextSize),
      value: isChecked,
      onChanged: changeFunction,
      activeColor: activeColor,
      checkColor: activeCheckColor,
      side: BorderSide(color: myMainColor),
      checkboxShape: isCercle
          ? CircleBorder(
              side: BorderSide(color: mySubTowColor),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
      secondary: secondaryWidget,
    ),
  );
}

Widget myCustomCheckBox({
  required String label,
  required bool isChecked,
  required changeFunction,
  bool isBold = false,
  double textSize = 16,
  Color? activeColor,
  Color activeCheckColor = myWhiteColor,
  Color? textColor,
  int maxLine = 1,
  double minTextSize = -1,
  double verticalPadding = _defaultVerticalPadding,
  double horizontalPadding = 0,
  bool isStartBox = true,
  bool isCercle = false,
  Widget? secondaryWidget,
}) {
  activeColor ??= myMainColor;
  textColor ??= myMainColor;
  if (minTextSize == -1) {
    minTextSize = textSize;
  }

  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: InkWell(
      onTap: () => changeFunction(!isChecked),
      child: myLine(widgetsList: [
        Checkbox(
          value: isChecked,
          side: BorderSide(width: 1, color: myMainColor),
          onChanged: changeFunction,
          activeColor: activeColor,
          checkColor: activeCheckColor,
          shape: isCercle
              ? CircleBorder()
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        myLable(
          text: label,
          isbold: isBold,
          textSize: textSize,
          textColor: textColor,
          maxline: maxLine,
          minTextSize: minTextSize,
        ),
        // secondaryWidget ?? SizedBox(), // Display secondary widget if provided
      ], flexList: [
        -30,
        1
      ], isStart: true),
    ),
  );
}

Widget mySVGimage(
    {required String name,
    double height = double.infinity,
    double width = double.infinity}) {
  return Container(
    height: height,
    width: width,
    child: SvgPicture.asset(
      'imagesSvg/$name.svg',
      fit: BoxFit.fill,
    ),
  );
}

myBadgeWidget(
    {bool showBadge = true,
    int bagdeCount = 0,
    Widget? badgeWidget,
    required Widget mainWidget}) {
  return badges.Badge(
      position: badges.BadgePosition.topEnd(),
      showBadge: showBadge,
      badgeContent: badgeWidget != null
          ? badgeWidget
          : myLable(text: bagdeCount.toString(), textColor: myWhiteColor),
      child: mainWidget);
}

Widget myImage(
    {required String imageSource, // 'asset', 'api', 'url', 'icon' , 'badge'
    required imagePath, // In case of ('asset', 'api', 'url') send path as string // In case of ('icon') send IconData
    required double height,
    required double width,
    bagdeCount,
    Color? color = null,
    bool hasBorder = false,
    Color? borderColor,
    double borderWidth = 1.0,
    double radius = 0,
    bool isfill = false}) {
  borderColor ??= myMainColor;

  getImage() {
    if (imageSource == 'api') {
      return Image.memory(
        base64Decode(imagePath),
        height: height,
        width: width,
        color: color,
        fit: BoxFit.fill,
      );
    } else if (imageSource == 'url') {
      return CachedNetworkImage(
        fit: BoxFit.fill,
        imageUrl: imagePath,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Shimmer.fromColors(
          baseColor: myMidGreyColor,
          highlightColor: myWhiteColor,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: myMidGreyColor,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
        fadeInDuration: Duration(seconds: 1),
      );
    } else if (imageSource == 'asset') {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        color: color,
        fit: isfill ? BoxFit.fill : null,
      );
    } else {
      return Container();
    }
  }

  if (imageSource == 'icon') {
    return Icon(
      imagePath,
      size: width,
      color: color,
    );
  } else if (imageSource == 'badge') {
    return Obx(() => badges.Badge(
        showBadge: bagdeCount == 0 ? false : true,
        badgeContent:
            myLable(text: bagdeCount.toString(), textColor: myWhiteColor),
        child: Icon(
          imagePath,
          size: width,
          color: color,
        )));
  } else {
    return Container(
      decoration: hasBorder
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            )
          : null,
      height: height,
      width: width,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius), child: getImage()),
    );
  }
}

Color myColorDarkness({
  required Color color,
  required double percent,
}) {
  final hslColor = HSLColor.fromColor(color);
  // final hslLight = hslColor.lightness;
  final changedColor =
      hslColor.withLightness(((100 - percent) / 100).clamp(0.0, 1.0));

  return changedColor.toColor();
}

myGradiantWidget({required Widget widget, colorsList}) {
  if (colorsList == null) {
    colorsList = [
      myColorDarkness(color: myMainColor, percent: 80),
      myColorDarkness(color: myMainColor, percent: 55),
      myColorDarkness(color: myMainColor, percent: 30),
    ];
  }
  return ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (Rect bounds) => LinearGradient(
      colors: colorsList, // Your gradient colors
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds),
    child: widget,
  );
}

Widget myIcon(
    {String? iconSource = '', String? iconCat = '', String? iconText = ''}) {
  // default icons
  if (iconText == '' || iconText == null) {
    if (iconCat == 'not') {
      return Icon(Icons.notifications, color: myMainColor);
    } else if (iconCat == 'srv') {
      return Image.asset(
        'icons/white.png',
      );
    } else if (iconCat == 'flg') {
      return Container(
        height: 40,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Icon(
          FontAwesomeIcons.globe,
          size: 36,
          color: myMainColor,
        ),
      );
    } else if (iconCat == 'kw-flag') {
      return Container(
        height: 40,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          image: DecorationImage(
            image: AssetImage('icons/KW.png'),
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Image.asset(
        'icons/privacy.png',
      );
    }
  }
  // specific icons
  else {
    if (iconSource == 'api') {
      return Image.memory(
        base64Decode(iconText),
      );
    } else if (iconSource == 'url') {
      return Container(
        height: 38,
        width: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          image: DecorationImage(
            image: NetworkImage(iconText),
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Image.asset(
        iconText,
      );
    }
  }
}

Widget myPageViewController({
  required PageController controller,
  required int count,
  Color activeColor = myLightGreyColor,
  Color? inactiveColor, // Dark blue
  bool isVertical = false,
  double activeHeight = 8.0,
  double activeWidth = 40.0,
  double inactiveHeight = 8.0,
  double inactiveWidth = 8.0,
}) {
  inactiveColor ??= myMainColor;
  return SmoothPageIndicator(
    axisDirection: isVertical ? Axis.vertical : Axis.horizontal,
    controller: controller,
    count: count,
    effect: CustomizableEffect(
      activeDotDecoration: DotDecoration(
        width: activeWidth, // pill width
        height: activeHeight, // pill height
        color: activeColor,
        borderRadius: BorderRadius.circular(50),
      ),
      dotDecoration: DotDecoration(
        width: inactiveWidth,
        height: inactiveHeight,
        color: inactiveColor,
        borderRadius: BorderRadius.circular(100),
      ),
      spacing: 6.0,
    ),
  );
}

Widget myExpansionTile(
    {required Widget titleWidget,
    required List<Widget> widgetsList,
    Color? borderColor,
    Color? collapsedCardColor,
    Color openedCardColor = myWhiteColor,
    Color collapsedIconColor = myBlackColor,
    Color? openedIconColor,
    bool initExpanded = false,
    double elevation = 3.0,
    double radius = 20,
    double borderWidth = 1.2,
    double collapsedCardColorOpacity = 0.1,
    double tileVerticalPadding = 4.0,
    double bodyHorizontalPadding = 15.0,
    double bodyBottomPadding = 20.0,
    bool canOpen = true,
    ExpansionTileController? expansionController}) {
  borderColor ??= myMainColor;
  collapsedCardColor ??= myMainColor;
  openedIconColor ??= myMainColor;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: tileVerticalPadding),
    child: Card(
      elevation: 0,
      shape: InputBorder.none,
      clipBehavior: Clip.antiAlias,
      child: IgnorePointer(
        ignoring: canOpen ? false : true,
        child: ExpansionTile(
          controller: expansionController,
          tilePadding: EdgeInsets.all(0),
          shape: InputBorder.none,
          initiallyExpanded: initExpanded,
          collapsedBackgroundColor:
              collapsedCardColor.withOpacity(collapsedCardColorOpacity),
          collapsedIconColor: collapsedIconColor,
          backgroundColor: openedCardColor,
          iconColor: openedIconColor,
          title: titleWidget,
          children: widgetsList,
          childrenPadding: EdgeInsets.fromLTRB(bodyHorizontalPadding, 0,
              bodyHorizontalPadding, bodyBottomPadding),
        ),
      ),
    ),
  );
}

mySheet(
    {required BuildContext context,
    required List<Widget> widgetsList,
    double toppadding = 30.0,
    double bottompadding = 30.0,
    double horizontalPadding = 15.0}) {
  return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(maxHeight: myDeviceSize(context, 'h') * 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return RawScrollbar(
          thumbColor: myMainColor,
          radius: Radius.circular(10),
          thickness: 4,
          mainAxisMargin: 15,
          crossAxisMargin: 6,
          thumbVisibility: true,
          child: SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(
                            top: toppadding,
                            bottom: bottompadding,
                            right: horizontalPadding,
                            left: horizontalPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widgetsList,
                        )),
                  ),
                ),
              )),
        );
      });
}

myLoadingSheet(BuildContext context, futureFunction) async {
  await futureFunction;
  mySheet(context: context, widgetsList: [myLoading()]);
}

Future<void> myDialog(
    {required context,
    required String statusCode,
    required String textTitle,
    required String textDetails,
    Color backgroundColor = myWhiteColor,
    confirmAction,
    cancelAction,
    String? confirmText,
    String? cancelText,
    bool hasSuccessImage = false,
    bool hasFailedImage = false,
    Color confrimTextColor = myWhiteColor}) async {
  Color statusColor = myGetStatusColor(statusCode);
  FocusScope.of(context).unfocus();
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: true, // can click back
        child: AlertDialog(
          backgroundColor: backgroundColor,
          icon: ((statusCode == 'S' && hasSuccessImage) ||
                  (statusCode == 'F' && hasFailedImage))
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Container(
                    height: myDeviceSize(context, 'W') * 0.4,
                    width: myDeviceSize(context, 'W') * 0.4,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              statusCode == 'F'
                                  ? 'images/dialogfailed.png'
                                  : 'images/dialogsuccess.png',
                            ),
                            fit: BoxFit.fill)),
                  ),
                ))
              : Container(),
          title: Text(
            textTitle,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: myBlackColor,
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            myLine(widgetsList: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: TextButton(
                    // confirm button
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: myMainColor),
                          borderRadius: BorderRadius.circular(20),
                          color: myWhiteColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          cancelText ?? 'main_canceltext'.tr,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: myMainColor,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      // cancelAction();
                    }),
              ),
              confirmAction == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: TextButton(
                          // confirm button
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                confirmText ?? 'main_confirmtext'.tr,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: confrimTextColor,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                            confirmAction();
                          }),
                    ),
            ], flexList: [
              1,
              1
            ], isSpaceBetween: true)
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(48))),
          elevation: 10,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  textDetails,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

myAPIResultDialog({required responseMap, required context}) {
  myDialog(
      context: context,
      statusCode: responseMap['successFlag'].toString() == 'T' ? 'S' : 'F',
      textTitle: responseMap['successFlag'].toString() == 'T'
          ? 'main_goodTitle'.tr
          : "main_error".tr,
      textDetails: responseMap['resultMessage']);
}

myToast(
    {required context,
    required String text,
    required String statusCode,
    int duartion = 3}) {
  Color statusColor = myGetStatusColor(statusCode);
  FToast fToast;
  fToast = FToast();
  fToast.init(context);
  fToast.showToast(
    toastDuration: Duration(seconds: duartion),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: statusColor),
          borderRadius: BorderRadius.circular(15),
          color: statusColor),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: myLine(isMinSize: true, widgetsList: [
          myLable(text: text, textColor: myWhiteColor, textSize: 16),
          SizedBox(
            width: 10,
          ),
          Icon(
            myGetStatusIcon(statusCode),
            color: myWhiteColor,
          )
        ], flexList: [
          6,
          1,
          1
        ]),
      ),
    ),
    gravity: ToastGravity.BOTTOM,
  );
}

mySnack(
    {required String title,
    required String body,
    required Icon icon,
    Color? backgroundColor,
    Color textColor = myWhiteColor,
    bool isTopPosition = false,
    int duration = 5,
    Function? onTap}) {
  backgroundColor ??= myMainColor;
  Get.snackbar(title, body,
      icon: icon,
      snackPosition: isTopPosition ? SnackPosition.TOP : SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: Duration(seconds: duration), onTap: (snackbar) {
    if (onTap != null) {
      Get.back();
      myLog('Snackbar tapped!');
      onTap();
    }
  },
      messageText: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 80,
          ),
          child: SingleChildScrollView(
            child: Text(
              body,
              style: TextStyle(
                color: textColor,
              ),
            ),
          )));
}

List<Map<String, String>> myAttachmentsMap(
    List<AttachmentTemplate> attachments) {
  List<Map<String, String>> values = [];
  String filePath;
  String fileExtension;

  attachments.forEach((att) {
    if (att.fPResult.files.isNotEmpty) {
      filePath = att.fPResult.files[0].path.toString();
      fileExtension = pathPKG.extension(filePath);
      values.add({
        'key': att.id,
        'value': myFileToBase64(filePath),
        'type': 'file',
        'extension': fileExtension.split('.').last,
      });
    }
    if (att.imagePicker != null) {
      filePath = att.imagePicker!.path;
      fileExtension = pathPKG.extension(filePath);
      values.add({
        'key': att.id,
        'value': myFileToBase64(att.imagePicker!.path),
        'type': 'file',
        'extension': fileExtension.split('.').last,
      });
    }
  });
  return values;
}

Future<String> myValidateAttachments(
    List<AttachmentTemplate> attachments) async {
  int requiredEmptyDocsCount = 0;
  List<String> extensions = [
    '.png',
    '.jpg',
    '.pdf',
    '.mp4',
    '.MOV'
  ]; // don't forget dot before extension
  int maxMegas = 25;

  String fileExist(index) {
    if (attachments[index].imagePicker != null) return 'image';
    if (attachments[index].fPResult.files.isNotEmpty) return 'file';
    return 'empty';
  }

  // for (int i = 0; i < attachments.length; i++) {
  //   if (fileExist(i) == 'image') {
  //
  //   }
  // }

  String errorRequired = '';
  String errorExtension = '';
  String errorSize = '';

  for (int i = 0; i < attachments.length; i++) {
    if (attachments[i].canBeEmpty == false &&
        attachments[i].fPResult.files.isEmpty &&
        attachments[i].imagePicker == null) {
      requiredEmptyDocsCount++;
      errorRequired += '\n' + '- ' + attachments[i].docDesc;
    }
  }

  if (requiredEmptyDocsCount > 0) {
    return 'main_attachments_not_empty'.tr +
        '\n' +
        'main_attachments_files_check'.tr +
        '\n' +
        errorRequired;
  }

  for (int i = 0; i < attachments.length; i++) {
    if (fileExist(i) == 'file') {
      String fileExtension =
          pathPKG.extension(attachments[i].fPResult.files[0].path.toString());
      if (!extensions.contains(fileExtension)) {
        errorExtension +=
            '\n' + '- ' + attachments[i].docDesc + ' ($fileExtension)';
      }
      if (attachments[i].fPResult.files[0].size > (maxMegas * 1024 * 1024)) {
        errorSize += '\n' + '- ' + attachments[i].docDesc;
      }
    }

    if (fileExist(i) == 'image') //image
    {
      String imageExtension =
          pathPKG.extension(attachments[i].imagePicker!.path);
      if (!extensions.contains(imageExtension)) {
        errorExtension +=
            '\n' + '- ' + attachments[i].docDesc + ' ($imageExtension)';
      }
      var imageLength = await attachments[i].imagePicker!.length();
      if (imageLength > (maxMegas * 1024 * 1024)) {
        errorSize += '\n' +
            '- ' +
            attachments[i].docDesc +
            ' (' +
            (imageLength / 1024 / 1024).toStringAsFixed(2) +
            'MB) ';
      }
    }
  }

  if (errorExtension.length > 0)
    return 'main_attachments_ext'.tr +
        ' ' +
        extensions.toString() +
        '. ' +
        'main_attachments_files_check'.tr +
        '\n' +
        errorExtension;

  if (errorSize.length > 0)
    return 'main_attachments_size'.tr +
        ' (' +
        maxMegas.toString() +
        ' ' +
        'mega'.tr +
        ') ' +
        'main_attachments_files_check'.tr +
        '\n' +
        errorSize;

  return 'T';
}

Widget myAttachmentsBlock(
    {required List<AttachmentTemplate> attachmentsList,
    String? blockTitle,
    String? blockBottomLabel,
    bool allowMore = false,
    double textSize = 17,
    bool allowFiles = true,
    bool allowGallery = true,
    bool allowCamera = true,
    bool allowVideo = false,
    double verticalPadding = _defaultVerticalPadding + 4,
    double horizontalPadding = 0.0,
    double opacity = 0.2,
    double imageSize = 100,
    int maxCountWithMore = -1}) {
  String fileExist(index) {
    if (attachmentsList[index].imagePicker != null) return 'image';
    if (attachmentsList[index].fPResult.files.isNotEmpty) return 'file';
    return 'empty';
  }

  int extraLastCount() {
    int lastCount =
        attachmentsList.lastIndexWhere((element) => element.isExtra);

    if (lastCount < 0) return 1;

    int found = int.parse(
        attachmentsList[lastCount].docDesc.split(': ').last.toString());

    return found + 1;
  }

  Widget uploadSheetLine(
      {required IconData icon, required String label, required onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: myLine(isStart: true, widgetsList: [
          myImage(
              imageSource: 'icon',
              imagePath: icon,
              height: 22,
              width: 22,
              color: myMainColor),
          Container(),
          myLable(
            text: label,
            textSize: 16,
            textColor: myBlackColor,
          )
        ], flexList: [
          -30,
          -10,
          1
        ]),
      ),
    );
  }

  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: StatefulBuilder(builder: (context, sheetsetState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blockTitle == null
              ? Container()
              : Column(children: [
                  myLable(text: blockTitle, textSize: textSize),
                  SizedBox(
                    height: 6,
                  )
                ]),
          ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(height: 8);
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: attachmentsList.length + 1,
              itemBuilder: (context, index) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: index == attachmentsList.length
                        ? ((allowMore &&
                                (maxCountWithMore == -1 ||
                                    maxCountWithMore > attachmentsList.length))
                            ? InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: myWhiteColor,
                                      border: Border.all(color: myMidGreyColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13.0, horizontal: 8),
                                        child: myLine(widgetsList: [
                                          myLable(text: 'Extra Attachment'),
                                          myImage(
                                              imageSource: 'icon',
                                              imagePath: FontAwesomeIcons.plus,
                                              color: myMainColor,
                                              height: 18,
                                              width: 18),
                                        ], flexList: [
                                          1,
                                          1
                                        ])),
                                  ),
                                ),
                                onTap: () {
                                  sheetsetState(() {
                                    attachmentsList.add(AttachmentTemplate(
                                      isExtra: true,
                                      canBeRemoved: true,
                                      docDesc: 'Extra Attachment' +
                                          ': ' +
                                          (extraLastCount()).toString(),
                                      id: (0).toString(),
                                    ));
                                  });
                                },
                              )
                            : Container())
                        : Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  attachmentsList[index].currentlyHasFile
                                      ? Container()
                                      : Container(
                                          // height: imageSize,
                                          decoration: BoxDecoration(
                                              color: myWhiteColor,
                                              border: Border.all(
                                                  color: myMidGreyColor),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          width: double.infinity,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13.0),
                                            child: InkWell(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: myLine(widgetsList: [
                                                  myLine(widgetsList: [
                                                    attachmentsList[index]
                                                            .canBeRemoved
                                                        ? myButton(
                                                            verticalPadding: 0,
                                                            buttonType: 'image',
                                                            imageSource: 'icon',
                                                            imagePath:
                                                                FontAwesomeIcons
                                                                    .xmark,
                                                            imageColor:
                                                                myFailedColor,
                                                            imageHeight: 18,
                                                            imageWidth: 18,
                                                            onpressed: () {
                                                              sheetsetState(() {
                                                                attachmentsList
                                                                    .removeAt(
                                                                        index);
                                                              });
                                                            },
                                                          )
                                                        : Container(),
                                                    myLable(
                                                        text: 'Upload Image'),
                                                  ], flexList: [
                                                    attachmentsList[index]
                                                            .canBeRemoved
                                                        ? -30
                                                        : 0,
                                                    1
                                                  ], isStart: true),
                                                  myImage(
                                                      imageSource: 'icon',
                                                      imagePath:
                                                          FontAwesomeIcons
                                                              .upload,
                                                      color: myMainColor,
                                                      height: 18,
                                                      width: 18),
                                                ], flexList: [
                                                  1,
                                                  1
                                                ]),
                                              ),
                                              onTap: () {
                                                mySheet(
                                                    toppadding: 20,
                                                    bottompadding: 20,
                                                    horizontalPadding: 25,
                                                    context: context,
                                                    widgetsList: [
                                                      !allowCamera
                                                          ? Container()
                                                          : uploadSheetLine(
                                                              icon: Icons
                                                                  .camera_alt,
                                                              label:
                                                                  'main_attachments_camera'
                                                                      .tr,
                                                              onTap: () async {
                                                                Future<bool>
                                                                    checkPermissions() async {
                                                                  try {
                                                                    // You can request multiple permissions at once.
                                                                    Map<Permission,
                                                                            PermissionStatus>
                                                                        statues =
                                                                        await [
                                                                      //add more permission to request here comma seperated
                                                                      Permission
                                                                          .camera
                                                                    ].request();

                                                                    //same way to check other permissions
                                                                    if (statues[
                                                                            Permission.camera]!
                                                                        .isDenied) {
                                                                      return false;
                                                                    }
                                                                    return true;
                                                                  } catch (e) {
                                                                    return false;
                                                                  }
                                                                }

                                                                bool
                                                                    permissionGiven =
                                                                    await checkPermissions();
                                                                try {
                                                                  if (permissionGiven) {
                                                                    if (fileExist(
                                                                            index) ==
                                                                        'empty') {
                                                                      attachmentsList[index].imagePicker = await ImagePicker().pickImage(
                                                                          source: ImageSource
                                                                              .camera,
                                                                          imageQuality:
                                                                              20);

                                                                      if (attachmentsList[index]
                                                                              .imagePicker !=
                                                                          null) {
                                                                        CroppedFile?
                                                                            croppedImage =
                                                                            await ImageCropper().cropImage(
                                                                          compressQuality:
                                                                              20,
                                                                          sourcePath: attachmentsList[index]
                                                                              .imagePicker!
                                                                              .path,
                                                                          uiSettings: [
                                                                            AndroidUiSettings(
                                                                              toolbarTitle: "main_attachments_editphoto".tr,
                                                                              toolbarColor: myMainColor,
                                                                              toolbarWidgetColor: myWhiteColor,
                                                                            ),
                                                                            IOSUiSettings(
                                                                              title: "main_attachments_editphoto".tr,
                                                                            )
                                                                          ],
                                                                        );

                                                                        if (croppedImage !=
                                                                            null) {
                                                                          attachmentsList[index].imagePicker =
                                                                              XFile(croppedImage.path);
                                                                        }
                                                                        Get.back();
                                                                        if (fileExist(index) ==
                                                                            'empty') {
                                                                          sheetsetState(
                                                                              () {
                                                                            attachmentsList[index].currentlyHasFile =
                                                                                false;
                                                                          });
                                                                        } else {
                                                                          sheetsetState(
                                                                              () {
                                                                            attachmentsList[index].currentlyHasFile =
                                                                                true;
                                                                          });
                                                                        }
                                                                      }
                                                                    } else {
                                                                      return myDialog(
                                                                        statusCode:
                                                                            "F",
                                                                        context:
                                                                            context,
                                                                        textTitle:
                                                                            'main_attachments_error'.tr,
                                                                        textDetails:
                                                                            'main_attachments_full'.tr,
                                                                      );
                                                                    }
                                                                  } else {
                                                                    myDialog(
                                                                        context:
                                                                            context,
                                                                        statusCode:
                                                                            'F',
                                                                        textTitle:
                                                                            'main_attachments_cant_complete'
                                                                                .tr,
                                                                        textDetails:
                                                                            'main_attachments_cant_upload_files'.tr);
                                                                  }
                                                                } catch (e) {
                                                                  myDialog(
                                                                      context:
                                                                          context,
                                                                      statusCode:
                                                                          'F',
                                                                      textTitle:
                                                                          'main_attachments_cant_complete'
                                                                              .tr,
                                                                      textDetails:
                                                                          'main_attachments_cant_upload_files'.tr +
                                                                              '!');
                                                                }
                                                              }),
                                                      (allowCamera &&
                                                              allowGallery)
                                                          ? Divider(
                                                              color:
                                                                  myMidGreyColor,
                                                              height: 2.0,
                                                            )
                                                          : Container(),
                                                      !allowGallery
                                                          ? Container()
                                                          : uploadSheetLine(
                                                              icon:
                                                                  FontAwesomeIcons
                                                                      .image,
                                                              label:
                                                                  'main_attachments_gallery'
                                                                      .tr,
                                                              onTap: () async {
                                                                Future<bool>
                                                                    checkPermissions() async {
                                                                  return true;
                                                                }

                                                                bool
                                                                    permissionGiven =
                                                                    await checkPermissions();
                                                                try {
                                                                  if (permissionGiven) {
                                                                    if (fileExist(
                                                                            index) ==
                                                                        'empty') {
                                                                      attachmentsList[index].imagePicker = await ImagePicker().pickImage(
                                                                          source: ImageSource
                                                                              .gallery,
                                                                          imageQuality:
                                                                              20);
                                                                      sheetsetState(
                                                                          () {
                                                                        attachmentsList[index].currentlyHasFile =
                                                                            true;
                                                                      });
                                                                      Get.back();
                                                                      if (fileExist(
                                                                              index) ==
                                                                          'empty') {
                                                                        sheetsetState(
                                                                            () {
                                                                          attachmentsList[index].currentlyHasFile =
                                                                              false;
                                                                        });
                                                                      } else {
                                                                        sheetsetState(
                                                                            () {
                                                                          attachmentsList[index].currentlyHasFile =
                                                                              true;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      return myDialog(
                                                                        statusCode:
                                                                            "F",
                                                                        context:
                                                                            context,
                                                                        textTitle:
                                                                            'main_attachments_error'.tr,
                                                                        textDetails:
                                                                            'main_attachments_full'.tr,
                                                                      );
                                                                    }
                                                                  } else {
                                                                    myDialog(
                                                                        context:
                                                                            context,
                                                                        statusCode:
                                                                            'F',
                                                                        textTitle:
                                                                            'main_attachments_cant_complete'
                                                                                .tr,
                                                                        textDetails:
                                                                            'main_attachments_cant_upload_files'.tr);
                                                                  }
                                                                } catch (e) {
                                                                  myDialog(
                                                                      context:
                                                                          context,
                                                                      statusCode:
                                                                          'F',
                                                                      textTitle:
                                                                          'main_attachments_cant_complete'
                                                                              .tr,
                                                                      textDetails:
                                                                          'main_attachments_cant_upload_files'.tr +
                                                                              '!');
                                                                }
                                                              }),
                                                      allowVideo
                                                          ? Divider(
                                                              color:
                                                                  myMidGreyColor,
                                                              height: 2.0,
                                                            )
                                                          : Container(),
                                                      !allowVideo
                                                          ? Container()
                                                          : uploadSheetLine(
                                                              icon: Icons
                                                                  .ondemand_video_rounded,
                                                              label: 'Video',
                                                              onTap: () async {
                                                                Future<bool>
                                                                    checkPermissions() async {
                                                                  return true;
                                                                }

                                                                bool
                                                                    permissionGiven =
                                                                    await checkPermissions();
                                                                try {
                                                                  if (permissionGiven) {
                                                                    if (fileExist(
                                                                            index) ==
                                                                        'empty') {
                                                                      attachmentsList[index]
                                                                              .imagePicker =
                                                                          await ImagePicker()
                                                                              .pickVideo(
                                                                        source:
                                                                            ImageSource.gallery,
                                                                      );
                                                                      sheetsetState(
                                                                          () {
                                                                        attachmentsList[index].currentlyHasFile =
                                                                            true;
                                                                      });
                                                                      Get.back();
                                                                      if (fileExist(
                                                                              index) ==
                                                                          'empty') {
                                                                        sheetsetState(
                                                                            () {
                                                                          attachmentsList[index].currentlyHasFile =
                                                                              false;
                                                                        });
                                                                      } else {
                                                                        sheetsetState(
                                                                            () {
                                                                          attachmentsList[index].currentlyHasFile =
                                                                              true;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      return myDialog(
                                                                        statusCode:
                                                                            "F",
                                                                        context:
                                                                            context,
                                                                        textTitle:
                                                                            'main_attachments_error'.tr,
                                                                        textDetails:
                                                                            'main_attachments_full'.tr,
                                                                      );
                                                                    }
                                                                  } else {
                                                                    myDialog(
                                                                        context:
                                                                            context,
                                                                        statusCode:
                                                                            'F',
                                                                        textTitle:
                                                                            'main_attachments_cant_complete'
                                                                                .tr,
                                                                        textDetails:
                                                                            'main_attachments_cant_upload_files'.tr);
                                                                  }
                                                                } catch (e) {
                                                                  myDialog(
                                                                      context:
                                                                          context,
                                                                      statusCode:
                                                                          'F',
                                                                      textTitle:
                                                                          'main_attachments_cant_complete'
                                                                              .tr,
                                                                      textDetails:
                                                                          'main_attachments_cant_upload_files'.tr +
                                                                              '!');
                                                                }
                                                              }),
                                                      ((allowCamera ||
                                                                  allowGallery) &&
                                                              allowFiles)
                                                          ? Divider(
                                                              color:
                                                                  myMidGreyColor,
                                                              height: 2.0,
                                                            )
                                                          : Container(),
                                                      !allowFiles
                                                          ? Container()
                                                          : uploadSheetLine(
                                                              icon:
                                                                  FontAwesomeIcons
                                                                      .file,
                                                              label:
                                                                  "main_attachments_file"
                                                                      .tr,
                                                              onTap: () async {
                                                                Future<bool>
                                                                    checkPermissions() async {
                                                                  return true;
                                                                }

                                                                bool
                                                                    permissionGiven =
                                                                    await checkPermissions();
                                                                try {
                                                                  if (permissionGiven) {
                                                                    if (fileExist(
                                                                            index) ==
                                                                        'empty') {
                                                                      attachmentsList[
                                                                              index]
                                                                          .fPResult = await FilePicker
                                                                              .platform
                                                                              .pickFiles(
                                                                            allowMultiple:
                                                                                false,
                                                                          ) ??
                                                                          FilePickerResult(
                                                                              []);
                                                                      sheetsetState(
                                                                          () {
                                                                        attachmentsList[index].currentlyHasFile =
                                                                            true;
                                                                      });
                                                                      Get.back();
                                                                      if (fileExist(
                                                                              index) ==
                                                                          'empty') {
                                                                        sheetsetState(
                                                                            () {
                                                                          attachmentsList[index].currentlyHasFile =
                                                                              false;
                                                                        });
                                                                      } else {
                                                                        sheetsetState(
                                                                            () {
                                                                          attachmentsList[index].currentlyHasFile =
                                                                              true;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      return myDialog(
                                                                        statusCode:
                                                                            "F",
                                                                        context:
                                                                            context,
                                                                        textTitle:
                                                                            'main_attachments_error'.tr,
                                                                        textDetails:
                                                                            'main_attachments_full'.tr,
                                                                      );
                                                                    }
                                                                  } else {
                                                                    myDialog(
                                                                        context:
                                                                            context,
                                                                        statusCode:
                                                                            'F',
                                                                        textTitle:
                                                                            'main_attachments_cant_complete'
                                                                                .tr,
                                                                        textDetails:
                                                                            'main_cant_upload_files'.tr);
                                                                  }
                                                                } catch (e) {
                                                                  myDialog(
                                                                      context:
                                                                          context,
                                                                      statusCode:
                                                                          'F',
                                                                      textTitle:
                                                                          'main_attachments_cant_complete'
                                                                              .tr,
                                                                      textDetails:
                                                                          'main_attachments_cant_upload_files'.tr +
                                                                              '!');
                                                                }
                                                              }),
                                                    ]);
                                              },
                                            ),
                                          ),
                                        ),
                                  attachmentsList[index].currentlyHasFile
                                      ? Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            InkWell(
                                              child: Container(
                                                height: 52,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: myMainColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: fileExist(index) ==
                                                        'file'
                                                    ? Icon(
                                                        FontAwesomeIcons.file,
                                                        size: 40,
                                                        color: myMainColor,
                                                      )
                                                    : fileExist(index) ==
                                                                'image' &&
                                                            (attachmentsList[
                                                                        index]
                                                                    .imagePicker!
                                                                    .path
                                                                    .endsWith(
                                                                        '.mp4') ||
                                                                attachmentsList[
                                                                        index]
                                                                    .imagePicker!
                                                                    .path
                                                                    .endsWith(
                                                                        '.MOV'))
                                                        ? Icon(
                                                            FontAwesomeIcons
                                                                .video,
                                                            size: 40,
                                                            color: myMainColor,
                                                          )
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              File(attachmentsList[
                                                                      index]
                                                                  .imagePicker!
                                                                  .path),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                              ),
                                              onTap: () {
                                                if (fileExist(index) ==
                                                    'file') {
                                                  OpenFile.open(
                                                      attachmentsList[index]
                                                          .fPResult
                                                          .files[0]
                                                          .path);
                                                } else if (fileExist(index) ==
                                                    'image') {
                                                  OpenFile.open(
                                                      attachmentsList[index]
                                                          .imagePicker!
                                                          .path);
                                                } else {
                                                  myDialog(
                                                      statusCode: 'F',
                                                      context: context,
                                                      textTitle:
                                                          "main_attachments_error"
                                                              .tr,
                                                      textDetails:
                                                          'main_attachments_show'
                                                              .tr);
                                                }
                                              },
                                            ),
                                            attachmentsList[index]
                                                    .currentlyHasFile
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4.0,
                                                        vertical: 2.0),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      decoration: BoxDecoration(
                                                          color: myWhiteColor,
                                                          shape:
                                                              BoxShape.circle),
                                                      child: myButton(
                                                        buttonType: 'image',
                                                        imageSource: 'icon',
                                                        imagePath:
                                                            FontAwesomeIcons
                                                                .trash,
                                                        imageColor:
                                                            myFailedColor,
                                                        imageHeight: 18,
                                                        imageWidth: 18,
                                                        onpressed: () {
                                                          if (fileExist(
                                                                  index) ==
                                                              'file')
                                                            myDialog(
                                                                statusCode: 'F',
                                                                context:
                                                                    context,
                                                                textTitle:
                                                                    'main_attachments_sure'
                                                                        .tr,
                                                                textDetails:
                                                                    'main_attachments_delete'
                                                                        .tr,
                                                                cancelText:
                                                                    'global_back'
                                                                        .tr,
                                                                confirmText:
                                                                    'main_delete_att'
                                                                        .tr,
                                                                confirmAction:
                                                                    () {
                                                                  attachmentsList[
                                                                          index]
                                                                      .fPResult
                                                                      .files
                                                                      .clear();
                                                                  sheetsetState(
                                                                      () {
                                                                    attachmentsList[
                                                                            index]
                                                                        .currentlyHasFile = false;
                                                                  });
                                                                });
                                                          else if (fileExist(
                                                                  index) ==
                                                              'image')
                                                            myDialog(
                                                                statusCode: 'F',
                                                                context:
                                                                    context,
                                                                textTitle:
                                                                    'main_attachments_sure'
                                                                        .tr,
                                                                textDetails:
                                                                    'main_attachments_delete'
                                                                        .tr,
                                                                cancelText:
                                                                    'global_back'
                                                                        .tr,
                                                                confirmText:
                                                                    'main_delete_att'
                                                                        .tr,
                                                                confirmAction:
                                                                    () {
                                                                  attachmentsList[
                                                                          index]
                                                                      .imagePicker = null;
                                                                  sheetsetState(
                                                                      () {
                                                                    attachmentsList[
                                                                            index]
                                                                        .currentlyHasFile = false;
                                                                  });
                                                                });
                                                          else {
                                                            myDialog(
                                                                statusCode: 'F',
                                                                context:
                                                                    context,
                                                                textTitle:
                                                                    'main_attachments_error'
                                                                        .tr,
                                                                textDetails:
                                                                    'main_attachments_remove'
                                                                        .tr);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        )
                                      : Container(),
                                  Container(),
                                ],
                              ),
                            ],
                          ));
              }),
          blockBottomLabel == null
              ? Container()
              : Column(children: [
                  SizedBox(
                    height: 6,
                  ),
                  myLable(text: blockBottomLabel, textSize: 13),
                ]),
        ],
      );
    }),
  );
}

myAttachmentsView(
    {required BuildContext context, required List attachmentsListJSON}) {
  // attachmentsListJSON should be sent exactly like that
  // [
  //   {
  //       "attchid": 210, // ATT_FILE_ID
  //       "attchname": "Upload Photo(s) / Videos *", // ATT_FILE_NAME
  //       "filepath": "iVBORw0KGgoAAAANSUhEUgAAAF4A",
  //       "extension": "image/png"
  //   }
  // ]

  return Container(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: myWidgetLineCount(context),
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: attachmentsListJSON.length,
        itemBuilder: (BuildContext context, int indx) {
          Map<String, dynamic> attch = attachmentsListJSON[indx];
          return Container(
            height: 100,
            width: 100,
            padding: EdgeInsets.all(2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Container(
                color: myMainColor.withOpacity(0.1),
                child: InkWell(
                  child: (attch['extension'] == 'application/pdf')
                      ? myImage(
                          width: 40,
                          height: 40,
                          imageSource: 'icon',
                          color: myMainColor,
                          imagePath: FontAwesomeIcons.file)
                      : (attch['extension'] == 'image/mp4' ||
                              attch['extension'] == 'image/MOV')
                          ? myImage(
                              width: 40,
                              height: 40,
                              imageSource: 'icon',
                              color: myMainColor,
                              imagePath: FontAwesomeIcons.video)
                          : myImage(
                              width: 100,
                              height: 100,
                              imageSource: 'url',
                              imagePath: myCloudImagesLink +
                                  attch['filepath'].toString()),
                  onTap: () async {
                    {
                      try {
                        String mimeTypeToExtension(String mimeType) {
                          switch (mimeType) {
                            case 'image/png':
                              return '.png';
                            case 'image/jpeg':
                              return '.jpg';
                            case 'image/jpg':
                              return '.jpg';
                            case 'application/pdf':
                              return '.pdf';
                            case 'image/mp4':
                              return '.mp4';
                            case 'image/MOV':
                              return '.MOV';
                            default:
                              return '.dat'; // Default to a generic extension
                          }
                        }

                        String tempFileExtension =
                            mimeTypeToExtension(attch['extension'].toString());

                        // Directory tempDir = await getTemporaryDirectory();
                        // String tempFilePath = '${tempDir.path}/' +
                        //     getRandomValue(length: 12, addMilSec: true) +
                        //     tempFileExtension;

                        // File tempFile = await File(tempFilePath)
                        //     .writeAsBytes(base64Decode(attch['filepath']));
                        tempFileExtension == '.mp4' ||
                                tempFileExtension == '.MOV'
                            ? Get.to(AppWebView(
                                pageURL: myCloudImagesLink +
                                    attch['filepath'].toString()))
                            : showDialog(
                                useSafeArea: false,
                                context: context,
                                builder: (BuildContext context) => Scaffold(
                                      extendBodyBehindAppBar: true,
                                      appBar: AppBar(
                                        iconTheme: const IconThemeData(
                                            color: Colors.white),
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      backgroundColor:
                                          myWhiteColor.withOpacity(0.5),
                                      body: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: PhotoViewGallery.builder(
                                            scrollPhysics:
                                                const BouncingScrollPhysics(),
                                            builder: (BuildContext context,
                                                int index) {
                                              return PhotoViewGalleryPageOptions(
                                                imageProvider: NetworkImage(
                                                    myCloudImagesLink +
                                                        attch['filepath']
                                                            .toString()),
                                                minScale: PhotoViewComputedScale
                                                        .contained *
                                                    1,
                                                maxScale: PhotoViewComputedScale
                                                        .covered *
                                                    1,
                                                initialScale:
                                                    PhotoViewComputedScale
                                                        .contained,
                                                heroAttributes:
                                                    PhotoViewHeroAttributes(
                                                        tag: myCloudImagesLink +
                                                            attch['filepath']
                                                                .toString()),
                                              );
                                            },
                                            itemCount: 1,
                                            loadingBuilder: (context, event) =>
                                                Center(
                                              child: Container(
                                                width: 20.0,
                                                height: 20.0,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            // backgroundDecoration: widget.backgroundDecoration,
                                            // pageController: widget.pageController,
                                            // onPageChanged: onPageChanged,
                                          )),
                                    ));
                        OpenFile.open(
                          myCloudImagesLink + attch['filepath'].toString(),
                        );
                      } catch (e) {
                        myDialog(
                            statusCode: 'F',
                            context: context,
                            textTitle: "main_attachments_error".tr,
                            textDetails: 'main_attachments_show'.tr);
                      }
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget myTable(
    {required List data,
    Color? headerBackgroundColor,
    Color? OddBackgroundColor,
    Color? EvenBackgroundColor,
    flexList,
    double tableRaduis = 10.0,
    Color tableBorderColor = myBlackColor,
    double tableBorderWidth = 1.0,
    bool hasBorderInData = true,
    bool hasHeader = true}) {
  if (flexList != null) {
    if (data[0].length != flexList.length) {
      myLogError(
          'Flex Error (widgets length = ${data[0].length}) (flex length = ${flexList.length})');
      return myLable(text: '');
    }
  }

  if (!hasHeader) {
    headerBackgroundColor = EvenBackgroundColor ?? myMainColor.withOpacity(0.2);
  }

  Map<int, TableColumnWidth>? flexMap = {};
  if (flexList == null) {
    for (int i = 0; i < data[0].length; i++) {
      flexMap.addAll({i: FlexColumnWidth(1.0)});
    }
  } else {
    for (int i = 0; i < flexList.length; i++) {
      flexMap.addAll({i: FlexColumnWidth(flexList[i].toDouble())});
    }
  }

  return Container(
    child: Table(
        border: TableBorder.all(
            borderRadius: BorderRadius.circular(tableRaduis),
            width: tableBorderWidth,
            color: tableBorderColor,
            style: hasBorderInData ? BorderStyle.solid : BorderStyle.none),
        columnWidths: flexMap,
        children: [
          for (int i = 0; i < data.length; i++)
            TableRow(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(i == 0 ? tableRaduis : 0.0),
                      topRight: Radius.circular(i == 0 ? tableRaduis : 0.0),
                      bottomLeft: Radius.circular(
                          i == data.length - 1 ? tableRaduis : 0.0),
                      bottomRight: Radius.circular(
                          i == data.length - 1 ? tableRaduis : 0.0)),
                  color: i == 0
                      ? headerBackgroundColor ?? myMainColor.withOpacity(0.7)
                      : i.isOdd
                          ? OddBackgroundColor ?? myWhiteColor
                          : EvenBackgroundColor ?? myMainColor.withOpacity(0.2),
                ),
                children: [
                  for (int j = 0; j < data[i].length; j++)
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: data[i][j],
                      ),
                    )
                ])
        ]),
  );
}

Widget myShimmerLoading(
    {required int linesCount,
    required int columsCount,
    required double height,
    required double width,
    required double horizontalPadding,
    required double verticalPadding,
    required double Radius,
    bool isCercile = false,
    bool isCenter = false}) {
  Widget shimmerContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Shimmer.fromColors(
        baseColor: myMainColor.withOpacity(0.3),
        highlightColor: myWhiteColor,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            shape: isCercile ? BoxShape.circle : BoxShape.rectangle,
            color: myMidGreyColor,
            borderRadius: isCercile ? null : BorderRadius.circular(Radius),
          ),
        ),
      ),
    );
  }

  return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: linesCount,
      itemBuilder: (context, index) {
        return Container(
          height: height,
          child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: columsCount,
              itemBuilder: (context, index) {
                return isCenter
                    ? Center(
                        child: shimmerContainer(),
                      )
                    : shimmerContainer();
              }),
        );
      });
}

Widget mySpin({
  double spinHeight = 30,
  double iconSize = 15,
  double textSize = 12,
  onSubmit,
  double initValue = 0,
  double minNumber = 0,
  double maxNumber = 1000,
  Color? textColor,
}) {
  textColor ??= myMainColor;
  return SizedBox(
    height: spinHeight,
    child: SpinBox(
      onChanged: onSubmit,
      value: initValue,
      iconSize: iconSize,
      cursorColor: textColor,
      iconColor: MaterialStatePropertyAll(textColor),
      textStyle: TextStyle(fontSize: textSize, color: textColor),
      decoration: InputDecoration(
        fillColor: mySubTowColor,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
      // onSubmitted: onSubmit,
      min: minNumber,
      max: maxNumber,
    ),
  );
}

Widget myDevider({Color? divColor, double height = 0, double thickness = 1}) {
  divColor ??= myMainColor;
  return Divider(
    color: divColor,
    thickness: thickness,
    height: height,
  );
}

Widget myStepper(
    {required BuildContext context,
    required int value,
    required void Function(int) onChange,
    double size = 28,
    Color unSelectedBackgroundColor = myWhiteColor,
    Color? unSelectedItemsColor,
    Color selectedBackgroundColor = myWhiteColor,
    Color? selectedItemsColor,
    double radius = 20,
    double elevation = 2.0,
    bool isUnSelectedExpanded = false,
    double numberFieldSize = 3.0,
    int oneStepCount = 1}) {
  unSelectedItemsColor ??= myMainColor;
  selectedItemsColor ??= myMainColor;
  return CartStepperInt(
      value: value,
      size: size,
      alwaysExpanded: isUnSelectedExpanded,
      numberSize: numberFieldSize,
      elevation: elevation,
      stepper: oneStepCount,
      style: CartStepperTheme.of(context).copyWith(
        backgroundColor: unSelectedBackgroundColor,
        foregroundColor: unSelectedItemsColor,
        activeBackgroundColor: selectedBackgroundColor,
        activeForegroundColor: selectedItemsColor,
        radius: Radius.circular(radius),
        iconMinus: value == 1 ? FontAwesomeIcons.trash : Icons.remove,
        iconPlus: Icons.add,
      ),
      didChangeCount: onChange);
}
