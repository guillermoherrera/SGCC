import 'package:flutter/material.dart';
import 'package:sgcartera_app/pages/root_page.dart';

import 'classes/auth_firebase.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SGCC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(authFirebase: new AuthFirebase()),
    );
  }
}


