import 'dart:convert';

import 'package:api/brand/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final tBrand = Brand(
    id: 'string',
    name: 'string',
    imageUrl: 'string',
    createdAt: DateTime.parse('2022-12-08T06:52:19.128Z').toLocal(),
    updatedAt: DateTime.parse('2022-12-08T06:52:19.128Z').toLocal());

// final tpBrand = Paging<Brand>(const Item(), const Item(), [tBrand]);

final jBrand = readJson('brand/brand.json');
final jpBrand = readJson('brand/brand_paging.json');

void main() {
  test('Brand model fromJson', () {
    final result = Brand.fromMap(jsonDecode(jBrand)["data"]);
    expect(result, equals(tBrand));
  });
}
