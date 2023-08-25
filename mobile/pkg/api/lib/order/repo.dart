import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OrderRepo {
  ///All User
  ///
  ///Find order
  ///
  ///query = userid,regionid,branchid,code,status
  ///
  ///Status
  ///
  ///0.APPLY
  ///
  ///1.PENDING
  ///
  ///2.COMPLETE
  ///
  ///3.CANCEL
  Future<Paging<Order>> find({int? num = 1, int? limit = 20, String? query});

  ///All User
  ///
  ///Create order
  Future<Order> create(CreateOrder req);

  ///All User
  ///
  ///Find order by id
  Future<Order> byId(String id);

  ///Leader
  ///
  ///Performance
  Future<List<Performance>> performance({required DateTime startAt, required DateTime endAt, required int team, String? query});

  ///All user
  ///
  ///Transaction Last Month
  Future<double> lastMonth(String customerId);

  ///All user
  ///
  ///Transaction Per Month
  Future<double> perMonth(String customerId);
}

abstract class OrderApplyRepo {
  ///Leader
  ///
  ///0.WAITING APPROVE
  ///
  ///1.HISTORY
  ///
  Future<List<OrderApply>> find(int type);
  Future<OrderApply> byId(String id);
  Future<OrderApply> approve({required String id, required Approval req});
  Future<OrderApply> reject({required String id, required Approval req});
}

class OrderRepoImpl implements OrderRepo {
  final Client client;
  final FirebaseAuth auth;

  OrderRepoImpl(this.client, this.auth);

  static const path = 'order/v1';

  @override
  Future<Order> byId(String id) => request<Order>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Order.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Order> create(CreateOrder req) => request<Order>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.post(
          Uri.https(host, path),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Order.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Paging<Order>> find({int? num = 1, int? limit = 20, String? query}) => request(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'query': query}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging<Order>.fromMap(result.data, Order.fromMap);
        throw result.toString();
      });

  @override
  Future<List<Performance>> performance({required DateTime startAt, required DateTime endAt, required int team, String? query}) =>
      request<List<Performance>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final req = {
          'startAt': DateTime(startAt.year, startAt.month, startAt.day + 1, 0).toUtc().toIso8601String(),
          'endAt': DateTime(endAt.year, endAt.month, endAt.day + 1, 0).toUtc().toIso8601String(),
          "team": '$team',
          "query": query
        };
        final response = await client.get(
          Uri.https(host, '$path/find/performance', req),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Performance>.from(result.data.map((e) => Performance.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<double> lastMonth(String customerId) => request<double>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(
            host,
            '$path/transaction/last-month',
            {"customerId": customerId},
          ),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return doubleParse(result.data) ?? 0.0;
        throw result.toString();
      });

  @override
  Future<double> perMonth(String customerId) => request<double>(() async {
        final token = await auth.currentUser?.getIdToken();

        final response = await client.get(
          Uri.https(
            host,
            '$path/transaction/per-month',
            {"customerId": customerId},
          ),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return doubleParse(result.data) ?? 0.0;
        throw result.toString();
      });
}

class OrderApplyRepoImpl implements OrderApplyRepo {
  final Client client;
  final FirebaseAuth auth;

  OrderApplyRepoImpl(this.client, this.auth);

  static const path = 'order-apply/v1';

  @override
  Future<OrderApply> byId(String id) => request<OrderApply>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return OrderApply.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<OrderApply> approve({required String id, required Approval req}) => request<OrderApply>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.put(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return OrderApply.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<OrderApply> reject({required String id, required Approval req}) => request<OrderApply>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.patch(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return OrderApply.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<List<OrderApply>> find(int type) => request<List<OrderApply>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path, {'type': '$type'}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<OrderApply>.from(result.data.map((e) => OrderApply.fromMap(e)));
        throw result.toString();
      });
}
