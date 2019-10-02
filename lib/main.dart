import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sgcartera_app/pages/root_page.dart';

import 'classes/auth_firebase.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
          const Locale('es'), // Hebrew
          const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
          // ... other locales the app supports
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(authFirebase: new AuthFirebase()),
    );
  }
}


