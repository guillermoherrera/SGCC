import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/sqlite_files/database_creator.dart';

import 'classes/auth_firebase.dart';

//void main() => runApp(MyApp());

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DataBaseCreator().initDataBase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //const PrimaryColor = const Color(0xFF151026);
  final colorTema = Color(0xff76BD21);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SGCC',
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
          const Locale('en'), // English
          const Locale('es'), // Español
          const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
          // ... other locales the app supports
      ],
      theme: ThemeData(
        primaryColor: colorTema,
        //primarySwatch: colorTema,
      ),
      home: RootPage(authFirebase: new AuthFirebase(), colorTema: colorTema,),
    );
  }
}


