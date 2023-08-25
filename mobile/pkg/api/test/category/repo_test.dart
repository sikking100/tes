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
//   late CategoryRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = CategoryRepoImpl(client, auth);
//   });

//   const path = 'category/api/v1';

//   group('Category repository', () {
//     group('find All', () {
//       test(test200('category'), () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpCategory, 200));

//         final result = await repo.findAll(pageLimit: 0, pageNumber: 0);

//         expect(result, equals(tpCategory));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.findAll(pageLimit: 0, pageNumber: 0);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('find', () {
//       test(test200('category'), () async {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jCategory, 200));

//         final result = await repo.find('string');

//         expect(result, equals(tCategory));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, '$path/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
