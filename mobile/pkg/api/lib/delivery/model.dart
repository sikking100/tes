// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:api/common.dart';
import 'package:equatable/equatable.dart';

class PackingListCourier extends Equatable {
  const PackingListCourier({
    this.warehouse,
    required this.product,
  });

  final Warehouse? warehouse;
  final List<DeliveryProduct> product;

  PackingListCourier copyWith({
    Warehouse? warehouse,
    List<DeliveryProduct>? product,
  }) {
    return PackingListCourier(
      warehouse: warehouse ?? this.warehouse,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'warehouse': warehouse?.toMap(),
      'product': product.map((x) => x.toMap()).toList(),
    };
  }

  factory PackingListCourier.fromMap(Map<String, dynamic> map) {
    return PackingListCourier(
      warehouse: map['warehouse'] == null ? null : Warehouse.fromMap(map['warehouse'] as Map<String, dynamic>),
      product: List<DeliveryProduct>.from(
        (map['product'] as List<dynamic>).map<DeliveryProduct>(
          (x) => DeliveryProduct.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PackingListCourier.fromJson(String source) => PackingListCourier.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [warehouse, product];
}

class PackingDestination extends Equatable {
  const PackingDestination({
    required this.orderId,
    required this.deliveryId,
    required this.customer,
  });

  final String orderId;
  final String deliveryId;
  final DeliveryCustomer customer;

  PackingDestination copyWith({
    String? orderId,
    String? deliveryId,
    DeliveryCustomer? customer,
  }) {
    return PackingDestination(
      orderId: orderId ?? this.orderId,
      deliveryId: deliveryId ?? this.deliveryId,
      customer: customer ?? this.customer,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'deliveryId': deliveryId,
      'customer': customer.toMap(),
    };
  }

  factory PackingDestination.fromMap(Map<String, dynamic> map) {
    return PackingDestination(
      orderId: map['orderId'] as String,
      deliveryId: map['deliveryId'] as String,
      customer: DeliveryCustomer.fromMap(map['customer'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory PackingDestination.fromJson(String source) => PackingDestination.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [orderId, deliveryId, customer];
}

class DeliveryCustomer extends Equatable {
  const DeliveryCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressName,
    required this.addressLngLat,
  });

  final String id;
  final String name;
  final String phone;
  final String addressName;
  final List<double> addressLngLat;

  double get lat => addressLngLat.last;
  double get lng => addressLngLat.first;

  DeliveryCustomer copyWith({
    String? id,
    String? name,
    String? phone,
    String? picName,
    String? picPhone,
    String? addressName,
    List<double>? addressLngLat,
  }) {
    return DeliveryCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addressName: addressName ?? this.addressName,
      addressLngLat: addressLngLat ?? this.addressLngLat,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'addressName': addressName,
      'addressLngLat': addressLngLat,
    };
  }

  factory DeliveryCustomer.fromMap(Map<String, dynamic> map) {
    return DeliveryCustomer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      addressName: map['addressName'] as String,
      addressLngLat: List<double>.from(
        (map['addressLngLat'] as List<dynamic>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliveryCustomer.fromJson(String source) => DeliveryCustomer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      phone,
      addressName,
      addressLngLat,
    ];
  }
}

class Delivery extends Equatable {
  const Delivery({
    required this.id,
    required this.orderId,
    required this.transactionId,
    required this.regionId,
    required this.regionName,
    required this.branchId,
    required this.branchName,
    required this.customer,
    required this.courier,
    required this.courierType,
    required this.url,
    required this.product,
    required this.note,
    required this.price,
    required this.status,
    required this.deliveryAt,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String transactionId;
  final String regionId;
  final String regionName;
  final String branchId;
  final String branchName;
  final DeliveryCustomer customer;
  final Courier? courier;
  final int courierType;
  final String url;
  final List<DeliveryProduct> product;
  final String note;
  final double price;

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
  final int status;
  final DateTime deliveryAt;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'orderId': orderId,
      'transactionId': transactionId,
      'regionId': regionId,
      'regionName': regionName,
      'branchId': branchId,
      'branchName': branchName,
      'customer': customer.toMap(),
      'courier': courier?.toMap(),
      'courierType': courierType,
      'url': url,
      'product': product.map((x) => x.toMap()).toList(),
      'note': note,
      'price': price,
      'status': status,
      'deliveryAt': deliveryAt.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      transactionId: map['transactionId'] as String,
      regionId: map['regionId'] as String,
      regionName: map['regionName'] as String,
      branchId: map['branchId'] as String,
      branchName: map['branchName'] as String,
      customer: DeliveryCustomer.fromMap(map['customer'] as Map<String, dynamic>),
      courier: map['courier'] != null ? Courier.fromMap(map['courier'] as Map<String, dynamic>) : null,
      courierType: map['courierType'] as int,
      url: map['url'] as String,
      product: List<DeliveryProduct>.from(
        (map['product'] as List<dynamic>).map<DeliveryProduct>(
          (x) => DeliveryProduct.fromMap(x as Map<String, dynamic>),
        ),
      ),
      note: map['note'] as String,
      price: doubleParse(map['price']) ?? 0.0,
      status: map['status'] as int,
      deliveryAt: DateTime.parse(map['deliveryAt']).toLocal(),
      createdAt: DateTime.parse(map['createdAt']).toLocal(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Delivery.fromJson(String source) => Delivery.fromMap(json.decode(source) as Map<String, dynamic>);

  Delivery copyWith({
    String? id,
    String? orderId,
    String? transactionId,
    String? regionId,
    String? regionName,
    String? branchId,
    String? branchName,
    DeliveryCustomer? customer,
    Courier? courier,
    int? courierType,
    String? url,
    List<DeliveryProduct>? product,
    String? note,
    double? price,
    int? status,
    DateTime? deliveryAt,
    DateTime? createdAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      transactionId: transactionId ?? this.transactionId,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      customer: customer ?? this.customer,
      courier: courier ?? this.courier,
      courierType: courierType ?? this.courierType,
      url: url ?? this.url,
      product: product ?? this.product,
      note: note ?? this.note,
      price: price ?? this.price,
      status: status ?? this.status,
      deliveryAt: deliveryAt ?? this.deliveryAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      orderId,
      transactionId,
      regionId,
      regionName,
      branchId,
      branchName,
      customer,
      courier,
      courierType,
      url,
      product,
      note,
      price,
      status,
      deliveryAt,
      createdAt,
    ];
  }
}

class Courier extends Equatable {
  const Courier({
    required this.id,
    required this.name,
    required this.phone,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String imageUrl;

  Courier copyWith({
    String? id,
    String? name,
    String? phone,
    String? imageUrl,
  }) {
    return Courier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }

  factory Courier.fromMap(Map<String, dynamic> map) {
    return Courier(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Courier.fromJson(String source) => Courier.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, name, phone, imageUrl];
}

class Loaded extends Equatable {
  const Loaded({
    required this.branchId,
    required this.courierId,
    required this.warehouseId,
    required this.product,
  });

  final String branchId;
  final String courierId;
  final String warehouseId;
  final Map<String, int> product;

  Loaded copyWith({
    String? branchId,
    String? courierId,
    String? warehouseId,
    Map<String, int>? product,
  }) {
    return Loaded(
      branchId: branchId ?? this.branchId,
      courierId: courierId ?? this.courierId,
      warehouseId: warehouseId ?? this.warehouseId,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'branchId': branchId,
      'courierId': courierId,
      'warehouseId': warehouseId,
      'product': product,
    };
  }

  factory Loaded.fromMap(Map<String, dynamic> map) {
    return Loaded(
        branchId: map['branchId'] as String,
        courierId: map['courierId'] as String,
        warehouseId: map['warehouseId'] as String,
        product: Map<String, int>.from(
          (map['product'] as Map<String, dynamic>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory Loaded.fromJson(String source) => Loaded.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [branchId, courierId, warehouseId, product];
}

class Complete extends Equatable {
  const Complete({required this.courierId, required this.product, required this.status, required this.note});

  final String courierId;
  final List<DeliveryProduct> product;

  ///8. RESTOCK
  ///9. COMPLETE
  final int status;

  final String note;

  Complete copyWith({String? courierId, List<DeliveryProduct>? product, int? status, String? note}) {
    return Complete(
      courierId: courierId ?? this.courierId,
      product: product ?? this.product,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'courierId': courierId,
      'product': List<dynamic>.from(product.map((e) => e.toMap())),
      'status': status,
      'note': note,
    };
  }

  factory Complete.fromMap(Map<String, dynamic> map) {
    return Complete(
      courierId: map['courierId'] as String,
      product: List<DeliveryProduct>.from(
        (map['product'] as List<dynamic>).map<DeliveryProduct>(
          (x) => DeliveryProduct.fromMap(x as Map<String, dynamic>),
        ),
      ),
      status: map['status'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Complete.fromJson(String source) => Complete.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [courierId, product, status, note];
}

class DeliveryProduct extends Equatable {
  const DeliveryProduct({
    required this.id,
    required this.warehouse,
    required this.category,
    required this.brand,
    required this.name,
    required this.size,
    required this.imageUrl,
    required this.purcaseQty,
    required this.deliveryQty,
    required this.reciveQty,
    required this.brokenQty,
    required this.status,
  });

  final String id;
  final Warehouse? warehouse;
  final String category;
  final String brand;
  final String name;
  final String size;
  final String imageUrl;
  final int purcaseQty;
  final int deliveryQty;
  final int reciveQty;
  final int brokenQty;

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
  final int status;

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
  DeliveryProduct copyWith({
    String? id,
    Warehouse? warehouse,
    String? category,
    String? brand,
    String? name,
    String? size,
    String? imageUrl,
    int? purcaseQty,
    int? deliveryQty,
    int? reciveQty,
    int? brokenQty,
    int? status,
  }) {
    return DeliveryProduct(
      id: id ?? this.id,
      warehouse: warehouse ?? this.warehouse,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
      purcaseQty: purcaseQty ?? this.purcaseQty,
      deliveryQty: deliveryQty ?? this.deliveryQty,
      reciveQty: reciveQty ?? this.reciveQty,
      brokenQty: brokenQty ?? this.brokenQty,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'warehouse': warehouse?.toMap(),
      'category': category,
      'brand': brand,
      'name': name,
      'size': size,
      'imageUrl': imageUrl,
      'purcaseQty': purcaseQty,
      'deliveryQty': deliveryQty,
      'reciveQty': reciveQty,
      'brokenQty': brokenQty,
      'status': status,
    };
  }

  factory DeliveryProduct.fromMap(Map<String, dynamic> map) {
    return DeliveryProduct(
      id: map['id'] as String,
      warehouse: map['warehouse'] == null ? null : Warehouse.fromMap(map['warehouse'] as Map<String, dynamic>),
      category: map['category'] as String,
      brand: map['brand'] as String,
      name: map['name'] as String,
      size: map['size'] as String,
      imageUrl: map['imageUrl'] as String,
      purcaseQty: map['purcaseQty'] as int,
      deliveryQty: map['deliveryQty'] as int,
      reciveQty: map['reciveQty'] as int,
      brokenQty: map['brokenQty'] as int,
      status: map['status'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliveryProduct.fromJson(String source) => DeliveryProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      warehouse,
      category,
      brand,
      name,
      size,
      imageUrl,
      purcaseQty,
      deliveryQty,
      reciveQty,
      brokenQty,
      status,
    ];
  }
}

class Warehouse {
  Warehouse({
    required this.id,
    required this.name,
    required this.addressName,
    required this.addressLngLat,
  });

  final String id;
  final String name;
  final String addressName;
  final List<double> addressLngLat;

  Warehouse copyWith({
    String? id,
    String? name,
    String? addressName,
    List<double>? addressLngLat,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      addressName: addressName ?? this.addressName,
      addressLngLat: addressLngLat ?? this.addressLngLat,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'addressName': addressName,
      'addressLngLat': addressLngLat,
    };
  }

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
        id: map['id'] as String,
        name: map['name'] as String,
        addressName: map['addressName'] as String,
        addressLngLat: List<double>.from(
          (map['addressLngLat'] as List<dynamic>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory Warehouse.fromJson(String source) => Warehouse.fromMap(json.decode(source) as Map<String, dynamic>);
}
