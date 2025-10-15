import 'package:flutter/material.dart';
import '../global/globalConfig.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../global/globalWidgets.dart';

late bool _webloading;

class AppWebView extends StatefulWidget {
  final String pageURL;
  AppWebView({required this.pageURL});
  @override
  _AppWebViewState createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late WebViewController WVCcontroller;
  @override
  void initState() {
    _webloading = true;
    WVCcontroller = WebViewController()
      ..loadRequest(Uri.parse(widget.pageURL))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(myWhiteColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted)
              setState(() {
                _webloading = false;
              });
          },
        ),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      body: Stack(
        children: [
          WebViewWidget(controller: WVCcontroller),
          _webloading
              ? Center(
                  child: myLoading(),
                )
              : Container(),
        ],
      ),
    );
  }
}
