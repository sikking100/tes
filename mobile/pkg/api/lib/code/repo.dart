import 'package:api/code/model.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class CodeRepo {
  Future<List<Code>> find();
  Future<Code> byId(String id);
}

class CodeRepoImpl implements CodeRepo {
  final Client client;
  final FirebaseAuth auth;

  CodeRepoImpl(this.client, this.auth);

  static const path = 'code/v1';

  @override
  Future<Code> byId(String id) => request<Code>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Code.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<List<Code>> find() => request<List<Code>>(() async {
        final String? token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Code>.from(result.data.map((e) => Code.fromMap(e)));
        throw result.toString();
      });
}
