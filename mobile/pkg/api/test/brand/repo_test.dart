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
//   late BrandRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = BrandhRepoImpl(client, auth);
//   });

//   const String path = 'brand/api/v1';

//   const e400 = 'Input tidak valid, pastikan semua inputan sudah benar';
//   const e401 = 'Anda tidak punya akses';
//   const e500 = 'Sistem sedang sibuk, silakan coba beberapa saat lagi';

//   group('Brand repository find All', () {
//     test(test200('brand'), () async {
//       when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//           .thenAnswer((_) async => Response(jpBrand, 200));

//       final result = await repo.findAll(pageNumber: 0, pageLimit: 0);

//       expect(result, equals(tpBrand));
//     });

//     test(testNot200(400), () {
//       when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//           .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//       final result = repo.findAll(pageNumber: 0, pageLimit: 0);

//       expect(() => result, throwsA(isA<String>()));
//       expect(() => result, throwsA(equals(e400)));
//     });

//     test(testNot200(401), () {
//       when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//           .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 401})), 401));

//       final result = repo.findAll(pageNumber: 0, pageLimit: 0);

//       expect(() => result, throwsA(isA<String>()));
//       expect(() => result, throwsA(equals(e401)));
//     });

//     test(testNot200(500), () {
//       when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//           .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 500})), 500));

//       final result = repo.findAll(pageNumber: 0, pageLimit: 0);

//       expect(() => result, throwsA(isA<String>()));
//       expect(() => result, throwsA(equals(e500)));
//     });
//   });
// }
