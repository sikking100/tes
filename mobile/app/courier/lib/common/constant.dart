import 'package:flutter/material.dart';

const mPrimaryColor = Color(0xffdc143c);
const mTextfieldLoginColor = Color(0xffdfdfdf);
const mTextfieldLoginNumberColor = Color(0xffd4d4d4);
const mArrowIconColor = Color(0xff606060);
const mOnHoldColor = Color(0xffFF971A);
const mCallColor = Color(0xff3065AC);

const mPadding = EdgeInsets.all(15);

const mImage =
    'https://upload.wikimedia.org/wikipedia/commons/f/fb/Karen_Gillan_Stuttgart_Comic-Con_Germany_2019-_d90_by-RaBoe_123_%28cropped%29.jpg';
const mImage2 = 'https://upload.wikimedia.org/wikipedia/commons/3/33/Mark_Kassen%2C_Tony_C%C3%A1rdenas_and_Chris_Evans_%28cropped%29.jpg';

const lat = -6.138527983838412;
const lng = 106.79354299732256;

const lat1 = -6.192129405804242;
const lng1 = 106.80369221547953;

const lat2 = -6.149867462562235;
const lng2 = 106.81688431349599;

const overviewPolyline =
    'd|md@qbyjSBl@|CIzJc@lFQ~AE`@AF`AElAB`@V|CBjAZdIFzB@`@~@_@`By@hAc@zJaE`@Mj@GvBaAfPeHdCaAvDaBzBw@nBc@lAIj@AfAFdAJxBd@~HdCzHhC|DvA`FtBfFzBrAb@lC|@`HtBhFdBvDjAlA\\tBb@rAP~ANxAHnBBvBIrCYtAWhA[rAc@bAc@hBcAxB_BvBkBnBuBz@cAzEsFfIaJhBqBzBoB|B}AROlAk@\\OtA_@pA[~A[lBQnAGzDQdJG|CCzBGLILGrAEdBIVIz@D`A?dBCdGSvACpA@~CKjGEhBAjA?dE]nDWbD]hGw@~A[hDaAfDiArBq@`Ac@H_A?IQYAG]Y]o@k@_B_@}@kA{CkA}C[k@[[]Um@WeAc@q@e@y@_BS[g@UeBw@sBw@c@Oo@MmBMiHm@sCSOCAbBCtBAXc@A';

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

const ColorScheme scheme = ColorScheme(
  primary: Colors.white,
  // primaryVariant: Colors.white70,
  secondary: Color(0xffdc143c),
  // secondaryVariant: Color(0xffc10028),
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

const success = 'success';

class StatusDelivery {
  static const String pending = 'PENDING';
  static const String delivery = 'DELIVERY';
  static const String complete = 'COMPLETE';
}

class PaymentMethod {
  static const String top = 'TOP';
  static const String cod = 'COD';
  static const String tra = 'TRA';
}

String statusString(String status, [bool? isSelisih, bool? isBatal]) {
  switch (status) {
    case StatusDelivery.complete:
      if (isBatal == true) return 'Batal';
      if (isSelisih == true) return 'Selisih';
      return 'Selesai';
    case StatusDelivery.pending:
      return 'Menunggu Diambil';
    case StatusDelivery.delivery:
      return 'Diantar';
    default:
      return 'Menunggu';
  }
}

Color statusColor(String status, [bool? isSelisih, bool? isBatal]) {
  switch (status) {
    case StatusDelivery.complete:
      if (isBatal == true) return mPrimaryColor;
      if (isSelisih == true) return Colors.orange;
      return Colors.green;
    case StatusDelivery.pending:
      return mPrimaryColor;
    case StatusDelivery.delivery:
      return mPrimaryColor;
    default:
      return mPrimaryColor;
  }
}

const double lats = -5.106222761217505;
const double lngs = 119.52157572615388;
