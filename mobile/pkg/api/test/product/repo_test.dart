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
//   late ProductRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = ProductRepoImpl(client, auth);
//   });

//   const String path = 'product/api/v1';

//   group('Product repository', () {
//     group('find', () {
//       test(test200('paging of product'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'team': 'null'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpProduct, 200));

//         final result = await repo.find(pageNumber: 0, pageLimit: 0);

//         expect(result, equals(tpProduct));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'team': 'null'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find(pageNumber: 0, pageLimit: 0);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('byId', () {
//       test(test200(' product'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jProduct, 200));

//         final result = await repo.byId('string');

//         expect(result, equals(tProduct));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.byId('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('search', () {
//       test(test200('list of product'), () async {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpProduct, 200));

//         final result = await repo.search('string');

//         expect(result, equals([tProduct]));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'search': 'string'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
