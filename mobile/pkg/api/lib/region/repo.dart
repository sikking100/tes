import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class RegionRepo {
  Future<Paging<Region>> find({int? limit = 1, int? num = 20, String? search});
  Future<Region> byId(String id);
}

class RegionRepoImpl implements RegionRepo {
  final Client client;
  final FirebaseAuth auth;

  RegionRepoImpl(this.client, this.auth);

  static const path = 'location-region/v1';

  @override
  Future<Paging<Region>> find({int? limit = 1, int? num = 20, String? search}) => request<Paging<Region>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response =
            await client.get(Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'search': search}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);

        if (result.code == 200) return Paging<Region>.fromMap(result.data, Region.fromMap);
        throw result.toString();
      });

  @override
  Future<Region> byId(String id) => request<Region>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Region.fromMap(result.data);
        throw result.toString();
      });
}
