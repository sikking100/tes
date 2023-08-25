// import 'dart:convert';

// import 'package:api/api.dart';
// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart';
// import 'package:mockito/mockito.dart';

// import '../api_test.dart';
// import '../api_test.mocks.dart';
// import '../order/model_test.dart';
// import 'model_test.dart';

// void main() {
//   late MockClient client;
//   late DeliveryRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = DeliveryRepoImpl(client, auth);
//   });

//   const String path = 'deliver/api/v1';

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e404 = 'Data tidak ditemukan';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Delivery repository', () {
//     group('products', () {
//       test(test200('list of product'), () async {
//         when(client.get(Uri.https(host, '$path/product', {'courierId': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jOrderProduct, 200));

//         final result = await repo.products('string');

//         expect(result, equals([tOrderProduct]));
//       });
//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, '$path/product', {'courierId': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.products('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });
//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, '$path/product', {'courierId': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.products('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, '$path/product', {'courierId': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.products('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//     });

//     group('send', () {
//       test(test200('deliver'), () async {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jOrder, 200));

//         final result = await repo.send(branchId: 'string', orderId: 'string');

//         expect(result, equals(tOrder));
//       });
//       test(testNot200(401), () {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.send(branchId: 'string', orderId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });
//       test(testNot200(500), () {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.send(branchId: 'string', orderId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//       test(testNot200(400), () {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.send(branchId: 'string', orderId: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//     });

//     group('complete', () {
//       test(test200('deliver'), () async {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '2'}),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tComplete.toMap())))
//             .thenAnswer((_) async => Response(jOrder, 200));

//         final result = await repo.complete(orderId: 'string', branchId: 'string', req: tComplete);

//         expect(result, equals(tOrder));
//       });
//       test(testNot200(401), () {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '2'}),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tComplete.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.complete(orderId: 'string', branchId: 'string', req: tComplete);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });
//       test(testNot200(500), () {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '2'}),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tComplete.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.complete(orderId: 'string', branchId: 'string', req: tComplete);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//       test(testNot200(400), () {
//         when(client.put(Uri.https(host, '$path/string', {'branchId': 'string', 'type': '2'}),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tComplete.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.complete(orderId: 'string', branchId: 'string', req: tComplete);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });
//     });
//   });
// }
