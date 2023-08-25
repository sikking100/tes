import 'package:api/common.dart';
import 'package:api/price_list/model.dart';
import 'package:http/http.dart' show Client;
import 'package:firebase_auth/firebase_auth.dart';

abstract class PriceRepo {
  Future<PriceList> byId(String id);
  Future<List<PriceList>> find();
}

class PriceRepoImpl implements PriceRepo {
  final Client client;
  final FirebaseAuth auth;

  PriceRepoImpl(this.client, this.auth);

  static const path = 'product-pricelist/v1';

  @override
  Future<PriceList> byId(String id) => request<PriceList>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return PriceList.fromMap(result.data['items']);
        throw result.toString();
      });

  @override
  Future<List<PriceList>> find() => request<List<PriceList>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<PriceList>.from(result.data.map((e) => PriceList.fromMap(e)));
        throw result.toString();
      });
}
