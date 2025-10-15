import '../global/globalWidgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../global/globalConfig.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';

late bool _PageLoading;
late TextEditingController _saearchIDTE;
late TextEditingController _idTE;
late TextEditingController _dateTE;
late TextEditingController _detailsTE;
late Map<String, dynamic> _getMap;

class homePage extends StatefulWidget {
  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  Future initCalls() async {
    //_paymentsMap = await getUserPayments();
    // _catsMap = await getListDetails(Type: 'cats');

    // setState(() {
    //   _PageLoading = false;
    // });
  }

  Future<Map<String, dynamic>> getAPIData() async {
    try {
      final resp = await http.get(
        Uri.parse(myLink + 'getData/${_saearchIDTE.text}'),
        headers: {'Accept': 'application/json'},
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));
      log(result.toString());
      return result;
    } catch (e) {
      setState(() {
        _PageLoading = false;
      });
      return {};
    }
  }

  Future postAPIData() async {
    // String _username = _auth.getUserName();
    // String _savedToken = await getLocalData('token');
    String jsonString = jsonEncode({
      'pid': _idTE.text,
      'pdate': _dateTE.text,
      'pdetails': _detailsTE.text
    });

    myLog(jsonString);

    try {
      var resp = await http.post(Uri.parse(myLink + 'postData'),
          headers: {
            'Accept': 'application/json',
          },
          body: jsonString);
      var result = json.decode(utf8.decode(resp.bodyBytes));

      if (result['successFlag'] == 'T') {
        myToast(
            duartion: 5,
            context: context,
            text: result['resultMessage'] ?? '',
            statusCode: 'S');
        // Some code here
      } else {
        myToast(
            duartion: 5,
            context: context,
            text: (result['resultMessage'] ?? '') +
                '\n' +
                (result['exception'] ?? ''),
            statusCode: 'F');
      }
      setState(() {
        _PageLoading = false;
      });

      return result;
    } catch (e) {
      myToast(
          duartion: 5,
          context: context,
          text: 'main_error_details'.tr,
          statusCode: 'F');
      setState(() {
        _PageLoading = false;
      });
      return {};
    }
  }

  @override
  void initState() {
    _PageLoading = false;
    _saearchIDTE = TextEditingController();
    _idTE = TextEditingController();
    _dateTE = TextEditingController();
    _detailsTE = TextEditingController();
    _getMap = {};
    initCalls().then((value) {});
    super.initState();
  }

  Widget myPage() {
    return _PageLoading
        ? myLoading()
        : Column(
            children: [
              myLine(
                widgetsList: [
                  myTextField(
                      label: 'ID',
                      textController: _saearchIDTE,
                      inputType: 'number'),
                  Padding(
                    padding: const EdgeInsets.only(top: 38.0),
                    child: myButton(
                      buttonType: 'simple',
                      text: 'Get',
                      onpressed: () async {
                        if (_saearchIDTE.text.isEmpty) {
                          myToast(
                              duartion: 5,
                              context: context,
                              text: 'Please enter an ID',
                              statusCode: 'F');
                          return;
                        }
                        setState(() {
                          _PageLoading = true;
                        });
                        _getMap = await getAPIData();
                        setState(() {
                          _PageLoading = false;
                          _idTE.text = _getMap['id']?.toString() ?? '';
                          _dateTE.text = _getMap['date']?.toString() ?? '';
                          _detailsTE.text =
                              _getMap['details']?.toString() ?? '';
                        });
                      },
                      elevation: 0,
                    ),
                  ),
                ],
                flexList: [1, 1],
              ),
              myDevider(height: 60, thickness: 4, divColor: myBlackColor),
              Column(children: [
                myTextField(
                    label: 'ID', textController: _idTE, inputType: 'number'),
                myDateTimePicker(
                  context: context,
                  textController: _dateTE,
                  label: 'Date & Time',
                  canBeEmpty: false,
                  hasBorder: false,
                  changeFunc: (DateTime? selectedDateTime) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (mounted && selectedDateTime != null) {
                      setState(() {
                        // The widget will automatically format the text controller
                        // So we don't need to manually set _dateTE.text here
                      });
                    }
                  },
                ),
                myTextField(
                  label: 'Details',
                  textController: _detailsTE,
                  linesNo: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: myButton(
                    buttonType: 'simple',
                    text: 'Post',
                    onpressed: () async {
                      setState(() {
                        _PageLoading = true;
                      });
                      await postAPIData();
                    },
                    elevation: 0,
                  ),
                ),
              ]),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(8.0), child: myPage()),
        ),
      ),
    );
  }
}
