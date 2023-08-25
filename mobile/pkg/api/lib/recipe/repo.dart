import 'package:api/common.dart';
import 'package:api/recipe/model.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class RecipeRepo {
  Future<Paging<Recipe>> finds({int? num = 1, int? limit = 20, String? category});
  Future<List<String>> categories();
  Future<Recipe> find(String id);
  Future<List<Recipe>> search(String query);
}

class RecipeRepoImpl implements RecipeRepo {
  final Client client;
  final FirebaseAuth auth;

  RecipeRepoImpl(this.client, this.auth);

  static const path = 'recipe/v1/recipe';

  @override
  Future<List<String>> categories() => request<List<String>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'num': '1', 'limit': '1', 'categories': 'true'}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return (result.data as List).map((e) => e.toString()).toList();
        throw result.toString();
      });

  @override
  Future<Recipe> find(String id) => request<Recipe>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Recipe.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Recipe>> finds({int? num = 1, int? limit = 20, String? category}) => request<Paging<Recipe>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response =
            await client.get(Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'category': category}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging<Recipe>.fromMap(result.data, Recipe.fromMap);
        throw result.toString();
      });

  @override
  Future<List<Recipe>> search(String query) => request<List<Recipe>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'num': '1', 'limit': '1', 'search': query}), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List.from(result.data['items']).map((e) => Recipe.fromMap(e)).toList();
        throw result.toString();
      });
}
