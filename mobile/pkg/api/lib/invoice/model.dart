// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:api/common.dart';
import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  const Invoice({
    this.id = '',
    this.transactionId = '',
    this.orderId = '',
    this.regionId = '',
    this.regionName = '',
    this.branchId = '',
    this.branchName = '',
    this.customer = const InvoiceCustomer(),
    this.price = 0.0,
    this.paid = 0.0,
    this.url = '',
    this.channel = '',
    this.method = '',
    this.destination = '',
    this.paymentMethod = 0,
    this.status = 0,
    this.createdAt,
    this.paidAt,
    this.term,
  });

  final String id;
  final String transactionId;
  final String orderId;
  final String regionId;
  final String regionName;
  final String branchId;
  final String branchName;
  final InvoiceCustomer customer;
  final double price;
  final double paid;
  final String channel;
  final String method;
  final String destination;

  ///0.COD
  ///
  ///1.TOP
  ///
  ///2.TRF
  final int paymentMethod;
  final String url;

  ///0.APPLY
  ///
  ///1.PENDING
  ///
  ///2.WAITING PAY
  ///
  ///3.PAID
  ///
  ///4.CANCEL
  ///
  final int status;

  final DateTime? term;
  final DateTime? createdAt;
  final DateTime? paidAt;

  factory Invoice.fromJson(String str) => Invoice.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Invoice.fromMap(Map<String, dynamic> json) => Invoice(
        id: json["id"],
        transactionId: json["transactionId"],
        orderId: json["orderId"],
        regionId: json["regionId"],
        regionName: json["regionName"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        customer: InvoiceCustomer.fromMap(json["customer"]),
        price: doubleParse(json["price"]) ?? 0.0,
        paid: doubleParse(json["paid"]) ?? 0.0,
        channel: json["channel"],
        method: json["method"],
        destination: json["destination"],
        paymentMethod: json["paymentMethod"],
        url: json["url"],
        status: json["status"],
        term: DateTime.parse(json["term"]).toLocal(),
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        paidAt: DateTime.parse(json["paidAt"]).toLocal(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "transactionId": transactionId,
        "orderId": orderId,
        "regionId": regionId,
        "regionName": regionName,
        "branchId": branchId,
        "branchName": branchName,
        "customer": customer.toMap(),
        "price": price,
        "paid": paid,
        "url": url,
        "channel": channel,
        "method": method,
        "destination": destination,
        "paymentMethod": paymentMethod,
        "status": status,
        "createdAt": createdAt?.toUtc().toIso8601String(),
        "paidAt": paidAt?.toUtc().toIso8601String(),
        "term": term?.toUtc().toIso8601String(),
      };

  Invoice copyWith({
    String? id,
    String? transactionId,
    String? orderId,
    String? regionId,
    String? regionName,
    String? branchId,
    String? branchName,
    InvoiceCustomer? customer,
    double? price,
    double? paid,
    String? url,
    String? channel,
    String? method,
    String? destination,
    int? paymentMethod,
    int? status,
    DateTime? createdAt,
    DateTime? paidAt,
    DateTime? term,
  }) {
    return Invoice(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      customer: customer ?? this.customer,
      price: price ?? this.price,
      paid: paid ?? this.paid,
      url: url ?? this.url,
      channel: channel ?? this.channel,
      method: method ?? this.method,
      destination: destination ?? this.destination,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      term: term ?? this.term,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      transactionId,
      orderId,
      regionId,
      regionName,
      branchId,
      branchName,
      customer,
      price,
      paid,
      url,
      channel,
      method,
      destination,
      paymentMethod,
      status,
      createdAt,
      paidAt,
      term,
    ];
  }
}

class InvoiceCustomer extends Equatable {
  const InvoiceCustomer({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
  });

  final String id;
  final String name;
  final String phone;
  final String email;

  factory InvoiceCustomer.fromJson(String str) => InvoiceCustomer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceCustomer.fromMap(Map<String, dynamic> json) => InvoiceCustomer(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
      };

  InvoiceCustomer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
  }) {
    return InvoiceCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      name,
      phone,
      email,
    ];
  }
}
