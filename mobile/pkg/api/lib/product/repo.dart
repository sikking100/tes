import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProductRepo {
  ///query
  ///
  ///branchId,brandId,categoryId,team,salesId
  ///
  ///sort
  ///
  ///1 order count
  ///2 discount
  ///
  ///qtype
  ///
  ///1 by search
  ///2 by brand
  ///3 by category
  Future<Paging<Product>> find({
    int? num = 1,
    int? limit = 20,

    ///query
    ///
    ///branchId,brandId,categoryId,team,salesId
    required String query,

    ///sort
    ///
    ///1 order count
    ///2 discount
    int? sort,
    String? search,
  });
  Future<Product> byId(String id);
}

class ProductRepoImpl implements ProductRepo {
  final Client client;
  final FirebaseAuth auth;

  ProductRepoImpl(this.client, this.auth);

  static const path = 'product-branch/v1';

  @override
  Future<Product> byId(String id) => request<Product>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Product.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Product>> find({
    int? num = 1,
    int? limit = 20,

    ///query
    ///
    ///branchId,brandId,categoryId,team,salesId
    required String query,
    int? sort,

    ///qtype
    ///
    ///1 by search
    ///2 by brand
    ///3 by category

    String? search,
  }) =>
      request<Paging<Product>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
            Uri.https(host, path, {
              'num': '$num',
              'limit': '$limit',
              'query': query,
              if (sort != null) 'sort': '$sort',
              if (search != null) 'search': search,
            }),
            headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Paging<Product>.fromMap(result.data, Product.fromMap);
        throw result.toString();
      });
}
