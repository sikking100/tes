// import 'dart:convert';

// import 'package:api/common.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart' show Response;

// import '../api_test.dart';
// import '../api_test.mocks.dart';

// void main() {
//   late ActivityRepo repo;
//   late MockClient client;
//   late MockAuth auth;
//   setUp(() {
//     client = MockClient();
//     auth = MockAuth();
//     repo = ActivityRepoImpl(client, auth);
//   });

//   group('Activity repository', () {
//     group('create', () {
//       const path = 'activity/api/v1/activity';

//       test('should return activity when the result code is 200', () async {
//         when(client.post(
//           Uri.https(host, path),
//           headers: const Headers('customer').toMapWithReq(),
//           body: jsonEncode(tActivitySave.toMap()),
//         )).thenAnswer((_) async => Response(jActivity, 200));

//         final result = await repo.create(tActivitySave);

//         expect(result, tActivity);
//       });

//       test(testNot200(400), () {
//         when(client.post(
//           Uri.https(host, path),
//           headers: const Headers('customer').toMapWithReq(),
//           body: jsonEncode(tActivitySave.toMap()),
//         )).thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.create(tActivitySave);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('delete', () {
//       const id = 'query';

//       const path = 'activity/api/v1/activity/$id';
//       test('should return activity', () async {
//         when(client.delete(Uri.https(host, path), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(jActivity, 200));

//         final result = await repo.delete(id);

//         expect(result, tActivity);
//       });

//       test(testNot200(400), () {
//         when(client.delete(Uri.https(host, path), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.delete(id);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('find', () {
//       const id = 'query';
//       const path = 'activity/api/v1/activity/$id';
//       test('should return activity', () async {
//         when(client.get(Uri.https(host, path), headers: const Headers('customer').toMap())).thenAnswer((_) async => Response(jActivity, 200));

//         final result = await repo.find(id);

//         expect(result, tActivity);
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.find(id);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('finds', () {
//       const path = 'activity/api/v1/activity';

//       test('should return paging activity', () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jpActivity, 200));

//         final result = await repo.findAll(pageLimit: 0, pageNumber: 0);

//         expect(result, tpActivity);
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0'}), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.findAll(pageLimit: 0, pageNumber: 0);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('count', () {
//       const path = 'activity/api/v1';

//       test('should return int', () async {
//         when(client.get(Uri.https(host, '$path/count/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode({"code": 200, "message": "ok", "data": 0}), 200));

//         final result = await repo.count('string');

//         expect(result, equals(0));
//       });

//       test(testNot200(400), () {
//         when(client.get(Uri.https(host, '$path/count/string'), headers: const Headers('customer').toMap()))
//             .thenAnswer((_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400));

//         final result = repo.count('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });

//   group('Comment Repository', () {
//     const String actId = 'string';
//     const String comId = 'string';

//     group('findComment', () {
//       const path = 'activity/api/v1/comment';

//       test('should return paging comment', () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'activityId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer(
//           (_) async => Response(jpComment, 200),
//         );

//         final result = await repo.findComment(activityId: actId, pageLimit: 0, pageNumber: 0);

//         expect(result, equals(tpComment));
//       });

//       test('should throw string error', () async {
//         when(client.get(Uri.https(host, path, {'pageNumber': '0', 'pageLimit': '0', 'activityId': 'string'}),
//                 headers: const Headers('customer').toMap()))
//             .thenAnswer(
//           (_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400),
//         );

//         final result = repo.findComment(activityId: actId, pageLimit: 0, pageNumber: 0);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('createComment', () {
//       const path = 'activity/api/v1/comment';

//       test('should return comment', () async {
//         when(client.post(
//           Uri.https(host, path),
//           headers: const Headers('customer').toMapWithReq(),
//           body: jsonEncode(tSaveComment.toMap()),
//         )).thenAnswer(
//           (_) async => Response(jComment, 200),
//         );

//         final result = await repo.createComment(tSaveComment);

//         expect(result, equals(tComment));
//       });

//       test('should throw string error', () async {
//         when(client.post(Uri.https(host, path), headers: const Headers('customer').toMapWithReq(), body: jsonEncode(tSaveComment.toMap())))
//             .thenAnswer(
//           (_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400),
//         );

//         final result = repo.createComment(tSaveComment);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('deleteComment', () {
//       const path = 'activity/api/v1/comment';

//       test('should return comment', () async {
//         when(client.delete(
//           Uri.https(host, '$path/$comId', {'activity-id': 'string'}),
//           headers: const Headers('customer').toMap(),
//         )).thenAnswer(
//           (_) async => Response(jComment, 200),
//         );

//         final result = await repo.deleteComment(activityId: actId, commentId: comId);

//         expect(result, equals(tComment));
//       });

//       test('should throw string error', () async {
//         when(client.delete(Uri.https(host, '$path/$comId', {'activity-id': 'string'}), headers: const Headers('customer').toMap())).thenAnswer(
//           (_) async => Response(jsonEncode(jsonError..addAll({'code': 400})), 400),
//         );

//         final result = repo.deleteComment(activityId: actId, commentId: comId);

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
