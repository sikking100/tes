import 'dart:developer';

import 'package:common/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/auth/auth_page.dart';
import 'package:sales/presentation/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  await Firebase.initializeApp();
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  final AppPages _appPages = AppPages();
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      title: 'Dairyfood Sales',
      theme: theme,
      onGenerateRoute: _appPages.onGenerateRoutes,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [Locale('id', 'ID')],
      builder: (context, child) {
        return Builder(
          builder: (context) => ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: child!,
          ),
        );
      },
      home: StreamBuilder<User?>(
        builder: (context, snapshot) {
          snapshot.data
              ?.getIdTokenResult()
              .then((value) => log(value.toString()));

          if (snapshot.data != null) {
            return const HomePage();
          }
          if (snapshot.data == null) return AuthPage();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        },
        stream: FirebaseAuth.instance.authStateChanges(),
      ),
    );
  }
}
