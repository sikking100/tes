import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

abstract class CustomerRepo {
  ///employee
  ///ambil business
  Future<Paging<Customer>> find({int? num = 1, int? limit = 20, String? query, String? search});

  ///customer
  ///register customer
  Future<Customer> create(ReqCustomer req);

  ///employee
  ///find customer by phone and create if not exists
  Future<Customer> createByEmployee(ReqCustomer req);

  ///all user
  ///mengambil business berdasarkan id
  Future<Customer> byId(String id);

  ///customer
  ///update akun customer
  Future<Customer> update(ReqCustomer req);

  ///customer
  ///update bisnis
  Future<Customer> updateBusiness({required String id, required UpdateBusiness req});
}

abstract class ApplyRepo {
  ///employee
  /// 0 ALL
  /// 1 WAITING LIMIT
  /// 2 WAITING APPROVE
  Future<Paging<Apply>> find({int? num = 1, int? limit = 20, required String userId, int? type = 0});

  ///all user
  ///get pengajuan bisnis by id
  Future<Apply> byId(String id);

  ///all user
  ///buat bisnis
  Future<Apply> create(ReqApply req);

  ///leader
  Future<Apply> approve(ReqApproval req);

  ///leader
  Future<Apply> reject(ReqApproval req);
}

class CustomerRepoImpl implements CustomerRepo {
  final Client client;
  final FirebaseAuth auth;

  static const String path = 'user-customer/v1';
  CustomerRepoImpl(this.client, this.auth);

  @override
  Future<Customer> byId(String id) => request<Customer>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Customer.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Customer> create(ReqCustomer req) => request<Customer>(() async {
        final response = await client.post(Uri.https(host, path), headers: const Headers().toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Customer.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Customer>> find({int? num = 1, int? limit = 20, String? query, String? search}) => request<Paging<Customer>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'query': query, 'search': search}),
            headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Paging<Customer>.fromMap(result.data, Customer.fromMap);
        throw result.toString();
      });

  @override
  Future<Customer> update(ReqCustomer req) => request<Customer>(() async {
        final token = await auth.currentUser?.getIdToken();
        final String? id = auth.currentUser?.uid;
        final response = await client.put(Uri.https(host, '$path/$id'), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Customer.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Customer> createByEmployee(ReqCustomer req) => request<Customer>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.put(Uri.https(host, path), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Customer.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Customer> updateBusiness({required String id, required UpdateBusiness req}) => request<Customer>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.patch(Uri.https(host, '$path/$id'), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body);
        if (result.code == 200) return Customer.fromMap(result.data);
        throw result.toString();
      });
}

class ApplyRepoImpl implements ApplyRepo {
  final Client client;
  final FirebaseAuth auth;

  static const String path = 'user-customer-apply/v1';

  ApplyRepoImpl(this.client, this.auth);
  @override
  Future<Apply> approve(ReqApproval req) => request<Apply>(() async {
        final token = await auth.currentUser?.getIdToken();

        final response = await client.post(Uri.https(host, '$path/approve'), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Apply.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Apply> byId(String id) => request<Apply>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, '$path/$id'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 404) return const Apply();
        if (result.code == 200) return Apply.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Apply> create(ReqApply req) => request<Apply>(() async {
        final token = await auth.currentUser?.getIdToken();

        final response = await client.post(Uri.https(host, '$path/new-business'), headers: Headers(token).toMapWithReq(), body: req.toJson());
        final result = Responses.fromJson(response.body, response.request);

        if (result.code == 200) return Apply.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Apply>> find({int? num = 1, int? limit = 20, required String userId, int? type = 0}) => request<Paging<Apply>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'userId': userId, 'type': '$type'}),
            headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging<Apply>.fromMap(result.data, Apply.fromMap);
        throw result.toString();
      });

  @override
  Future<Apply> reject(ReqApproval req) => request<Apply>(() async {
        final token = await auth.currentUser?.getIdToken();

        final response = await client.post(Uri.https(host, '$path/reject'), headers: Headers(token).toMapWithReq(), body: req.toJson(false));
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Apply.fromMap(result.data);
        throw result.toString();
      });
}
