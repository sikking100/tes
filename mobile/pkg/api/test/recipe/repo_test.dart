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
//   late RecipeRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = RecipeRepoImpl(client, auth);
//   });

//   const path = 'recipe/api/v1';

//   group('Recipe repository', () {
//     group('categories', () {
//       test(test200('list of string'), () async {
//         when(client.get(
//           Uri.https(host, path, {'categories': 'true'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(
//             jsonEncode({
//               'code': 200,
//               'message': 'message',
//               'data': ['string', 'string']
//             }),
//             200));

//         final result = await repo.categories();

//         expect(result, equals(['string', 'string']));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//           Uri.https(host, path, {'categories': 'true'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.categories();

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('find', () {
//       test(test200('recipe'), () async {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jRecipe, 200));

//         final result = await repo.find('string');

//         expect(result, equals(tRecipe));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//           Uri.https(host, '$path/string'),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('finds', () {
//       test(test200('list of recipe'), () async {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'category': 'string'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jRecipeList, 200));

//         final result = await repo.finds(category: 'string');

//         expect(result, equals(tpRecipe));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//           Uri.https(host, path, {'pageNumber': '1', 'pageLimit': '20', 'category': 'string'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.finds(category: 'string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('search', () {
//       test(test200('list of recipe'), () async {
//         when(client.get(
//           Uri.https(host, path, {'search': 'string'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jRecipeList, 200));

//         final result = await repo.search('string');

//         expect(result, equals([tRecipe]));
//       });

//       test(testNot200(400), () {
//         when(client.get(
//           Uri.https(host, path, {'search': 'string'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.search('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
