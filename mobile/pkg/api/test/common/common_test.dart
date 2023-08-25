import 'dart:convert';

import 'package:api/common.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

void main() {
  group('Header', () {
    final json = readJson('common/header1.json');
    final jsonWithoutAuth = readJson('common/header3.json');
    final jsonCreate = readJson('common/header2.json');
    final jsonCreateWithoutAuth = readJson('common/header4.json');
    const Headers headers = Headers('token');
    const Headers headersWithoutAuth = Headers();
    test('class', () {
      const result = Headers('token');
      expect(result, equals(headers));
    });

    test('toMap', () {
      final result = headers.toMap();
      expect(result, equals(jsonDecode(json)));
    });

    test('toMapCreate', () {
      final result = headers.toMapWithReq();
      expect(result, equals(jsonDecode(jsonCreate)));
    });
    test('toMapWithoutAuth', () {
      final result = headersWithoutAuth.toMap();
      expect(result, equals(jsonDecode(jsonWithoutAuth)));
    });

    test('toMapCreateWithoutAuth', () {
      final result = headersWithoutAuth.toMapWithReq();
      expect(result, equals(jsonDecode(jsonCreateWithoutAuth)));
    });
  });

  group('Response', () {
    const Responses response = Responses(200, 'message', {"items": []});
    const json = {
      'code': 200,
      'data': {"items": []},
      'message': 'message'
    };
    test('class', () {
      const result = Responses(200, 'message', {"items": []});
      expect(result, equals(response));
    });

    test('fromJson', () {
      final result = Responses.fromMap(json);
      expect(result, equals(response));
    });

    test('toString', () {
      expect(response.toString(), isA<String>());
    });
  });

  group('Paging', () {
    // final tBrand = Brand(
    //   id: 'BRAND801671008283328',
    //   name: 'Milko',
    //   imageUrl: 'https://storage.googleapis.com/dairy-food-development.appspot.com/default/brand.png',
    //   createdAt: DateTime.parse('2022-12-14T08:58:04.766Z').toLocal(),
    //   updatedAt: DateTime.parse('2022-12-14T08:58:04.766Z').toLocal(),
    // );
    // // final tPaging = Paging<Brand>(const Item(pageLimit: 2, pageNumber: 2), null, [tBrand, tBrand]);

    // final jPaging = readJson('common/paging.json');
    // test('fromJson', () {
    //   final result = Paging<Brand>.fromMap(jsonDecode(jPaging)['data'], Brand.fromMap);
    //   expect(result, equals(tPaging));
    // });

    // test('copyWith', () {
    //   final result = tPaging.copyWith();
    //   expect(result, tPaging);
    // });
  });

  group('Next', () {
    const tNext1 = Item(pageNumber: 0, pageLimit: 0, branchId: 'string', regionId: 'string');
    const tNext2 = Item(
      pageLimit: 0,
      pageNumber: 0,
    );
    const tNext3 = Item(pageLimit: 0, pageNumber: 0, regionId: 'string');

    final jNext1 = readJson('common/next-1.json');
    final jNext2 = readJson('common/next-2.json');
    final jNext3 = readJson('common/next-3.json');

    test('fromMap Next 1', () {
      final result = Item.fromMap(jsonDecode(jNext1));
      expect(result, equals(tNext1));
    });

    test('fromMap Next 2', () {
      final result = Item.fromMap(jsonDecode(jNext2));
      expect(result, equals(tNext2));
    });

    test('fromMap Next 3', () {
      final result = Item.fromMap(jsonDecode(jNext3));
      expect(result, equals(tNext3));
    });
  });

  group('Address', () {
    const Address tAddress = Address(name: 'string', lngLat: [119.42595478321972, -5.147121083821573]);

    final jAddress = readJson('common/address.json');
    test('fromMap', () {
      final result = Address.fromMap(jsonDecode(jAddress));
      expect(result, equals(tAddress));
    });

    test('toMap', () {
      final result = tAddress.toMap();
      expect(result, equals(jsonDecode(jAddress)));
    });

    test('lat', () {
      final result = tAddress.lat;
      expect(result, equals(-5.147121083821573));
    });

    test('lng', () {
      final result = tAddress.lng;
      expect(result, equals(119.42595478321972));
    });

    test('copyWith', () {
      final result = tAddress.copyWith();
      expect(result, equals(tAddress));
    });
  });

  group('CreatedBy', () {
    const tCreatedBy1 = CreatedBy(
      id: 'string',
      name: 'string',
      roles: 'string',
      imageUrl: 'string',
      description: 'string',
    );
    final tCreatedBy2 = CreatedBy(
      id: "string",
      roles: "string",
      name: "string",
      phone: "string",
      note: "string",
      status: "PENDING",
      imageUrl: "string",
      updatedAt: DateTime.parse('2022-11-28T06:21:28.854Z').toLocal(),
    );

    const tCreatedBy3 = CreatedBy(
      id: "string",
      name: "string",
      phone: "string",
      roles: "string",
      imageUrl: "string",
    );

    final jCreatedBy1 = readJson('common/created-by-1.json');
    final jCreatedBy2 = readJson('common/created-by-2.json');
    final jCreatedBy3 = readJson('common/created-by-3.json');

    test('fromJson1', () {
      final result = CreatedBy.fromMap(jsonDecode(jCreatedBy1));
      expect(result, equals(tCreatedBy1));
    });

    test('fromJson2', () {
      final result = CreatedBy.fromMap(jsonDecode(jCreatedBy2));
      expect(result, equals(tCreatedBy2));
    });
    test('fromJson3', () {
      final result = CreatedBy.fromMap(jsonDecode(jCreatedBy3));
      expect(result, equals(tCreatedBy3));
    });

    test('toJson1', () {
      final result = tCreatedBy1.toActivitySave();
      expect(result, equals(jsonDecode(jCreatedBy1)));
    });
    test('toJson3', () {
      final result = tCreatedBy3.toMap();
      expect(result, equals(jsonDecode(jCreatedBy3)));
    });
  });
}
