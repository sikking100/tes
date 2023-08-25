import 'dart:convert';

import 'package:api/branch/model.dart';
import 'package:api/common.dart';
import 'package:api/region/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final Branch tBranch = Branch(
  id: 'string',
  name: 'string',
  region: Region(
      id: "string",
      name: "string",
      createdAt: DateTime.parse('2022-12-19T14:26:39.679Z').toLocal(),
      updatedAt: DateTime.parse('2022-12-19T14:26:39.679Z').toLocal()),
  address: const Address(),
  createdAt: DateTime.parse('2022-12-19T14:26:39.679Z').toLocal(),
  updatedAt: DateTime.parse('2022-12-19T14:26:39.679Z').toLocal(),
);

// final Paging<Branch> tpBranch = Paging(const Item(regionId: 'string'), const Item(regionId: 'string'), [tBranch]);

final jBranch = readJson('branch/branch.json');
final jpBranch = readJson('branch/branch_paging.json');
void main() {
  test('Branch model fromJson', () {
    final result = Branch.fromMap(jsonDecode(jBranch)['data']);
    expect(result, equals(tBranch));
  });
}
