import 'package:api/api.dart' hide Location;
import 'package:courier/common/constant.dart';
import 'package:courier/firebase_options.dart';
import 'package:courier/main_controller.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:courier/presentation/page/page_login.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:courier/provider_observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiProvider = Provider((_) => Api(FirebaseAuth.instance));
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Location.instance.requestPermission();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      observers: [
        Logger(),
      ],
      overrides: [sharedPrefProvider.overrideWithValue(sharedPreferences)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id');
    return MaterialApp(
      title: 'Dairyfood Courier',
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.secondary),
        primarySwatch: mColorSwatches,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.background,
        appBarTheme: const AppBarTheme(elevation: 1, centerTitle: true),
        tabBarTheme: TabBarTheme(labelColor: scheme.secondary, unselectedLabelColor: scheme.onPrimary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: scheme.secondary, foregroundColor: scheme.onSecondary),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: scheme.secondary,
          selectionHandleColor: scheme.secondaryContainer,
          selectionColor: const Color(0xffED365B),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: scheme.secondary,
          backgroundColor: const Color(0xffEAECEF),
        ),
      ),
      themeMode: ThemeMode.light,

      // darkTheme: ThemeData.from(colorScheme: schemeDark),
      // darkTheme: ThemeData(
      //   scaffoldBackgroundColor: schemeDark.background,
      //   primarySwatch: mColorSwatches,
      //   colorScheme: schemeDark,
      //   appBarTheme: AppBarTheme(
      //     elevation: 1,
      //     centerTitle: true,
      //     backgroundColor: Colors.grey[850],
      //   ),
      //   tabBarTheme: TabBarTheme(
      //     indicator: UnderlineTabIndicator(
      //       borderSide: BorderSide(
      //         color: schemeDark.secondary,
      //       ),
      //     ),
      //     labelColor: schemeDark.secondary,
      //     unselectedLabelColor: schemeDark.onBackground,
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       foregroundColor: schemeDark.secondary,
      //       textStyle: const TextStyle(color: Colors.white),
      //     ),
      //   ),
      //   toggleableActiveColor: schemeDark.secondary,
      // ),
      onGenerateRoute: Routes.onGenerateRoute,
      // home: PageHome(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, s) {
          s.data?.getIdTokenResult().then((value) => logger.info(value));
          if (s.data == null) {
            return PageAuth();
          }

          if (s.data != null) {
            return PageHome();
          }

          return const Scaffold(
              body: Center(
            child: CircularProgressIndicator.adaptive(),
          ));
        },
      ),
    );
  }
}
