import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class ConfiaShopView extends StatefulWidget {
  @override
  _ConfiaShopViewState createState() => _ConfiaShopViewState();
}

class _ConfiaShopViewState extends State<ConfiaShopView> {
  final flutterWebViewPlugin = FlutterWebviewPlugin(); 
  final defaultUrl = 'https://confia-dev.supernova-desarrollo.com/?page=mobile';//"https://confia-qa.supernova-desarrollo.com/?page=mobile";
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription _onDestroy;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  
  @override
  void initState() {
    flutterWebViewPlugin.close();

    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged = flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged webState){
      print("***Change State:");
      print(webState);
    });

    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print("***Change Url:");
        print("Current URL: $url");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onUrlChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ConfiaShop", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        leading: new IconButton(icon: Icon(Icons.close), onPressed: (){
          flutterWebViewPlugin.close();
          //print("destroy");
          Navigator.of(context).pop();
        }),
        actions: <Widget>[
          //IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: (){ flutterWebViewPlugin != null  ? flutterWebViewPlugin.goBack() : null;}),
          //IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: (){ flutterWebViewPlugin != null ? flutterWebViewPlugin.goForward() : null;}),
          IconButton(icon: const Icon(Icons.replay), onPressed: () async { flutterWebViewPlugin != null? flutterWebViewPlugin.reload() : null;})
        ],
      ),
      body:
        WebviewScaffold(
          url: defaultUrl,
          withZoom: true,
          withLocalStorage: true,
          withJavascript: true,
          hidden: true,
          initialChild: Container(
            color: Colors.white,
            child:  Center(
              child: Image.asset("images/confiaShop.png"),
            ),
          ),
        )
    );
  }
}