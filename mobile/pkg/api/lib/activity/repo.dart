// import 'dart:convert';

// import 'package:api/api.dart';
// import 'package:api/common.dart';
// import 'package:http/http.dart' show Client;
// import 'package:firebase_auth/firebase_auth.dart';

// abstract class ActivityRepo {
//   Future<Activity> create(ActivitySave save);
//   Future<Paging<Activity>> findAll({int? pageNumber = 1, int? pageLimit = 20});
//   Future<Activity> find(String id);
//   Future<Activity> delete(String id);
//   Future<Paging<Comment>> findComment({required String activityId, int? pageNumber = 1, int? pageLimit = 20});
//   Future<Comment> createComment(SaveComment req);
//   Future<Comment> deleteComment({required String activityId, required String commentId});
//   Future<int> count(String activityId);
// }

// class ActivityRepoImpl implements ActivityRepo {
//   final Client client;
//   final FirebaseAuth auth;

//   const ActivityRepoImpl(this.client, this.auth);

//   static const path = 'activity/v1';

//   @override
//   Future<Activity> create(ActivitySave save) => request<Activity>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response = await client.post(Uri.https(host, '$path/activity'), headers: Headers(token).toMapWithReq(), body: jsonEncode(save.toMap()));
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return Activity.fromMap(result.data);
//         throw result.toString();
//       });

//   @override
//   Future<Activity> delete(String id) => request<Activity>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response = await client.delete(Uri.https(host, '$path/activity/$id'), headers: Headers(token).toMap());
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return Activity.fromMap(result.data);
//         throw result.toString();
//       });

//   @override
//   Future<Activity> find(String id) => request<Activity>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response = await client.get(Uri.https(host, '$path/activity/$id'), headers: Headers(token).toMap());
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return Activity.fromMap(result.data);
//         throw result.toString();
//       });

//   @override
//   Future<Paging<Activity>> findAll({int? pageNumber = 1, int? pageLimit = 20}) => request<Paging<Activity>>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response = await client.get(Uri.https(host, '$path/activity', {'pageNumber': '$pageNumber', 'pageLimit': '$pageLimit'}),
//             headers: Headers(token).toMap());
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) {
//           return Paging<Activity>.fromMap(result.data, Activity.fromMap);
//         }
//         throw result.toString();
//       });

//   @override
//   Future<Paging<Comment>> findComment({required String activityId, int? pageNumber = 1, int? pageLimit = 20}) => request<Paging<Comment>>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response = await client.get(
//           Uri.https(host, '$path/comment', {'pageNumber': '$pageNumber', 'pageLimit': '$pageLimit', 'activityId': activityId}),
//           headers: Headers(token).toMap(),
//         );
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return Paging<Comment>.fromMap(result.data, Comment.fromMap);
//         throw result.toString();
//       });

//   @override
//   Future<Comment> createComment(SaveComment req) => request<Comment>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response = await client.post(
//           Uri.https(host, '$path/comment'),
//           headers: Headers(token).toMapWithReq(),
//           body: jsonEncode(req.toMap()),
//         );
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return Comment.fromMap(result.data);
//         throw result.toString();
//       });

//   @override
//   Future<Comment> deleteComment({required String activityId, required String commentId}) => request<Comment>(() async {
//         final String? token = await auth.currentUser?.getIdToken();

//         final response =
//             await client.delete(Uri.https(host, '$path/comment/$commentId', {'activity-id': activityId}), headers: Headers(token).toMap());
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return Comment.fromMap(result.data);
//         throw result.toString();
//       });

//   @override
//   Future<int> count(String activityId) => request<int>(() async {
//         final String? token = await auth.currentUser?.getIdToken();
//         final response = await client.get(Uri.https(host, '$path/count/$activityId'), headers: Headers(token).toMap());
//         final result = Responses.fromJson(response.body, response.request);
//         if (result.code == 200) return result.data;
//         throw result.toString();
//       });
// }
