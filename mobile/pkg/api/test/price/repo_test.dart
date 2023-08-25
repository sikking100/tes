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
//   late PriceRepo repo;
//   late MockAuth auth;

//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = PriceRepoImpl(client, auth);
//   });

//   const String path = 'price/api/v1';

//   const String e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const String e401 = 'Anda tidak punya akses';
//   const String e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Price repository', () {
//     group('newest', () {
//       test(test200('paging of price'), () async {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpPrice, 200));

//         final result = await repo.newest(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(result, equals(tpPrice));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.newest(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//       test(testNot200(401), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.newest(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.newest(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byBrand', () {
//       test(test200('paging of price'), () async {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'brandId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpPrice, 200));

//         final result = await repo.byBrand(pageNumber: 0, pageLimit: 0, priceId: 'string', id: 'string');

//         expect(result, equals(tpPrice));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'brandId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.byBrand(pageNumber: 0, pageLimit: 0, priceId: 'string', id: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//       test(testNot200(401), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'brandId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.byBrand(pageNumber: 0, pageLimit: 0, priceId: 'string', id: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'brandId': 'string',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.byBrand(pageNumber: 0, pageLimit: 0, priceId: 'string', id: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('terlaris', () {
//       test(test200('paging of price'), () async {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '1',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpPrice, 200));

//         final result = await repo.laris(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(result, equals(tpPrice));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '1',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));
//         final result = repo.laris(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '1',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.laris(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '1',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.laris(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('diskon', () {
//       test(test200('paging of price'), () async {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '2',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpPrice, 200));

//         final result = await repo.diskon(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(result, equals(tpPrice));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '2',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.diskon(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//       test(testNot200(401), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '2',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.diskon(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//                 Uri.https(host, path, {
//                   'pageNumber': '0',
//                   'pageLimit': '0',
//                   'priceId': 'string',
//                   'sort': '2',
//                 }),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.diskon(pageNumber: 0, pageLimit: 0, priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('pencarian', () {
//       test(test200('list of price'), () async {
//         when(client.get(Uri.https(host, path, {'priceId': 'string', 'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpPrice, 200));

//         final result = await repo.search(query: 'string', priceId: 'string');

//         expect(result, equals([tPrice]));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'priceId': 'string', 'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.search(query: 'string', priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'priceId': 'string', 'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.search(query: 'string', priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'priceId': 'string', 'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.search(query: 'string', priceId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byId', () {
//       test(test200('price'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(jPrice, 200));

//         final result = await repo.byId('string');

//         expect(result, equals(tPrice));
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
