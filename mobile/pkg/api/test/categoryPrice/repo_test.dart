// import 'dart:convert';

// import 'package:api/categoryPrice/repo.dart';
// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart';
// import 'package:mockito/mockito.dart';

// import '../api_test.dart';
// import '../api_test.mocks.dart';
// import 'model_test.dart';

// void main() {
//   late MockClient client;
//   late CategoryPriceRepo repo;
//   late MockAuth auth;

//   setUp(() {
//     auth = MockAuth();
//     client = MockClient();
//     repo = CategoryPriceRepoImpl(client, auth);
//   });

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   const path = 'category-price/api/v1';

//   group('CategoryPrice repository', () {
//     group('byBranch', () {
//       test(test200('CategoryPrice'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jCategoryPrice, 200));

//         final result = await repo.byBranch('string');

//         expect(result, equals(tCategoryPrice));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 200));

//         final result = repo.byBranch('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 200));

//         final result = repo.byBranch('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 200));

//         final result = repo.byBranch('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byNear', () {
//       test(test200('CategoryPrice'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': '0.0,0.0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jCategoryPrice, 200));

//         final result = await repo.byNear(lat: 0.0, lng: 0.0);

//         expect(result, equals(tCategoryPrice));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': '0.0,0.0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 200));

//         final result = repo.byNear(lat: 0.0, lng: 0.0);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': '0.0,0.0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 200));

//         final result = repo.byNear(lat: 0.0, lng: 0.0);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'query': '0.0,0.0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 200));

//         final result = repo.byNear(lat: 0.0, lng: 0.0);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });
//   });
// }
