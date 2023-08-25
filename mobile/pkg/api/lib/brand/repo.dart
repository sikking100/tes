import 'package:api/brand/model.dart';
import 'package:api/common.dart';
import 'package:http/http.dart' show Client;
import 'package:firebase_auth/firebase_auth.dart';

abstract class BrandRepo {
  Future<List<Brand>> all();
  // Future<Brand> find(String id);
}

class BrandhRepoImpl implements BrandRepo {
  final Client client;
  final FirebaseAuth auth;

  const BrandhRepoImpl(this.client, this.auth);

  static const path = 'brand/v1';

  // @override
  // Future<Brand> find(String id) async {
  //   // final token = await auth.currentUser?.getIdToken();
  //   final response = await client.get(Uri.https(host, '$path/$id'), headers: const Headers().toJson());
  //   final result = Responses.fromJson(jsonDecode(response.body));
  //   if (result.code == 200) return Brand.fromMap(result.data);
  //   throw result.toString();
  // }

  @override
  Future<List<Brand>> all() => request<List<Brand>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Brand>.from(result.data.map((e) => Brand.fromMap(e)));
        throw result.toString();
      });
}
