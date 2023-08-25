import 'package:api/api.dart' hide Location;
import 'package:common/constant/constant.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/auth.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferences pref = await SharedPreferences.getInstance();
  await Location.instance.requestPermission();
  runApp(ProviderScope(
    overrides: [sharedPrefProvider.overrideWithValue(pref)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(mainController);
    initializeDateFormatting('id_ID');
    return AnimatedBuilder(
      animation: res,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dairyfood',
        theme: theme,
        themeMode: res.themeMode,
        darkTheme: themeDark,
        onGenerateRoute: Routes.onGenerateRoute,
        // home: PageBusinessDetail(arg: ArgBusinessDetail()),
        home: StreamBuilder<User?>(
          builder: (context, snapshot) {
            snapshot.data?.getIdTokenResult().then((value) => logger.info(value)).catchError((e) => (e));
            if (snapshot.data != null) return const PageHome();
            if (snapshot.data == null) return PageAuth();
            return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
          },
          stream: FirebaseAuth.instance.idTokenChanges(),
        ),
      ),
    );
  }
}
