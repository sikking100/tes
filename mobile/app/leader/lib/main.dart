import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_auth.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:leader/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: Main()));
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dairyfood Leader',
      navigatorObservers: [routeObserver],
      themeMode: ThemeMode.light,
      theme: theme.copyWith(
        colorScheme: scheme.copyWith(
          primary: const Color.fromARGB(255, 37, 37, 37),
        ),
      ),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          snapshot.data?.getIdTokenResult().then((value) => logger.info(value));
          if (snapshot.data == null) return const PageAuth();
          if (snapshot.data != null) return PageHome();
          return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
        },
      ),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
