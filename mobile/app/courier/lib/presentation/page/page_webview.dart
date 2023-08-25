import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageWebview extends StatefulWidget {
  final String url;
  const PageWebview({Key? key, required this.url}) : super(key: key);

  @override
  State<PageWebview> createState() => _PageWebviewState();
}

class _PageWebviewState extends State<PageWebview> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pop(context), child: const Icon(Icons.arrow_back)));
  }
}
