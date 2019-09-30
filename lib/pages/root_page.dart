import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/home.dart';

import 'login.dart';

class RootPage extends StatefulWidget {
  RootPage({this.authFirebase});
  final AuthFirebase authFirebase;
  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus{
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  @override
  void initState() {
    // TODO: implement initState
    widget.authFirebase.currrentUser().then((userId){
      setState(() {
       authStatus = userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn; 
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    switch(authStatus){
      case AuthStatus.notSignedIn:
        return Login(auth: widget.authFirebase, onSingIn: ()=>updateAuthSign(AuthStatus.signedIn),);
      case AuthStatus.signedIn:
        return HomePage(onSingIn: ()=>updateAuthSignOut(AuthStatus.notSignedIn));
    }
  }

  void updateAuthSign(AuthStatus aut){
    setState(() {
     authStatus = aut; 
    });
  }

  void updateAuthSignOut(AuthStatus aut){
    setState(() {
     authStatus = aut; 
    });
  }
}