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
//   late RegionRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = RegionRepoImpl(client, auth);
//   });

//   const String path = 'region/api/v1';
//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Region repository', () {
//     group('find', () {
//       test(test200('region'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpRegion, 200));

//         final result = await repo.find(pageLimit: 0, pageNumber: 0);

//         expect(result, equals(tpRegion));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find(pageLimit: 0, pageNumber: 0);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.find(pageLimit: 0, pageNumber: 0);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.find(pageLimit: 0, pageNumber: 0);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('search', () {
//       test(test200('region'), () async {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpRegion, 200));

//         final result = await repo.search('string');

//         expect(result, equals([tRegion]));
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

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byId', () {
//       test(test200('region'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(jRegion, 200));

//         final result = await repo.byId('string');

//         expect(result, equals(tRegion));
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
