import 'dart:convert';

import 'package:api/report/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final tReport = Report(
  sendDate: DateTime.parse('2022-11-27T01:43:19.030Z').toLocal(),
  id: "string",
  from: const ReportUser(id: "string", name: "string", roles: 0, imageUrl: "string", description: "string"),
  to: const ReportUser(id: "string", name: "string", roles: 0, imageUrl: "string", description: "string"),
  title: "string",
  imageUrl: "string",
  filePath: "string",
);

const tReportUser = ReportUser(id: "string", name: "string", roles: 0, imageUrl: "string", description: "string");

const tReportSave = SaveReport(
  from: ReportUser(id: "string", name: "string", roles: 0, imageUrl: "string", description: "string"),
  to: ReportUser(id: "string", name: "string", roles: 0, imageUrl: "string", description: "string"),
  title: "string",
  description: 'string',
);

// final tpReport = Paging<Report>(const Item(), const Item(), [tReport]);

final jReport = readJson('report/report.json');
final jReportList = readJson('report/report_list.json');
final jReportSave = readJson('report/report_save.json');
final jReportUser = readJson('report/report_user.json');

void main() {
  group('Report model', () {
    test('fromMap', () {
      final result = Report.fromMap(jsonDecode(jReport)['data']);
      expect(result, equals(tReport));
    });

    test('save toMap', () {
      final result = tReportSave.toMap();
      expect(result, jsonDecode(jReportSave));
    });

    test('report user fromMap', () {
      final result = ReportUser.fromMap(jsonDecode(jReportUser));
      expect(result, equals(tReportUser));
    });
  });
}
