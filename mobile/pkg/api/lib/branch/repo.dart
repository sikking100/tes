import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart' show Client;
import 'package:firebase_auth/firebase_auth.dart';

abstract class BranchRepo {
  Future<Paging<Branch>> find({int? limit = 20, int? num = 1, String? regionId, String? search});
  Future<Branch> near({required double lng, required double lat});
  Future<Branch> byId(String id);
}

class BranchRepoImpl implements BranchRepo {
  final Client client;
  final FirebaseAuth auth;

  BranchRepoImpl(this.client, this.auth);

  static const path = 'location-branch/v1';

  @override
  Future<Branch> byId(String id) => request<Branch>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Branch.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Branch>> find({int? limit = 20, int? num = 1, String? regionId, String? search}) => request<Paging<Branch>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'regionId': regionId, 'search': search}),
            headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging<Branch>.fromMap(result.data, Branch.fromMap);
        throw result.toString();
      });

  @override
  Future<Branch> near({required double lng, required double lat}) => request<Branch>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/find/near', {'lng': '$lng', 'lat': '$lat'}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Branch.fromMap(result.data);
        throw result.toString();
      });
}
