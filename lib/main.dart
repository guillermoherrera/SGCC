import 'package:flutter/material.dart';
import 'package:sgcartera_app/paginas/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGCC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(title: 'Sistema Gestion de Cartera'),
    );
  }
}


