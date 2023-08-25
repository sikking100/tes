import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryRepo {
  ///All user
  ///find delivery
  ///
  ///0.Apply
  ///
  ///1.PENDING
  ///
  ///2.create packing list
  ///
  ///3.add courier
  ///
  ///4.picked up
  ///
  ///5.loaded
  ///
  ///6.wait deliver
  ///
  ///7.deliver
  ///
  ///8.restock
  ///
  ///9.complete
  ///
  ///10.cancel
  Future<Paging<Delivery>> find({int? num = 1, int? limit = 20, required int status});

  ///All user
  ///find delivery by id
  ///
  Future<Delivery> byId(String id);

  ///All user
  ///find list delivery by order id
  ///
  Future<List<Delivery>> byOrder(String id);

  ///Courier
  ///update status to deliver
  ///
  ///Id delivery
  Future<Delivery> deliver(String id);

  ///Courier
  ///complete packing list
  ///Id delivery
  Future<Delivery> complete({required String id, required Complete req});

  ///Courier
  ///find packing list courier
  ///
  ///0.Apply
  ///
  ///1.PENDING
  ///
  ///2.create packing list
  ///
  ///3.add courier
  ///
  ///4.picked up
  ///
  ///5.loaded
  ///
  ///6. wait deliver
  ///
  ///7.deliver
  ///
  ///8.restock
  ///
  ///9.complete
  ///
  ///10.cancel
  Future<List<PackingListCourier>> packingListCourier(int status);

  ///Courier
  ///find packing list destination
  ///
  Future<List<PackingDestination>> packingListDestination();

  ///Courier
  ///loaded product inside packing list
  ///one by one
  ///Id delivery
  Future<Loaded> loaded(Loaded req);

  ///Courier
  ///find packing list courier
  ///
  ///0.Apply
  ///
  ///1.PENDING
  ///
  ///2.create packing list
  ///
  ///3.add courier
  ///
  ///4.picked up
  ///
  ///5.loaded
  ///
  ///6. wait deliver
  ///
  ///7.deliver
  ///
  ///8.restock
  ///
  ///9.complete
  ///
  ///10.cancel
  Future<List<DeliveryProduct>> productByStatus(int status);

  ///All user
  ///get delivery price
  Future<double> gosendPrice({required double oriLat, required double oriLng, required double desLat, required double desLng});
}

class DeliveryRepoImpl implements DeliveryRepo {
  final Client client;
  final FirebaseAuth auth;

  DeliveryRepoImpl(this.client, this.auth);

  static const String path = 'delivery/v1';

  @override
  Future<double> gosendPrice({required double oriLat, required double oriLng, required double desLat, required double desLng}) =>
      request<double>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(
              host, '$path/gosend/price', {'originLat': '$oriLat', 'originLng': '$oriLng', 'destinationLat': '$desLat', 'destinationLng': '$desLng'}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return doubleParse(result.data) ?? 0.0;
        throw result.toString();
      });

  @override
  Future<List<PackingListCourier>> packingListCourier(int status) => request<List<PackingListCourier>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final courierId = auth.currentUser?.uid;
        final response = await client.get(
          Uri.https(host, '$path/paking-list/courier', {'courierId': courierId, 'status': '$status'}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<PackingListCourier>.from(result.data.map((e) => PackingListCourier.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<List<PackingDestination>> packingListDestination() => request<List<PackingDestination>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final courierId = auth.currentUser?.uid;
        final response = await client.get(
          Uri.https(host, '$path/paking-list/destination', {'courierId': courierId}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<PackingDestination>.from(result.data.map((e) => PackingDestination.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<Delivery> byId(String id) => request<Delivery>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Delivery.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<List<Delivery>> byOrder(String id) => request<List<Delivery>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.get(
          Uri.https(host, '$path/$id/by-order'),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<Delivery>.from(result.data.map((e) => Delivery.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<Delivery> complete({required String id, required Complete req}) => request<Delivery>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.put(
          Uri.https(host, '$path/$id/complete'),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Delivery.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<Loaded> loaded(Loaded req) => request<Loaded>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.put(
          Uri.https(host, '$path/paking-list/loaded'),
          headers: Headers(token).toMapWithReq(),
          body: req.toJson(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Loaded.fromMap(result.data);
        throw result.toString();
      });

  @override
  Future<List<DeliveryProduct>> productByStatus(int status) => request<List<DeliveryProduct>>(() async {
        final token = await auth.currentUser?.getIdToken();
        final courierId = auth.currentUser?.uid;
        final response = await client.get(
          Uri.https(host, '$path/product/find', {'courierId': courierId, 'status': '$status'}),
          headers: Headers(token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return List<DeliveryProduct>.from(result.data.map((e) => DeliveryProduct.fromMap(e)));
        throw result.toString();
      });

  @override
  Future<Paging<Delivery>> find({int? num = 1, int? limit = 20, required int status}) => request<Paging<Delivery>>(() async {
        final token = await auth.currentUser?.getIdTokenResult();
        final courierId = auth.currentUser?.uid;
        final branchId = token?.claims?['locationId'];
        final response = await client.get(
          Uri.https(host, path, {'num': '$num', 'limit': '$limit', 'branchId': branchId, 'courierId': courierId, 'status': '$status'}),
          headers: Headers(token?.token).toMap(),
        );
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Paging.fromMap(result.data, Delivery.fromMap);
        throw result.toString();
      });

  @override
  Future<Delivery> deliver(String id) => request<Delivery>(() async {
        final token = await auth.currentUser?.getIdToken();
        final response = await client.put(Uri.https(host, '$path/$id/deliver'), headers: Headers(token).toMap());
        final result = Responses.fromJson(response.body, response.request);
        if (result.code == 200) return Delivery.fromMap(result.data);
        throw result.toString();
      });
}
