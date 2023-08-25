// import 'dart:convert';

// import 'package:api/branch/model.dart';
// import 'package:api/categoryPrice/model.dart';
// import 'package:api/common.dart';
// import 'package:api/region/model.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../json_reader.dart';

// final tCategoryPrice = CategoryPrice(
//   id: 'CATPRICE003',
//   team: 2,
//   branch: Branch(
//     id: 'BRA001',
//     address: const Address(),
//     name: 'Makassar',
//     region: Region(
//       id: 'REG02',
//       name: 'Sulawesi',
//       createdAt: DateTime.parse('2022-12-19T14:40:19.748Z').toLocal(),
//       updatedAt: DateTime.parse('2022-12-19T14:44:56.284Z').toLocal(),
//     ),
//     createdAt: DateTime.parse("2022-12-19T14:44:37.475Z").toLocal(),
//     updatedAt: DateTime.parse("2022-12-19T14:44:37.475Z").toLocal(),
//   ),
//   name: 'Kategori harga 3',
//   createdAt: DateTime.parse("2022-12-19T15:20:55.082Z").toLocal(),
//   updatedAt: DateTime.parse("2022-12-19T15:20:55.082Z").toLocal(),
// );

// final jCategoryPrice = readJson('categoryPrice/category_price.json');

// void main() {
//   group('CategoryPrice model', () {
//     test('fromMap', () {
//       final result = CategoryPrice.fromMap(jsonDecode(jCategoryPrice)['data']);
//       expect(result, equals(tCategoryPrice));
//     });

//     test('toMap', () {
//       final result = tCategoryPrice.toMap();
//       expect(result, equals(jsonDecode(jCategoryPrice)['data']));
//     });
//   });
// }
