import 'package:api/activity/new_model.dart';
import 'package:api/common.dart';
import 'package:http/http.dart' show Client;
import 'package:firebase_auth/firebase_auth.dart';

abstract class ActivityRepo {
  Future<Activity> create(ReqActivity req);
  Future<Paging<Activity>> all({int? num = 1, int? limit = 20});
  Future<Activity> byId(String id);
  Future<Activity> update({required String id, required ReqActivity req});
  Future<Activity> delete(String id);

  Future<List<Comment>> comments(String activityId);
  Future<Comment> createComment(ReqComment req);
  Future<Comment> updateComment({required String id, required ReqComment req});
  Future<Comment> deleteComment(String id);
}

class ActivityRepoImpl implements ActivityRepo {
  final Client client;
  final FirebaseAuth auth;

  const ActivityRepoImpl(this.client, this.auth);

  static const act = 'activity/v1';
  static const comment = 'comment/v1';

  @override
  Future<Activity> create(ReqActivity req) => request<Activity>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.post(Uri.https(host, act), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Activity.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Activity> delete(String id) => request<Activity>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.delete(Uri.https(host, '$act/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Activity.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Comment> createComment(ReqComment req) => request<Comment>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.post(
          Uri.https(host, comment),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Comment.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Comment> deleteComment(String id) => request<Comment>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.delete(Uri.https(host, '$comment/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Comment.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Activity> update({required String id, required ReqActivity req}) => request<Activity>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.put(Uri.https(host, '$act/$id'), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Activity.fromMap(result.data);
        throw result.toString();
      });
  @override
  Future<Comment> updateComment({required String id, required ReqComment req}) => request<Comment>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.put(
          Uri.https(host, '$comment/$id'),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Comment.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Activity>> all({int? num = 1, int? limit = 20}) => request<Paging<Activity>>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.get(Uri.https(host, act, {'num': '$num', 'limit': '$limit'}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) {
          return Paging<Activity>.fromMap(result.data, Activity.fromMap);
        }
        throw result.toString();
      });

  @override
  Future<Activity> byId(String id) => request<Activity>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.get(Uri.https(host, '$act/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Activity.fromMap(result.data);
        throw result.toString();
      });
  @override
  Future<List<Comment>> comments(String activityId) => request<List<Comment>>(() async {
        final String? token = await auth.currentUser?.getIdToken();

        final response = await client.get(
          Uri.https(host, comment, {'activityId': activityId}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Comment>.from(result.data.map((e) => Comment.fromMap(e)));
        throw result.toString();
      });
}
