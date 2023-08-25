import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, required this.url, required this.title})
      : super(key: key);

  final String url;
  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    int progress = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (webViewController) {
              _webViewController = webViewController;
            },
            onProgress: (prog) {
              setState(() {
                progress = prog;
              });
            },
          ),
          progress < 100 ? Container() : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _webViewController.reload();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
