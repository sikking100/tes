import 'package:api/common.dart';
import 'package:api/invoice/model.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class InvoiceRepo {
  ///All user
  ///find invoice
  ///
  ///type
  ///0.WAITING PAY\n
  ///1.OVERDUE\n
  ///2.HISTORY\n
  ///
  ///query
  ///userid,branchid,regionid,paymentMethod
  Future<Paging<Invoice>> find({int? num = 1, int? limit = 20, int? type, String? query});

  ///All User
  ///find by id
  Future<Invoice> byId(String id);

  ///Customer
  ///make payment
  ///for transfer and top only
  Future<Invoice> create(String id);

  ///All User
  ///find invoice by orderId
  Future<List<Invoice>> byOrder(String id);
}

class InvoiceRepoImpl implements InvoiceRepo {
  final Client client;
  final FirebaseAuth auth;

  InvoiceRepoImpl(this.client, this.auth);

  static const String path = 'invoice/v1';

  @override
  Future<Invoice> create(String idOrder) => request<Invoice>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.post(
          Uri.https(host, '$path/$idOrder/make-payment'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Invoice.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Invoice> byId(String id) => request<Invoice>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Invoice.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<List<Invoice>> byOrder(String id) => request<List<Invoice>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id/by-order'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Invoice>.from(result.data.map((e) => Invoice.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<Paging<Invoice>> find({int? num = 1, int? limit = 20, int? type, String? query}) => request<Paging<Invoice>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'type': '$type', 'query': query}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging<Invoice>.fromMap(result.data, Invoice.fromMap);
        throw result.toString();
      });
}
