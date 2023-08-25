import 'dart:convert';

import 'package:api/common.dart';
import 'package:api/maps/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

const Place tPlace = Place('ChIJD7fiBh9u5kcRYJSMaMOCCwQ', 'Paris, France');
const PlaceDetail tPlaceDetail = PlaceDetail('48 Pirrama Rd, Pyrmont NSW 2009, Australia', -33.866489, 151.1958561);
final Direction tDirection = Direction(
  overviewPolyline:
      'z}md@w_yjS}H^mGPqI`@iDTcFTW?NTJLJREfCOzC_AbI{@nHGlAo@|Gh@\\f@Ld@@v@EpG{@lLcBXEh@U|BmAbFoCHG@PFpAjAtCl@tBADUf@u@`AGXCv@NhDBhATtGXnH^zGPlED`AFh@LXJjAFx@F~ADv@Cb@IrA~@P`@DlA?dCAn@@|@RbATf@PLFG^Uz@@bAH~ALvC?r@c@nEWhCC|@UbCUnD[dCQ~@w@zCaA~Dy@`Du@fDw@tCaA|DaAvEmB|HiDrNcBtGs@zC_A|CmCpIQl@cArBUp@i@hC]bBW~@kA`Ck@|@_@h@uBlBc@p@iBlCy@fA_ApAYp@Oh@cBlCaB~B{@nAO\\yAlCeA~BuAlE}CfIiFnLmCrEeCvDuC`EmD|EaArAc@p@MbAGPeBvBmAhA_AhAy@jA|AbAQf@g@n@GBu@_@aAa@g@h@qB~BcClCeDbDuGfHcBvA_Ap@kFdDuA`Ak@h@{D~C}DzCwDnCqCrBqAz@kB|Ag@XaAn@eAt@aFbDu@v@}@n@_@VwAh@uBzAoBpAqA`AgAt@Wj@W\\qB~A_Bv@yB|@eBp@uCtAcCfAkA^aAd@i@PuAp@yAh@{@Po@Dk@Pa@\\S\\vHhGbAp@jClA~Bv@|@h@r@h@~B`Bl@d@|AxAR`@NZ@`@@V@XFrB?bBFXTxAXpCFl@RzAZ~@nAhBL^lC~K`ArD|@pBp@hA|A|Cv@fBR\\f@f@~AdAtA`AZX`FhDlAn@l@b@NTBZOp@St@C`@Hb@^p@pAhBrAzAfCpC^|@J`@?lAEzEXt@t@bAx@zAb@fAn@dALx@FjATrBRpAFBBDLh@VTZK|@IdGIh@EnGKhBCL@\\HVPn@h@h@^~@j@j@Vf@JdAPNH\\VN\\BZQvBAlBFRBNK`@En@Eb@IXWd@WVa@Lq@JeAByIFsELW??DRTb@TLPHX@n@C^An@D\\HTRXZp@JR\\Rp@Xx@XLRPr@B`@K~@G\\GvAcFxA_@PUZX~@HVvBrHfHbVnFzQhDjLVz@F?D@PX^z@r@t@vChBhAx@f@d@x@jAXn@x@pCrGjTnDlLnAbE\\|AnCzIpAdEhCnJjGtSbBtFNx@Ab@I^KTYVq@XeCv@oCr@e@Hs@A]KUMUWmAsDw@sBOu@uA_FWy@kCaJKUCCE?CAEBIPX`AqA\\q@JMBW@QH',
  legs: [
    Leg(
      distance: '23,2 km',
      duration: '58 menit',
      end: const Address(name: 'VMG3+89C, Pajang, Kec. Benda, Kota Tangerang, Banten 15126, Indonesia', lngLat: [106.6535296, -6.1240275]),
      start: const Address(
          name: 'Jl. Jemb. Dua Raya No.15, RT.5/RW.4, Pejagalan, Kec. Penjaringan, Kota Jkt Utara, Daerah Khusus Ibukota Jakarta 14450, Indonesia',
          lngLat: [106.7930763, -6.138698499999999]),
      steps: [Steps()],
    ),
  ],
);

final jPlace = readJson('maps/place.json');
final jPlaceDetail = readJson('maps/place_detail.json');
final jDirection = readJson('maps/direction.json');

void main() {
  group('Maps model', () {
    test('place fromMap', () {
      final result = Place.fromMap(jsonDecode(jPlace)['predictions'][0]);
      expect(result, equals(tPlace));
    });

    test('place detail fromMap', () {
      final result = PlaceDetail.fromMap(jsonDecode(jPlaceDetail)['result']);
      expect(result, equals(tPlaceDetail));
    });

    test('direction fromMap', () {
      final result = Direction.fromMap(jsonDecode(jDirection)['routes'][0]);
      expect(result, tDirection);
    });
  });
}
