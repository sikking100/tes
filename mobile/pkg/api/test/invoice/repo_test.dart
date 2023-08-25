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
//   late InvoiceRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = InvoiceRepoImpl(client, auth);
//   });

//   const String path = 'invoice/api/v1';

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e404 = 'Data tidak ditemukan';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Invoice repository', () {
//     group('create', () {
//       test(test200('invoice'), () async {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreate.toMap())))
//             .thenAnswer((_) async => Response(jOrder, 200));

//         final result = await repo.create(tCreate);

//         expect(result, equals(tOrder));
//       });

//       test(testNot200(400), () {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreate.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.create(tCreate);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e400)));
//       });

//       test(testNot200(401), () {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreate.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//         final result = repo.create(tCreate);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e401)));
//       });

//       test(testNot200(404), () {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreate.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 404})), 404));

//         final result = repo.create(tCreate);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e404)));
//       });

//       test(testNot200(500), () {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tCreate.toMap())))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//         final result = repo.create(tCreate);

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals(e500)));
//       });
//     });
//   });
// }
