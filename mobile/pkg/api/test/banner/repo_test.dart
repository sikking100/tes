// import 'dart:convert';

// import 'package:api/api.dart';
// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart';

// import '../api_test.dart';
// import '../api_test.mocks.dart';
// import 'model_test.dart';

// void main() {
//   late MockClient client;
//   late BannerRepo repo;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = BannerRepoImpl(client, auth);
//   });

//   const String path = 'banner/api/v1';

//   group('Banner repository', () {
//     group('find External', () {
//       test('should return list of banner when the result code is 200', () async {
//         when(client.get(Uri.https(host, path, {'type': BannerType.external}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jBanner, 200));

//         final result = await repo.findExternal();

//         expect(result, equals([tBanner]));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'type': BannerType.external}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.findExternal();

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('find Internal', () {
//       test('should return list of banner when the result code is 200', () async {
//         when(client.get(Uri.https(host, path, {'type': BannerType.internal}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jBanner, 200));

//         final result = await repo.findInternal();

//         expect(result, equals([tBanner]));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'type': BannerType.internal}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.findInternal();

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
