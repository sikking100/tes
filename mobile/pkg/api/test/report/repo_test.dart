// import 'dart:convert';

// import 'package:api/api.dart';
// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart';
// import 'package:mockito/mockito.dart';

// import '../api_test.dart';
// import '../api_test.mocks.dart';
// import 'model_test.dart';

// void main() {
//   late MockClient client;
//   late ReportRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = ReportRepoImpl(client, auth);
//   });

//   const path = 'report/api/v1';

//   group('Report repository', () {
//     group('create', () {
//       // test(test200('report'), () async {
//       //   when(client.post(Uri.https(host, path), headers: const Headers('customer').toMap(), body: jsonEncode(tReportSave.toMap())))
//       //       .thenAnswer((_) async => Response(jReport, 200));

//       //   final result = await repo.create(tReportSave);

//       //   expect(result, equals(tReport));
//       // });

//       test(testNot200(400), () {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMap(), body: jsonEncode(tReportSave.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.create(tReportSave);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('delete', () {
//       test(test200('report'), () async {
//         when(client.delete(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jReport, 200));

//         final result = await repo.delete('string');

//         expect(result, equals(tReport));
//       });

//       test(testNot200(400), () {
//         when(client.delete(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.delete('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('find', () {
//       test(test200('report'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(jReport, 200));

//         final result = await repo.find('string');

//         expect(result, equals(tReport));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('findAll', () {
//       test(test200('list of report'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'from': 'string', 'to': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jReportList, 200));

//         final result = await repo.findAll(to: 'string', from: 'string');

//         expect(result, equals(tpReport));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'from': 'string', 'to': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.findAll(to: 'string', from: 'string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
