import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/sqlite_files/database_creator.dart';

import 'classes/auth_firebase.dart';

//void main() => runApp(MyApp());

void main() async{
  await DataBaseCreator().initDataBase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final colorTema = Colors.green;
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
        primarySwatch: colorTema,
      ),
      home: RootPage(authFirebase: new AuthFirebase(), colorTema: colorTema,),
    );
  }
}


