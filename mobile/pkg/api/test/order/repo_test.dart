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
//   late OrderRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = OrderRepoImpl(client, auth);
//   });

//   const String path = 'order/api/v1';
//   const String approvalPath = 'order-approval/api/v1';

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   final date = DateTime.now();

//   group('Order repository', () {
//     group('find', () {
//       test(test200('paging of order'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'query': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpOrder, 200));

//         final result = await repo.find(query: 'string', type: Type.pending);

//         expect(result, equals(tpOrder));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'query': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find(query: 'string', type: Type.pending);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'query': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.find(query: 'string', type: Type.pending);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'query': 'string', 'type': '1'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.find(query: 'string', type: Type.pending);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('search', () {
//       test(test200('list of order'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'search': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpOrder, 200));

//         final result = await repo.search('string');

//         expect(result, equals([tOrder]));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'search': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'search': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '1', 'search': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('byId', () {
//       test(test200('order'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jOrder, 200));

//         final result = await repo.byId('string');

//         expect(result, equals(tOrder));
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

//     group('create', () {
//       test(test200('order'), () async {
//         when(client.post(Uri.https(host, path),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreateOrder.toMap())))
//             .thenAnswer((_) async => Response(jOrder, 200));

//         final result = await repo.create(tCreateOrder);

//         expect(result, equals(tOrder));
//       });

//       test(testNot200(400), () {
//         when(client.post(Uri.https(host, path),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreateOrder.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.create(tCreateOrder);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.post(Uri.https(host, path),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreateOrder.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.create(tCreateOrder);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.post(Uri.https(host, path),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreateOrder.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.create(tCreateOrder);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('approval', () {
//       test(test200('order'), () async {
//         when(client.post(Uri.https(host, approvalPath),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tApproval.toMap())))
//             .thenAnswer((_) async => Response(jOrder, 200));

//         final result = await repo.approval(tApproval);

//         expect(result, equals(tOrder));
//       });

//       test(testNot200(400), () {
//         when(client.post(Uri.https(host, approvalPath),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tApproval.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.approval(tApproval);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.post(Uri.https(host, approvalPath),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tApproval.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.approval(tApproval);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.post(Uri.https(host, approvalPath),
//                 headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tApproval.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.approval(tApproval);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });

//     group('performance', () {
//       test(test200('list of performance'), () async {
//         when(client.get(
//                 Uri.https(host, '$path/find/performance', {'startAt': date.toIso8601String(), 'endAt': date.toIso8601String(), 'query': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jPerformance, 200));

//         final result = await repo.performance(startAt: date, endAt: date, query: 'string');

//         expect(result, equals([tPerformance]));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//                 Uri.https(host, '$path/find/performance', {'startAt': date.toIso8601String(), 'endAt': date.toIso8601String(), 'query': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.performance(startAt: date, endAt: date, query: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.get(
//                 Uri.https(host, '$path/find/performance', {'startAt': date.toIso8601String(), 'endAt': date.toIso8601String(), 'query': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.performance(startAt: date, endAt: date, query: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(500), () {
//         when(client.get(
//                 Uri.https(host, '$path/find/performance', {'startAt': date.toIso8601String(), 'endAt': date.toIso8601String(), 'query': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.performance(startAt: date, endAt: date, query: 'string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });
//   });
// }
