// import 'dart:convert';

// import 'package:api/branch/model.dart';
// import 'package:api/brand/model.dart';
// import 'package:api/category/model.dart';
// import 'package:api/categoryPrice/model.dart';
// import 'package:api/common.dart';
// import 'package:api/price/model.dart';
// import 'package:api/product/model.dart';
// import 'package:api/region/model.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../json_reader.dart';

// final Price tPrice = Price(
//   id: 'string',
//   price: 0,
//   discount: Discount(
//     expiredAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//     items: const [
//       DiscountItem(discount: 0, max: 0, min: 0),
//     ],
//   ),
//   createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//   updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//   categoryPrice: CategoryPrice(
//     id: 'string',
//     branch: Branch(
//       id: 'string',

//       address: const Address(),

//       createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//       region: Region(
//         id: 'string',
//         createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//         name: 'string',
//         updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//       ),
//       updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//       name: 'string',
//     ),
//     createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//     updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//     name: 'string',
//     team: 0,
//   ),
//   product: Product(
//     id: "string",
//     name: "string",
//     description: "string",
//     size: "string",
//     team: 0,
//     imageUrl: "string",
//     brand: Brand(
//       id: 'string',
//       createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//       imageUrl: 'string',
//       name: 'string',
//       updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//     ),
//     category: Category(
//       id: 'string',
//       createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//       updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//       food: 0,
//       name: 'string',
//       retail: 0,
//     ),
//     point: 0.0,
//     createdAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//     updatedAt: DateTime.parse('2022-12-19T15:23:33.962Z').toLocal(),
//   ),
// );

// final tpPrice = Paging<Price>(const Item(priceId: 'string'), const Item(priceId: 'string'), [tPrice]);

// final jpPrice = readJson('price/price_paging.json');
// final jPrice = readJson('price/price.json');

// void main() {
//   test('Price model fromMap', () {
//     final result = Price.fromMap((jsonDecode(jPrice)['data']));
//     expect(result, equals(tPrice));
//   });

//   final discount = Discount(
//     expiredAt: DateTime.now(),
//     items: const [
//       DiscountItem(
//         discount: 1000,
//         min: 0,
//         max: 10,
//       ),
//       DiscountItem(
//         discount: 4000,
//         min: 31,
//       ),
//       DiscountItem(
//         discount: 2000,
//         min: 11,
//         max: 20,
//       ),
//       DiscountItem(
//         discount: 3000,
//         min: 21,
//         max: 30,
//       ),
//     ],
//   );
//   test('Discount list', () {
//     int result = 0;
//     int jumlah = 5;
//     for (var element in discount.items) {
//       final max = element.max;
//       if (max == null && jumlah >= element.min) {
//         result = element.discount;
//         break;
//       }
//       if (max != null && jumlah >= element.min && jumlah <= max) {
//         result = element.discount;
//         break;
//       }
//     }
//     expect(result, 1000);
//   });
// }
