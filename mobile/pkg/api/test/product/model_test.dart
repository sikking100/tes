// import 'dart:convert';

// import 'package:api/brand/model.dart';
// import 'package:api/category/model.dart';
// import 'package:api/common.dart';
// import 'package:api/product/model.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../json_reader.dart';

// final tProduct = Product(
//   id: "string",
//   name: "string",
//   description: "string",
//   size: "string",
//   team: 0,
//   imageUrl: "string",
//   category: Category(
//     id: 'string',
//     createdAt: DateTime.parse("2022-12-19T15:33:44.553Z").toLocal(),
//     food: 0,
//     name: 'string',
//     retail: 0,
//     updatedAt: DateTime.parse("2022-12-19T15:33:44.553Z").toLocal(),
//   ),
//   brand: Brand(
//     id: 'string',
//     createdAt: DateTime.parse("2022-12-19T15:33:44.553Z").toLocal(),
//     imageUrl: 'string',
//     name: 'string',
//     updatedAt: DateTime.parse("2022-12-19T15:33:44.553Z").toLocal(),
//   ),
//   point: 0.0,
//   createdAt: DateTime.parse("2022-12-19T15:33:44.553Z").toLocal(),
//   updatedAt: DateTime.parse("2022-12-19T15:33:44.553Z").toLocal(),
// );

// final tpProduct = Paging<Product>(const Item(team: 0), const Item(team: 0), [tProduct]);

// final jProduct = readJson('product/product.json');
// final jpProduct = readJson('product/product_paging.json');

import 'package:api/price_list/model.dart';
import 'package:flutter_test/flutter_test.dart';

final price = [
  const PriceList(
    id: 'PL05',
    price: 305000.0,
  ),
  const PriceList(
    id: 'PL04',
    price: 325000.0,
  ),
  const PriceList(
    id: 'PL02',
    price: 315000.0,
  ),
  const PriceList(
    id: 'PL01',
    price: 320000.0,
  ),
  const PriceList(
    id: 'PL03',
    price: 310000.0,
  ),
];

void main() {
  // test('Produk model fromJson', () {
  //   final result = Product.fromMap(jsonDecode(jProduct)["data"]);
  //   expect(result, equals(tProduct));
  // });
  test('price terbesar', () {
    price.sort((a, b) => b.price.compareTo(a.price));
    final result = price.first;
    expect(result.id, 'PL04');
  });
}
