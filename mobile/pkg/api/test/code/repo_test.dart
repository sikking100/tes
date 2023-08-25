// import 'dart:convert';

// import 'package:api/code/repo.dart';
// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart';
// import 'package:mockito/mockito.dart';

// import '../api_test.dart';
// import '../api_test.mocks.dart';
// import 'model_test.dart';

// void main() {
//   late MockAuth auth;
//   late MockClient client;
//   late CodeRepo repo;

//   setUp(() {
//     auth = MockAuth();
//     client = MockClient();
//     repo = CodeRepoImpl(client, auth);
//   });

//   const path = 'code/api/v1';

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e404 = 'Data tidak ditemukan';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Code Repository', () {
//     group('find', () {
//       test(test200('Paging of Business'), () async {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jpCode, 200));

//         final result = await repo.find();

//         expect(result, equals(tpCode));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));
//         final result = repo.find();
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));
//         final result = repo.find();
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(404), () {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 404})), 404));
//         final result = repo.find();
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e404)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));
//         final result = repo.find();
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byId', () {
//       test(test200('Business'), () async {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jCode, 200));

//         final result = await repo.byId('string');

//         expect(result, equals(tCode));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));
//         final result = repo.byId('string');
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));
//         final result = repo.byId('string');
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(404), () {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 404})), 404));
//         final result = repo.byId('string');
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e404)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));
//         final result = repo.byId('string');
//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });
//   });
// }
