import 'dart:convert';

import 'package:api/region/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final tRegion = Region(
  id: 'string',
  name: 'string',
  createdAt: DateTime.parse('2022-12-08T06:32:37.773Z').toLocal(),
  updatedAt: DateTime.parse('2022-12-08T06:32:37.773Z').toLocal(),
);

// final tpRegion = Paging<Region>(const Item(), const Item(), [tRegion]);

final jRegion = readJson('region/region.json');
final jpRegion = readJson('region/region_paging.json');

void main() {
  test('Region model fromMap', () {
    final result = Region.fromMap(jsonDecode(jRegion)['data']);
    expect(result, equals(tRegion));
  });
}
