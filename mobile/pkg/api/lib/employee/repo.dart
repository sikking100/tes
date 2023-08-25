import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

abstract class EmployeeRepo {
  Future<Paging<Employee>> find({int? num = 1, int? limit = 20, String? query, String? search});
  Future<Employee> byId(String id);
  Future<Employee> update({required String id, required ReqEmployee req});

  ///TEAM
  ///
  ///1. FOOD
  ///
  ///2. RETAIL
  Future<List<UserApprover>> approver({required String regionId, required String branchId, required int team});
}

class EmployeeRepoImpl implements EmployeeRepo {
  final Client client;
  final FirebaseAuth auth;

  EmployeeRepoImpl(this.client, this.auth);

  static const path = 'user-employee/v1';

  @override
  Future<Employee> byId(String id) => request<Employee>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Employee.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Employee> update({required String id, required ReqEmployee req}) => request<Employee>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.put(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Employee.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Employee>> find({int? num = 1, int? limit = 20, String? query, String? search}) => request<Paging<Employee>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'query': query, 'search': search}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging<Employee>.fromMap(result.data, Employee.fromMap);
        throw result.toString();
      });

  @override
  Future<List<UserApprover>> approver({required String regionId, required String branchId, required int team}) =>
      request<List<UserApprover>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/approver/top', {'regionId': regionId, 'branchId': branchId, 'team': '$team'}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<UserApprover>.from(result.data.map((e) => UserApprover.fromMap(e)));
        throw result.toString();
      });
}
