import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ReportRepo {
  Future<Report> create(SaveReport req);
  Future<Paging<Report>> findAll({int? num = 1, int? limit = 20, String? from, String? to});
  Future<Report> find(String id);
  Future<Report> delete(String id);
}

class ReportRepoImpl extends ReportRepo {
  final Client client;
  final FirebaseAuth auth;

  ReportRepoImpl(this.client, this.auth);

  static const path = 'report/v1';

  @override
  Future<Report> create(SaveReport req) => request<Report>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.post(Uri.https(host, path), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Report.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Report> delete(String id) => request<Report>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.delete(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Report.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Report> find(String id) => request<Report>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Report.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Report>> findAll({int? num = 1, int? limit = 20, String? from, String? to}) => request<Paging<Report>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response =
            await client.get(Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'from': from, 'to': to}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging.fromMap(result.data, Report.fromMap);
        throw result.toString();
      });
}
