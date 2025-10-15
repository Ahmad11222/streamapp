import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:convert' show base64Decode, json, jsonEncode, utf8;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../global/globalConfig.dart';
import '../global/globalWidgets.dart';

Future<List<dynamic>> myAPIgetCountriesList(
    {String trnsid = '', String id = '', String isocode = ''}) async {
  try {
    var resp = await http.get(
        Uri.parse(
            'https://csp-m.mofa.gov.kw/csp/mofa/fid/api/' + "getcountries"),
        headers: {
          "Accept": "application/json",
          'trnsid': trnsid,
          'isocode': isocode,
          'id': id,
          'lang': getCurrentLocaleString()
        });

    var result = json.decode(utf8.decode(resp.bodyBytes));

    return result['items'];
  } catch (e) {
    return [];
  }
}

Widget myCountriesWidget(
    {required TextEditingController? textController,
    required String label,
    required String imageText,
    String isocod = '',
    tapfunction,
    bordercolor = myDarkGreyColor,
    num widthbtween = 10.0,
    bool readonly = false,
    // int flex = 4,
    bool canBeEmpty = true}) {
  return InkWell(
    child: IgnorePointer(
      child: myLine(
        widgetsList: [
          myIcon(iconSource: 'url', iconText: imageText, iconCat: 'flg'),
          myTextField(
              label: label,
              textController: textController,
              canBeEmpty: canBeEmpty,
              borderColor: bordercolor),
        ],
        flexList: [
          -50,
          1,
        ],
      ),
    ),
    onTap: readonly
        ? null
        : () {
            tapfunction();
          },
  );
}

myCountriesSheet(BuildContext context,
    {String trnsid = '',
    tapfunction,
    bool showCallCode = true,
    countryid = ''}) {
  int _fetchCount = 15;
  int _increaseBy = 15;
  getCountriesSheet(BuildContext context) {
    myAPIgetCountriesList(trnsid: trnsid, id: countryid).then((apiCountries) {
      List<dynamic> countriesList = apiCountries;
      Get.back();
      List<dynamic> _foundCountries = countriesList;

      return mySheet(context: context, widgetsList: [
        StatefulBuilder(builder: (context, sheetsetState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    List<dynamic> results = [];
                    if (value.isEmpty) {
                      results = countriesList;
                    } else {
                      results = countriesList.where((country) {
                        return (country["namear"] ?? '')
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            (country["nameen"] ?? '')
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            (country["callcode"] ?? '')
                                .toLowerCase()
                                .contains(value.toLowerCase());
                      }).toList();
                    }
                    sheetsetState(() {
                      _foundCountries = results;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "globalsheet_search".tr,
                      suffixIcon: Icon(Icons.search)),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _foundCountries.isNotEmpty
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _foundCountries.length > _fetchCount
                              ? _fetchCount + 1
                              : _foundCountries.length,
                          itemBuilder: (context, index) => index < _fetchCount
                              ? Card(
                                  key: ValueKey(_foundCountries[index]["id"]),
                                  color: myLightGreyColor,
                                  child: InkWell(
                                    child: Container(
                                      height: 56,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        child:
                                            myLine(isStart: true, widgetsList: [
                                          myLine(
                                            isStart: true,
                                            widgetsList: [
                                              Container(
                                                child: myIcon(
                                                    iconSource: 'url',
                                                    iconText:
                                                        _foundCountries[index]
                                                                ["icon"] ??
                                                            '',
                                                    iconCat: 'flg'),
                                              ),
                                              Container(),
                                              myLable(
                                                  maxline: 3,
                                                  textSize: 16,
                                                  text: _foundCountries[index]
                                                          ['name'] ??
                                                      ''),
                                            ],
                                            flexList: [-50, -8, 1],
                                          ),
                                          myLable(
                                            isEnd: true,
                                            textSize: 16,
                                            maxline: 1,
                                            text: _foundCountries[index]
                                                    ["callcode"] ??
                                                '',
                                          ),
                                          Container()
                                        ], flexList: [
                                          1,
                                          showCallCode ? -30 : 0,
                                          showCallCode ? -5 : 0,
                                        ]),
                                      ),
                                    ),
                                    onTap: () {
                                      tapfunction(
                                        (_foundCountries[index]["id"] ?? '')
                                            .toString(),
                                        (_foundCountries[index]["callcode"] ??
                                                '')
                                            .toString(),
                                        (_foundCountries[index]["name"] ?? '')
                                            .toString(),
                                        (_foundCountries[index]["icon"] ?? '')
                                            .toString(),
                                        (_foundCountries[index]["isalt"] ?? '')
                                            .toString(),
                                      );

                                      Get.back();
                                    },
                                  ),
                                )
                              : myButton(
                                  buttonType: 'simple',
                                  text: "globalsheet_loadmore".tr,
                                  onpressed: () {
                                    sheetsetState(() {
                                      _fetchCount += _increaseBy;
                                    });
                                  }))
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "globalsheet_nocountry".tr,
                            style: TextStyle(fontSize: 20),
                          ),
                        ))
            ],
          );
        })
      ]);
    });
  }

  return myLoadingSheet(context, getCountriesSheet(context));
}

myDateSheet(
    {required BuildContext context,
    onsubmit,
    controller,
    isrange = true,
    onSelectionChanged,
    selectabledayPredicate}) {
  return Get.dialog(
    AlertDialog(
      title: Text("Select Date Range"),
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite, // Make sure the content takes full width
          height: MediaQuery.of(context).size.height * 0.5,
          child: SfDateRangePicker(
            onSelectionChanged: onSelectionChanged,
            selectionMode: isrange
                ? DateRangePickerSelectionMode.range
                : DateRangePickerSelectionMode.single,
            enablePastDates: false,
            endRangeSelectionColor: myFailedColor,
            showActionButtons: false,
            showTodayButton: false,
            showNavigationArrow: true,
            toggleDaySelection: true,
            onCancel: () {
              Get.back();
            },
            onSubmit: onsubmit,
            controller: controller,
            selectableDayPredicate: selectabledayPredicate,
            todayHighlightColor: myFailedColor,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onsubmit(controller.selectedDate);
          },
          child: Text('Submit'),
        ),
      ],
    ),
  );
}

myTimeSheet({
  required BuildContext context,
  required List data,
  onsubmit,
  controller,
  isrange = true,
  onSelectionChanged,
  selectabledayPredicate,
}) {
  return Get.dialog(
    AlertDialog(
      content: SingleChildScrollView(
        child: Container(
            width: double.maxFinite, // Make sure the content takes full width
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: [
                myLable(text: 'Select A TIME'),
                SizedBox(
                  height: 20,
                ),
                myLine(widgetsList: [
                  myLine(widgetsList: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          border: Border.all(color: myMainColor),
                          color: mySubTowColor),
                    ),
                    Container(),
                    myLable(text: 'Unavailable', textSize: 10)
                  ], flexList: [
                    1,
                    -10,
                    1
                  ]),
                  myLine(widgetsList: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          border: Border.all(color: myMainColor),
                          color: myWhiteColor),
                    ),
                    Container(),
                    myLable(text: 'Available', textSize: 10)
                  ], flexList: [
                    1,
                    -10,
                    1
                  ])
                ], flexList: [
                  1,
                  1
                ]),
                SizedBox(
                  height: 15,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: data[index].isSelected
                                    ? mySubTowColor
                                    : myWhiteColor,
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                myLable(text: data[index].text, textSize: 10),
                          ),
                        ),
                        onTap: onSelectionChanged,
                      );
                    }),
              ],
            )),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onsubmit(controller.selectedDate);
          },
          child: Text('Submit'),
        ),
      ],
    ),
  );
}

myReqServiceInfoSheet(
  BuildContext context, {
  required String reqID,
  required String reqdtlID,
}) {
  Future<Map<String, dynamic>> getInfoAPI() async {
    try {
      String _savedToken = await getLocalData('token');
      String _savedUsername = await getLocalData('username');
      var resp = await http
          .get(Uri.parse(myIntegrationAPILink + "getReqServiceInfo"), headers: {
        "Accept": "application/json",
        'authtoken': _savedToken,
        'username': _savedUsername,
        'reqid': reqID,
        'reqdtlid': reqdtlID,
        'plang': getCurrentLocaleString()
      });
      var result = json.decode(utf8.decode(resp.bodyBytes));
      log(result.toString());
      return result;
    } catch (e) {
      return {};
    }
  }

  getInfoSheet(BuildContext context) {
    getInfoAPI().then((infoAPI) {
      Get.back();

      return mySheet(context: context, widgetsList: [
        StatefulBuilder(builder: (context, sheetsetState) {
          return Column(
            children: [
              infoAPI['info'].length == 0
                  ? Container()
                  : ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: infoAPI['info'].length,
                      separatorBuilder: (context, index) => Container(),
                      itemBuilder: (BuildContext context, int indx) {
                        return myLine(isStart: true, widgetsList: [
                          myLable(
                              isbold: true,
                              text: infoAPI['info'][indx]['label'].toString() +
                                  ': '),
                          Container(),
                          myLable(
                            text: infoAPI['info'][indx]['value'].toString(),
                          ),
                        ], flexList: [
                          (myDeviceSize(context, 'w') * -0.45).floor(),
                          -7,
                          1
                        ]);
                      }),
              infoAPI['info'].length == 0 || infoAPI['attachments'].length == 0
                  ? Container()
                  : myDevider(height: 20),
              infoAPI['attachments'].length == 0
                  ? Container()
                  : myAttachmentsView(
                      context: context,
                      attachmentsListJSON: infoAPI['attachments']),
            ],
          );
        })
      ]);
    });
  }

  return myLoadingSheet(context, getInfoSheet(context));
}
