import 'package:firebase_auth/firebase_auth.dart';
import 'package:sgcartera_app/Models/auth_res.dart';

class AuthFirebase{
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<AuthRes> signIn(String email, String pass)async{
    AuthRes authRes = new AuthRes();
    try{
      AuthResult authResult = await firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
      authRes = AuthRes(email: authResult.user.email, result: true, uid: authResult.user.uid, mensaje: "Session iniciada con exito");
    }catch(e){
      authRes = AuthRes(email: null, result: false, uid: null, mensaje: e.toString());
    }
    return authRes;
  }
  
  Future<String> currrentUser() async{
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    return firebaseUser != null ? firebaseUser.uid : null;
  }

  Future<void> signOut() async{
    return firebaseAuth.signOut();
  }
}