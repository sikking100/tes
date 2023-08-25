import 'package:api/banner/new_model.dart';
import 'package:api/common.dart';
import 'package:http/http.dart' show Client;
import 'package:firebase_auth/firebase_auth.dart';

abstract class BannerRepo {
  Future<List<Banner>> findExternal();
  Future<List<Banner>> findInternal();
}

class BannerRepoImpl implements BannerRepo {
  final Client client;
  final FirebaseAuth auth;

  BannerRepoImpl(this.client, this.auth);

  static const path = 'banner/v1';

  @override
  Future<List<Banner>> findExternal() => request<List<Banner>>(() async {
        String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'type': '${BannerType.external}'}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Banner>.from(result.data.map((e) => Banner.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<List<Banner>> findInternal() => request<List<Banner>>(() async {
        String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'type': '${BannerType.internal}'}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Banner>.from(result.data.map((e) => Banner.fromMap(e)));
        throw result.toString();
      });
}
