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
//   late BranchRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = BranchRepoImpl(client, auth);
//   });

//   const String path = 'branch/api/v1';

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e404 = 'Cabang tidak ditemukan';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Branch repository', () {
//     group('search', () {
//       test(test200('branch'), () async {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpBranch, 200));

//         final result = await repo.search('string');

//         expect(result, equals([tBranch]));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(404), () {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(
//             jsonEncode(jsonError
//               ..addAll({'code': 404})
//               ..update('message', (value) => 'branch not found')),
//             404));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e404)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('find', () {
//       test(test200('paging of branch'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'regionId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpBranch, 200));

//         final result = await repo.find(pageLimit: 0, pageNumber: 0, regionId: 'string');

//         expect(result, equals(tpBranch));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'regionId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find(pageLimit: 0, pageNumber: 0, regionId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'regionId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.find(pageLimit: 0, pageNumber: 0, regionId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });
//       test(testNot200(404), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'regionId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(
//                 jsonEncode(jsonError
//                   ..addAll({'code': 404})
//                   ..update('message', (value) => 'branch not found')),
//                 404));

//         final result = repo.find(pageLimit: 0, pageNumber: 0, regionId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e404)));
//       });
//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'regionId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.find(pageLimit: 0, pageNumber: 0, regionId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byId', () {
//       test(test200('branch'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(jBranch, 200));

//         final result = await repo.byId('string');

//         expect(result, equals(tBranch));
//       });
//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.byId('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.byId('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });
//       test(testNot200(404), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(
//             jsonEncode(jsonError
//               ..addAll({'code': 404})
//               ..update('message', (value) => 'branch not found')),
//             404));

//         final result = repo.byId('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e404)));
//       });
//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.byId('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });
//   });
// }
