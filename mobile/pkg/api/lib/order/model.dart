// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class OrderDetail {
  final Order order;
  final List<Delivery> deliveries;
  final List<Invoice> invoices;

  Invoice get invoice => invoices.isEmpty ? const Invoice() : invoices.firstWhere((element) => element.id == order.invoiceId);

  Delivery? get delivery => deliveries.isEmpty ? null : deliveries.firstWhere((element) => element.id == order.deliveryId);

  OrderDetail(this.order, this.deliveries, this.invoices);
}

class Order extends Equatable {
  const Order({
    this.id = '',
    this.invoiceId = '',
    this.deliveryId = '',
    this.regionId = '',
    this.regionName = '',
    this.branchId = '',
    this.branchName = '',
    this.priceId = '',
    this.priceName = '',
    this.code = '',
    this.customer = const OrderCustomer(),
    this.creator = const OrderCreator(),
    this.cancel = const Cancel(),
    this.product = const [],
    this.deliveryPrice = 0.0,
    this.productPrice = 0.0,
    this.totalPrice = 0.0,
    this.poFilePath = '',
    this.status = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String invoiceId;
  final String deliveryId;
  final String regionId;
  final String regionName;
  final String branchId;
  final String branchName;
  final String priceId;
  final String priceName;
  final String code;
  final OrderCustomer customer;
  final OrderCreator creator;
  final Cancel? cancel;
  final List<OrderProduct> product;
  final double deliveryPrice;
  final double productPrice;
  final double totalPrice;
  final String poFilePath;

  ///0.APPLY
  ///
  ///1.PENDING
  ///
  ///2.COMPLETE
  ///
  ///3.CANCEL
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get totalBuy => product.map((element) => (element.unitPrice - element.discount) * element.qty).reduce((value, element) => value + element);

  Order copyWith({
    String? id,
    String? invoiceId,
    String? deliveryId,
    String? regionId,
    String? regionName,
    String? branchId,
    String? branchName,
    String? priceId,
    String? priceName,
    String? code,
    OrderCustomer? customer,
    OrderCreator? creator,
    Cancel? cancel,
    List<OrderProduct>? product,
    double? deliveryPrice,
    double? productPrice,
    double? totalPrice,
    String? poFilePath,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      deliveryId: deliveryId ?? this.deliveryId,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      priceId: priceId ?? this.priceId,
      priceName: priceName ?? this.priceName,
      code: code ?? this.code,
      customer: customer ?? this.customer,
      creator: creator ?? this.creator,
      cancel: cancel ?? this.cancel,
      product: product ?? this.product,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      productPrice: productPrice ?? this.productPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      poFilePath: poFilePath ?? this.poFilePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'invoiceId': invoiceId,
      'deliveryId': deliveryId,
      'regionId': regionId,
      'regionName': regionName,
      'branchId': branchId,
      'branchName': branchName,
      'priceId': priceId,
      'priceName': priceName,
      'code': code,
      'customer': customer.toMap(),
      'creator': creator.toMap(),
      'cancel': cancel?.toMap(),
      'product': product.map((x) => x.toMap()).toList(),
      'deliveryPrice': deliveryPrice,
      'productPrice': productPrice,
      'totalPrice': totalPrice,
      'poFilePath': poFilePath,
      'status': status,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      invoiceId: map['invoiceId'] as String,
      deliveryId: map['deliveryId'] as String,
      regionId: map['regionId'] as String,
      regionName: map['regionName'] as String,
      branchId: map['branchId'] as String,
      branchName: map['branchName'] as String,
      priceId: map['priceId'] as String,
      priceName: map['priceName'] as String,
      code: map['code'] as String,
      customer: OrderCustomer.fromMap(map['customer'] as Map<String, dynamic>),
      creator: OrderCreator.fromMap(map['creator'] as Map<String, dynamic>),
      cancel: map['cancel'] != null ? Cancel.fromMap(map['cancel'] as Map<String, dynamic>) : null,
      product: List<OrderProduct>.from(
        (map['product'] as List<dynamic>).map<OrderProduct>(
          (x) => OrderProduct.fromMap(x as Map<String, dynamic>),
        ),
      ),
      deliveryPrice: doubleParse(map['deliveryPrice']) ?? 0.0,
      productPrice: doubleParse(map['productPrice']) ?? 0.0,
      totalPrice: doubleParse(map['totalPrice']) ?? 0.0,
      poFilePath: map['poFilePath'] as String,
      status: map['status'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props {
    return [
      id,
      invoiceId,
      deliveryId,
      regionId,
      regionName,
      branchId,
      branchName,
      priceId,
      priceName,
      code,
      customer,
      creator,
      cancel,
      product,
      deliveryPrice,
      productPrice,
      totalPrice,
      poFilePath,
      status,
      createdAt,
      updatedAt,
    ];
  }
}

class Now extends Equatable {
  const Now({
    this.id = '',
    this.isComplete = false,
  });

  final String id;
  final bool isComplete;

  factory Now.fromJson(String str) => Now.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Now.fromMap(Map<String, dynamic> json) => Now(
        id: json["id"],
        isComplete: json["isComplete"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "isComplete": isComplete,
      };

  @override
  List<Object> get props => [id, isComplete];
}

class OrderCustomer extends Equatable {
  const OrderCustomer({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.imageUrl = '',
    this.picName = '',
    this.picPhone = '',
    this.addressName = '',
    this.addressLngLat = const [],
    this.note = '',
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String imageUrl;
  final String picName;
  final String picPhone;
  final String addressName;
  final List<double> addressLngLat;
  final String note;

  double get lat => addressLngLat.last;
  double get lng => addressLngLat.first;

  OrderCustomer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    String? picName,
    String? picPhone,
    String? addressName,
    List<double>? addressLngLat,
    String? note,
  }) {
    return OrderCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      picName: picName ?? this.picName,
      picPhone: picPhone ?? this.picPhone,
      addressName: addressName ?? this.addressName,
      addressLngLat: addressLngLat ?? this.addressLngLat,
      note: note ?? this.note,
    );
  }

  factory OrderCustomer.fromJson(String str) => OrderCustomer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderCustomer.fromMap(Map<String, dynamic> json) => OrderCustomer(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        imageUrl: json["imageUrl"],
        picName: json["picName"],
        picPhone: json["picPhone"],
        addressName: json["addressName"],
        addressLngLat: List<double>.from(json["addressLngLat"].map((x) => x)),
        note: json["note"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "imageUrl": imageUrl,
        "picName": picName,
        "picPhone": picPhone,
        "addressName": addressName,
        "addressLngLat": List<dynamic>.from(addressLngLat.map((x) => x)),
        "note": note,
      };

  @override
  List<Object> get props {
    return [
      id,
      name,
      phone,
      email,
      imageUrl,
      picName,
      picPhone,
      addressName,
      addressLngLat,
      note,
    ];
  }
}

class OrderCreator extends Equatable {
  const OrderCreator({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.imageUrl = '',
    this.roles = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String imageUrl;
  final int roles;

  factory OrderCreator.fromJson(String str) => OrderCreator.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderCreator.fromMap(Map<String, dynamic> json) => OrderCreator(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        imageUrl: json["imageUrl"],
        roles: json["roles"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "imageUrl": imageUrl,
        "roles": roles,
      };

  @override
  List<Object> get props {
    return [
      id,
      name,
      phone,
      email,
      imageUrl,
      roles,
    ];
  }

  OrderCreator copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    int? roles,
  }) {
    return OrderCreator(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      roles: roles ?? this.roles,
    );
  }
}

class Cancel extends Equatable {
  const Cancel({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.imageUrl = '',
    this.roles = 0,
    this.note = '',
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String imageUrl;
  final int roles;
  final String note;

  factory Cancel.fromJson(String str) => Cancel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Cancel.fromMap(Map<String, dynamic> json) => Cancel(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        imageUrl: json["imageUrl"],
        roles: json["roles"],
        note: json["note"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "imageUrl": imageUrl,
        "roles": roles,
        "note": note,
      };

  @override
  List<Object> get props {
    return [
      id,
      name,
      phone,
      email,
      imageUrl,
      roles,
      note,
    ];
  }

  Cancel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    int? roles,
    String? note,
  }) {
    return Cancel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      roles: roles ?? this.roles,
      note: note ?? this.note,
    );
  }
}

class OrderProduct extends Equatable {
  const OrderProduct({
    this.id = '',
    this.categoryId = '',
    this.categoryName = '',
    this.team = 0,
    this.brandId = '',
    this.brandName = '',
    this.salesId = '',
    this.salesName = '',
    this.name = '',
    this.description = '',
    this.size = '',
    this.imageUrl = '',
    this.point = 0.0,
    this.unitPrice = 0.0,
    this.discount = 0,
    this.qty = 0,
    this.totalPrice = 0.0,
    this.tax = 0.0,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final int team;
  final String brandId;
  final String brandName;
  final String salesId;
  final String salesName;
  final String name;
  final String description;
  final String size;
  final String imageUrl;
  final double point;
  final double unitPrice;
  final double discount;
  final int qty;
  final double totalPrice;
  final double tax;

  OrderProduct copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    int? team,
    String? brandId,
    String? brandName,
    String? salesId,
    String? salesName,
    String? name,
    String? description,
    String? size,
    String? imageUrl,
    double? point,
    double? unitPrice,
    double? discount,
    int? qty,
    double? totalPrice,
    double? tax,
  }) {
    return OrderProduct(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      team: team ?? this.team,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      salesId: salesId ?? this.salesId,
      salesName: salesName ?? this.salesName,
      name: name ?? this.name,
      description: description ?? this.description,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
      point: point ?? this.point,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      qty: qty ?? this.qty,
      totalPrice: totalPrice ?? this.totalPrice,
      tax: tax ?? this.tax,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'team': team,
      'brandId': brandId,
      'brandName': brandName,
      'salesId': salesId,
      'salesName': salesName,
      'name': name,
      'description': description,
      'size': size,
      'imageUrl': imageUrl,
      'point': point,
      'unitPrice': unitPrice,
      'discount': discount,
      'qty': qty,
      'totalPrice': totalPrice,
      'tax': tax,
    };
  }

  factory OrderProduct.fromMap(Map<String, dynamic> map) {
    return OrderProduct(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      team: map['team'] as int,
      brandId: map['brandId'] as String,
      brandName: map['brandName'] as String,
      salesId: map['salesId'] as String,
      salesName: map['salesName'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      size: map['size'] as String,
      imageUrl: map['imageUrl'] as String,
      point: doubleParse(map['point']) ?? 0.0,
      unitPrice: doubleParse(map['unitPrice']) ?? 0.0,
      discount: doubleParse(map['discount']) ?? 0.0,
      qty: map['qty'] as int,
      totalPrice: doubleParse(map['totalPrice']) ?? 0.0,
      tax: doubleParse(map['tax']) ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderProduct.fromJson(String source) => OrderProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object> get props {
    return [
      id,
      categoryId,
      categoryName,
      team,
      brandId,
      brandName,
      salesId,
      salesName,
      name,
      description,
      size,
      imageUrl,
      point,
      unitPrice,
      discount,
      qty,
      totalPrice,
      tax,
    ];
  }
}

class OrderApply extends Equatable {
  final String id;
  final List<UserApprover> userApprover;
  final String customerId;
  final double overlimit;
  final double overdue;
  final double totalPrice;

  ///0.PENDING
  ///
  ///1.WAITING APPROVE
  ///
  ///2.APPROVE
  ///
  ///3.REJECT
  final int status;
  final DateTime? expiredAt;
  const OrderApply({
    required this.id,
    required this.userApprover,
    required this.customerId,
    required this.overlimit,
    required this.overdue,
    required this.totalPrice,
    required this.status,
    this.expiredAt,
  });

  OrderApply copyWith({
    String? id,
    List<UserApprover>? userApprover,
    String? customerId,
    double? overlimit,
    double? overdue,
    double? totalPrice,
    int? status,
    DateTime? expiredAt,
  }) {
    return OrderApply(
      id: id ?? this.id,
      userApprover: userApprover ?? this.userApprover,
      customerId: customerId ?? this.customerId,
      overlimit: overlimit ?? this.overlimit,
      overdue: overdue ?? this.overdue,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userApprover': userApprover.map((x) => x.toMap()).toList(),
      'customerId': customerId,
      'overlimit': overlimit,
      'overdue': overdue,
      'totalPrice': totalPrice,
      'status': status,
      'expiredAt': expiredAt?.millisecondsSinceEpoch,
    };
  }

  factory OrderApply.fromMap(Map<String, dynamic> map) {
    return OrderApply(
      id: map['id'] as String,
      userApprover: List<UserApprover>.from(
        (map['userApprover'] as List<dynamic>).map<UserApprover>(
          (x) => UserApprover.fromMap(x as Map<String, dynamic>),
        ),
      ),
      customerId: map['customerId'] as String,
      overlimit: doubleParse(map['overLimit']) ?? 0.0,
      overdue: doubleParse(map['overDue']) ?? 0.0,
      totalPrice: doubleParse(map['totalPrice']) ?? 0.0,
      status: map['status'] as int,
      expiredAt: map['expiredAt'] != null ? DateTime.parse(map['expiredAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderApply.fromJson(String source) => OrderApply.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  List<UserApprover> get user {
    return userApprover.where((element) => element.status != 0 && element.note != 'approve by system').toList();
  }

  bool isNotMe(String id) {
    if (!user.map((e) => e.id).contains(id)) return true;
    return user.firstWhere((element) => element.id == id).status != 1;
  }

  @override
  List<Object?> get props {
    return [
      id,
      userApprover,
      customerId,
      overlimit,
      overdue,
      totalPrice,
      status,
      expiredAt,
    ];
  }
}

class UserApprover extends Equatable {
  const UserApprover({
    this.id = '',
    this.phone = '',
    this.email = '',
    this.name = '',
    this.imageUrl = '',
    this.roles = 0,
    this.fcmToken = '',
    this.status = 0,
    this.note = '',
    this.updatedAt,
  });

  final String id;
  final String phone;
  final String email;
  final String name;
  final String imageUrl;
  final int roles;
  final String fcmToken;
  final String note;

  ///0.PENDING
  ///
  ///1.WAITING APPROVE
  ///
  ///2.APPROVE
  ///
  ///3.REJECT
  final int status;
  final DateTime? updatedAt;

  factory UserApprover.fromJson(String str) => UserApprover.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserApprover.fromMap(Map<String, dynamic> json) => UserApprover(
        id: json["id"],
        phone: json["phone"],
        email: json["email"],
        name: json["name"],
        imageUrl: json["imageUrl"],
        roles: json['roles'],
        fcmToken: json["fcmToken"],
        status: json["status"],
        note: json["note"],
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "phone": phone,
        "email": email,
        "name": name,
        "imageUrl": imageUrl,
        "fcmToken": fcmToken,
        'roles': roles,
        "status": status,
        "note": note,
        "updatedAt": DateTime.now().toUtc().toIso8601String(),
      };

  UserApprover copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? imageUrl,
    String? fcmToken,
    int? status,
    String? note,
    int? roles,
    DateTime? updatedAt,
  }) {
    return UserApprover(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      status: status ?? this.status,
      note: note ?? this.note,
      roles: roles ?? this.roles,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      email,
      name,
      imageUrl,
      fcmToken,
      status,
      note,
      roles,
      updatedAt,
    ];
  }
}

class CreateOrder {
  CreateOrder({
    this.regionId = '',
    this.regionName = '',
    this.branchId = '',
    this.branchName = '',
    this.priceId = '',
    this.priceName = '',
    this.code = '',
    this.customer = const OrderCustomer(),
    this.orderCreator = const OrderCreator(),
    this.product = const [],
    this.paymentMethod = 0,
    this.deliveryType = 0,
    this.deliveryPrice = 0,
    this.deliveryAt,
    this.poFilePath = '',
    this.productPrice = 0,
    this.totalPrice = 0,
    this.termInvoice = 0,
    this.creditLimit = 0,
    this.creditUsed = 0,
    this.transactionLastMonth = 0,
    this.transactionPerMonth = 0,
    this.userApprover = const [],
  });

  final String regionId;
  final String regionName;
  final String branchId;
  final String branchName;
  final String priceId;
  final String priceName;
  final String code;
  final OrderCustomer customer;
  final OrderCreator orderCreator;
  final List<OrderProduct> product;

  ///0.CASH ON DELIVERY
  ///
  ///1.TERM OF PAYMENT
  ///
  ///2.TRANSFER
  final int paymentMethod;

  ///0.INTERNAL
  ///
  ///1.EXTERNAL
  final int deliveryType;
  final double deliveryPrice;
  final double productPrice;
  final double totalPrice;
  final DateTime? deliveryAt;
  final String poFilePath;
  final int termInvoice;
  final double creditLimit;
  final double creditUsed;
  final double transactionLastMonth;
  final double transactionPerMonth;
  final List<UserApprover> userApprover;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'regionId': regionId,
      'regionName': regionName,
      'branchId': branchId,
      'branchName': branchName,
      'priceId': priceId,
      'priceName': priceName,
      'code': code,
      'customer': customer.toMap(),
      'creator': orderCreator.toMap(),
      'product': product.map((x) => x.toMap()).toList(),
      'paymentMethod': paymentMethod,
      'deliveryType': deliveryType,
      'deliveryPrice': deliveryPrice,
      'productPrice': productPrice,
      'totalPrice': totalPrice,
      'deliveryAt': deliveryAt?.toUtc().toIso8601String(),
      'poFilePath': poFilePath,
      'termInvoice': termInvoice,
      'creditLimit': creditLimit,
      'creditUsed': creditUsed,
      'transactionLastMonth': transactionLastMonth,
      'transactionPerMonth': transactionPerMonth,
      'userApprover': userApprover.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
  CreateOrder copyWith({
    String? regionId,
    String? regionName,
    String? branchId,
    String? branchName,
    String? priceId,
    String? priceName,
    String? code,
    OrderCustomer? customer,
    OrderCreator? orderCreator,
    List<OrderProduct>? product,
    int? paymentMethod,
    int? deliveryType,
    double? deliveryPrice,
    double? productPrice,
    double? totalPrice,
    DateTime? deliveryAt,
    String? poFilePath,
    int? termInvoice,
    double? creditLimit,
    double? creditUsed,
    double? transactionLastMonth,
    double? transactionPerMonth,
    List<UserApprover>? userApprover,
  }) {
    return CreateOrder(
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      priceId: priceId ?? this.priceId,
      priceName: priceName ?? this.priceName,
      code: code ?? this.code,
      customer: customer ?? this.customer,
      orderCreator: orderCreator ?? this.orderCreator,
      product: product ?? this.product,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      productPrice: productPrice ?? this.productPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryAt: deliveryAt ?? this.deliveryAt,
      poFilePath: poFilePath ?? this.poFilePath,
      termInvoice: termInvoice ?? this.termInvoice,
      creditLimit: creditLimit ?? this.creditLimit,
      creditUsed: creditUsed ?? this.creditUsed,
      transactionLastMonth: transactionLastMonth ?? this.transactionLastMonth,
      transactionPerMonth: transactionPerMonth ?? this.transactionPerMonth,
      userApprover: userApprover ?? this.userApprover,
    );
  }
}

class Performance extends Equatable {
  const Performance({
    this.regionId = '',
    this.regionName = '',
    this.branchId = '',
    this.branchName = '',
    this.categoryId = '',
    this.categoryName = '',
    this.categoryTarget = 0,
    this.qty = 0,
  });

  final String regionId;
  final String regionName;
  final String branchId;
  final String branchName;
  final String categoryId;
  final String categoryName;
  final int categoryTarget;
  final int qty;

  factory Performance.fromJson(String str) => Performance.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Performance.fromMap(Map<String, dynamic> json) => Performance(
        regionId: json["regionId"],
        regionName: json["regionName"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        categoryTarget: json["categoryTarget"],
        qty: json["qty"],
      );

  Map<String, dynamic> toMap() => {
        "regionId": regionId,
        "regionName": regionName,
        "branchId": branchId,
        "branchName": branchName,
        "categoryId": categoryId,
        "categoryName": categoryName,
        "categoryTarget": categoryTarget,
        "qty": qty,
      };

  Performance copyWith({
    String? regionId,
    String? regionName,
    String? branchId,
    String? branchName,
    String? categoryId,
    String? categoryName,
    int? categoryTarget,
    int? qty,
  }) {
    return Performance(
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryTarget: categoryTarget ?? this.categoryTarget,
      qty: qty ?? this.qty,
    );
  }

  @override
  List<Object> get props {
    return [
      regionId,
      regionName,
      branchId,
      branchName,
      categoryId,
      categoryName,
      categoryTarget,
      qty,
    ];
  }
}

class Approval {
  final String userId;
  final String note;
  final List<UserApprover> userApprover;
  Approval({
    required this.userId,
    required this.note,
    required this.userApprover,
  });

  Approval copyWith({
    String? userId,
    String? note,
    List<UserApprover>? userApprover,
  }) {
    return Approval(
      userId: userId ?? this.userId,
      note: note ?? this.note,
      userApprover: userApprover ?? this.userApprover,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'note': note,
      'userApprover': userApprover.map((x) => x.toMap()).toList(),
    };
  }

  factory Approval.fromMap(Map<String, dynamic> map) {
    return Approval(
      userId: map['userId'] as String,
      note: map['note'] as String,
      userApprover: List<UserApprover>.from(
        (map['userApprover'] as List<dynamic>).map<UserApprover>(
          (x) => UserApprover.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Approval.fromJson(String source) => Approval.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Approval(userId: $userId, note: $note, userApprover: $userApprover)';

  @override
  bool operator ==(covariant Approval other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.userId == userId && other.note == note && listEquals(other.userApprover, userApprover);
  }

  @override
  int get hashCode => userId.hashCode ^ note.hashCode ^ userApprover.hashCode;
}
