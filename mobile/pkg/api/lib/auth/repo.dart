import 'package:api/auth/model.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';

abstract class AuthRepo {
  Future<String> login(ReqLogin req);
  Future<String> verify(ReqVerify req);
}

class AuthRepoImpl implements AuthRepo {
  static const String path = 'user-auth/v1';
  final Client client;

  AuthRepoImpl(this.client);
  @override
  Future<String> login(ReqLogin req) => request<String>(() async {
        final response = await client.post(Uri.https(host, path), headers: const Headers().toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return result.data;
        throw result.toString();
      });

  @override
  Future<String> verify(ReqVerify req) => request<String>(() async {
        final response = await client.put(Uri.https(host, path), headers: const Headers().toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return result.data;
        throw result.toString();
      });
}
