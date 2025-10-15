import '../global/globalWidgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../global/globalConfig.dart';
import 'dart:convert';
import 'dart:developer';

late bool _getRespLoading;
late TextEditingController _URLTE;
late TextEditingController InputTextTE;
late TextEditingController _detailsTE;
late String response;

class getSamplePage extends StatefulWidget {
  @override
  State<getSamplePage> createState() => _getSamplePageState();
}

class _getSamplePageState extends State<getSamplePage> {
  Future initCalls() async {
    //_paymentsMap = await getUserPayments();
    // _catsMap = await getListDetails(Type: 'cats');

    // setState(() {
    //   _getRespLoading = false;
    // });
    String getInputURL = await getLocalData('getInputURL');
    _URLTE.text = getInputURL == '' ? myLink + 'getData/31' : getInputURL;
  }

  Future<String> getAPIData(
      {required String url, required String inputText}) async {
    try {
      await setLocalData('getInputURL', url);
      final resp = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json', 'inputText': inputText},
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));
      log(result.toString());
      return result.toString();
    } catch (e) {
      setState(() {
        _getRespLoading = false;
      });
      return 'Error: ' + e.toString();
    }
  }

  @override
  void initState() {
    _getRespLoading = false;
    _URLTE = TextEditingController();
    myLog(_URLTE.text);
    _URLTE.text = '';

    InputTextTE = TextEditingController();
    _detailsTE = TextEditingController();
    response = '';

    initCalls().then((value) {});
    super.initState();
  }

  Widget myPage() {
    return Column(
      children: [
        myTextField(label: 'API URL', textController: _URLTE, linesNo: 3),
        SizedBox(
          height: 5,
        ),
        myTextField(
          label: 'Input Text',
          textController: InputTextTE,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: myButton(
            buttonType: 'simple',
            buttonColor: myInfoColor,
            text: 'Get',
            onpressed: () async {
              if (_URLTE.text.isEmpty) {
                myToast(
                    duartion: 5,
                    context: context,
                    text: 'Please enter API URL',
                    statusCode: 'F');
                return;
              }
              if (InputTextTE.text.isEmpty) {
                myToast(
                    duartion: 5,
                    context: context,
                    text: 'Please enter Input Text',
                    statusCode: 'F');
                return;
              }

              setState(() {
                _getRespLoading = true;
              });

              response = await getAPIData(
                  url: _URLTE.text, inputText: InputTextTE.text);
              setState(() {
                _getRespLoading = false;
                _detailsTE.text = response;
              });
            },
            elevation: 0,
          ),
        ),
        _getRespLoading
            ? myLoading()
            : myTextField(
                label: 'API Response',
                textController: _detailsTE,
                linesNo: 10,
              ),
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
