import 'package:common/function/function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Dimens {
  static const double px6 = 6.0;
  static const double px8 = 8.0;
  static const double px10 = 10.0;
  static const double px12 = 12.0;
  static const double px14 = 14.0;
  static const double px16 = 16.0;
  static const double px18 = 18.0;
  static const double px20 = 20.0;
  static const double px22 = 22.0;
  static const double px30 = 30.0;
  static const double px44 = 44.0;
}

Map<int, Color> _colorSwatches = {
  50: const Color.fromRGBO(220, 20, 60, .1),
  100: const Color.fromRGBO(220, 20, 60, .2),
  200: const Color.fromRGBO(220, 20, 60, .3),
  300: const Color.fromRGBO(220, 20, 60, .4),
  400: const Color.fromRGBO(220, 20, 60, .5),
  500: const Color.fromRGBO(220, 20, 60, .6),
  600: const Color.fromRGBO(220, 20, 60, .7),
  700: const Color.fromRGBO(220, 20, 60, .8),
  800: const Color.fromRGBO(220, 20, 60, .9),
  900: const Color.fromRGBO(220, 20, 60, 1),
};

MaterialColor mColorSwatches = MaterialColor(0xffdc143c, _colorSwatches);

final theme = ThemeData(
  fontFamily: GoogleFonts.notoSans().fontFamily,
  primarySwatch: mColorSwatches,
  colorScheme: scheme,
  scaffoldBackgroundColor: scheme.background,
  appBarTheme: const AppBarTheme(elevation: 1, centerTitle: true, backgroundColor: Colors.white),
  tabBarTheme: TabBarTheme(
    labelColor: scheme.secondary,
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    unselectedLabelColor: scheme.onPrimary.withOpacity(0.7),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: scheme.secondary,
      foregroundColor: scheme.onSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: scheme.secondary,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: scheme.secondary,
      side: BorderSide(color: scheme.secondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: scheme.secondary,
    backgroundColor: const Color(0xffEAECEF),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: scheme.secondary,
    selectionHandleColor: scheme.secondaryContainer,
    selectionColor: const Color(0xffED365B),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    iconColor: MaterialStateColor.resolveWith((states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return mPrimaryColor;
      }
      return Colors.black38;
    }),
  ),
  timePickerTheme: TimePickerThemeData(
    dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return scheme.secondary;
      }
      return scheme.onSurface.withOpacity(0.60);
    }),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.secondary),
  chipTheme: ChipThemeData(
    // padding: EdgeInsets.all(10),
    // backgroundColor: scheme.secondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
      side: BorderSide.none,
    ),
    secondaryLabelStyle: TextStyle(color: scheme.primary),
    selectedColor: scheme.secondary,
    side: BorderSide(
      color: scheme.secondary,
    ),
    backgroundColor: Colors.transparent,
    labelStyle: TextStyle(
      color: scheme.secondary,
    ),
  ),
);

final themeDark = ThemeData(
  fontFamily: GoogleFonts.notoSans().fontFamily,
  scaffoldBackgroundColor: schemeDark.background,
  primarySwatch: mColorSwatches,
  colorScheme: schemeDark,
  bottomSheetTheme: const BottomSheetThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
  ),
  appBarTheme: AppBarTheme(
    elevation: 1,
    centerTitle: true,
    backgroundColor: Colors.grey[850],
  ),
  tabBarTheme: TabBarTheme(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: schemeDark.secondary,
      ),
    ),
    labelColor: schemeDark.secondary,
    unselectedLabelColor: schemeDark.onBackground,
  ),
  timePickerTheme: TimePickerThemeData(
    dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return scheme.secondary;
      }
      return scheme.onSurface.withOpacity(0.60);
    }),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: scheme.secondary,
    selectionHandleColor: scheme.secondaryContainer,
    selectionColor: const Color(0xffED365B),
  ),
  inputDecorationTheme: InputDecorationTheme(
    iconColor: schemeDark.secondary,
    hintStyle: const TextStyle(color: Colors.black),
    labelStyle: const TextStyle(color: Colors.black),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return schemeDark.secondary;
      }
      return null;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return schemeDark.secondary;
      }
      return null;
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return schemeDark.secondary;
      }
      return null;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return schemeDark.secondary;
      }
      return null;
    }),
  ),
);

const ColorScheme scheme = ColorScheme(
  primary: Colors.white,
  // primary: Color(0xffdc143c),
  // primaryVariant: Colors.white70,
  secondary: Color(0xffdc143c),
  secondaryContainer: Color(0xffED365B),
  surface: Colors.white,
  background: Colors.white,
  error: Colors.red,
  onPrimary: Colors.black,
  onSecondary: Colors.white,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light,
);

const ColorScheme schemeDark = ColorScheme(
  primary: Colors.white,
  // primaryVariant: Colors.white70,
  secondary: Color(0xffdc143c),
  // secondaryVariant: Color(0xffdc143c),
  background: Color(0xff121212),
  surface: Color(0xff121212),
  error: Color(0xffcf6679),
  onPrimary: Color(0xff000000),
  onSecondary: Color(0xff000000),
  onBackground: Color(0xffffffff),
  onSurface: Color(0xffffffff),
  onError: Color(0xff000000),
  brightness: Brightness.dark,
);

class COB {
  static const bakery = 'Bakery';
  static const home = 'Home Industry';
  static const catering = 'Catering';
  static const mtb = 'Supplier';
  static const restaurant = 'Restaurant';
  static const industri = 'Industri';
  static const hotel = 'Hotel';
  static const distributor = 'Distributor';
  static const cafe = 'Cafe';
  static const modern = 'Modern Trade';
  static const tokoEcer = 'Toko - Eceran';
  static const tokoGrosir = 'Toko - Grosir';
  static const rs = 'Rumah Sakit';
  static const lainnya = 'Lainnya';

  static const List<String> list = [
    bakery,
    home,
    catering,
    mtb,
    restaurant,
    industri,
    hotel,
    distributor,
    cafe,
    modern,
    tokoEcer,
    tokoGrosir,
    rs,
    lainnya,
  ];
}

final urlApp = defaultTargetPlatform == TargetPlatform.iOS
    ? 'https://apps.apple.com/id/app/dairyfood-online-service/id6443916408'
    : 'https://play.google.com/store/apps/details?id=app.dairyfood.customer';
