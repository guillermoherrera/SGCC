import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:html/parser.dart';

class ConfiaShopView extends StatefulWidget {
  @override
  _ConfiaShopViewState createState() => _ConfiaShopViewState();
}

class _ConfiaShopViewState extends State<ConfiaShopView> {
  InAppWebViewController webView;
  String url = "", initialUrl = "https://www.liverpool.com.mx/";//"https://jsonplaceholder.typicode.com/";
  double progress = 0;

  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    var decoded = json.decode(parsedString);
    return parsedString;
  }

  @override
  void initState() {
    //webView.clearCache();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ConfiaShop"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () async { await webView.canGoBack() ? webView.goBack() : null;}),
          IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () async { await webView.canGoForward() ? webView.goForward() : null;}),
          IconButton(icon: const Icon(Icons.replay), onPressed: () async { progress == 1.0? webView.reload() : null;})
        ],
      ),
      body:
        Container(
          child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(0.0),
              child: progress < 1.0 ? LinearProgressIndicator(value: progress, backgroundColor: Colors.white, valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent)) : LinearProgressIndicator(value: 1, backgroundColor: Colors.blueAccent, valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent)),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(0.0),
                child: InAppWebView(
                  initialUrl: initialUrl,
                  initialHeaders: {},
                  initialOptions: InAppWebViewWidgetOptions(
                    inAppWebViewOptions: InAppWebViewOptions(
                      debuggingEnabled: true,
                    )
                  ),
                  onWebViewCreated: (InAppWebViewController controller){
                    webView = controller;
                  },
                  onLoadStart: (InAppWebViewController controller, String url){
                    setState(() {this.url = url;});
                  },
                  onLoadStop: (InAppWebViewController controller, String url) async{
                    print(url);
                    print("########################");
                    webView.clearCache();
                    String html = await controller.getHtml();
                    if(url.contains("users")) _parseHtmlString(html);
                    setState(() {this.url = url;});
                  },
                  onProgressChanged: (InAppWebViewController controller, int progress){
                    setState(() {this.progress = progress / 100;});
                  },
                ),
              ),
            )
          ],),
        )
    );
  }
}