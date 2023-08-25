import 'package:api/category/model.dart';
import 'package:api/common.dart';
import 'package:http/http.dart' show Client;

import 'package:firebase_auth/firebase_auth.dart';

abstract class CategoryRepo {
  Future<List<Category>> all();
  Future<Category> byId(String id);
}

class CategoryRepoImpl implements CategoryRepo {
  final Client client;
  final FirebaseAuth auth;

  CategoryRepoImpl(this.client, this.auth);

  static const path = 'category/v1';

  @override
  Future<Category> byId(String id) => request<Category>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Category.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<List<Category>> all() => request<List<Category>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Category>.from(result.data.map((e) => Category.fromMap(e)));
        throw result.toString();
      });
}
