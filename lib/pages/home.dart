import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/components/custom_drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({this.onSingIn});
  final VoidCallback onSingIn;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sistema Gestión de Cartera"),
        centerTitle: true,
      ),
      drawer: CustomDrawer(authFirebase: AuthFirebase(),onSingIn: widget.onSingIn),
    );
  }
}