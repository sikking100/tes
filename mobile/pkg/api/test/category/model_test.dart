import 'dart:convert';

import 'package:api/category/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final tCategory = Category(
  id: 'string',
  createdAt: DateTime.parse('2022-11-28T09:09:13.851Z').toLocal(),
  name: 'string',
  updatedAt: DateTime.parse('2022-11-28T09:09:13.851Z').toLocal(),
);

// final tpCategory = Paging<Category>(const Item(), const Item(), [tCategory]);

final jCategory = readJson('category/category.json');
final jpCategory = readJson('category/category_paging.json');

void main() {
  test('Category model fromMap', () {
    final result = Category.fromMap(jsonDecode(jCategory)['data']);
    expect(result, equals(tCategory));
  });
}
