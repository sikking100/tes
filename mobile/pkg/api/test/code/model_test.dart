import 'dart:convert';

import 'package:api/code/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final tCode = Code(
  id: 'JKT01',
  description: 'ccc',
  createdAt: DateTime.parse('2022-12-15T07:17:51.834Z').toLocal(),
  updatedAt: DateTime.parse('2022-12-15T07:17:51.834Z').toLocal(),
);

// final tpCode = Paging<Code>(null, null, [tCode]);

final jCode = readJson('code/code.json');
final jpCode = readJson('code/code_paging.json');

void main() {
  test('Code model fromMap', () {
    final result = Code.fromMap(jsonDecode(jCode)['data']);
    expect(result, equals(tCode));
  });
}
