// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';

const host = 'apigateway-service-ckndvuglva-et.a.run.app';
//prod
// const host = 'apigateway-service-l2bago5gdq-et.a.run.app';

class Headers {
  const Headers([this.authorization]);

  final String? authorization;

  Map<String, String> toMap() => authorization == null
      ? {"accept": 'application/json'}
      : {
          "accept": 'application/json',
          "Authorization": "Bearer $authorization",
        };

  Map<String, String> toMapWithReq() => authorization != null
      ? {
          "accept": 'application/json',
          "Authorization": "Bearer $authorization",
          "Content-Type": "application/json",
        }
      : {
          "accept": 'application/json',
          "Content-Type": "application/json",
        };
}

class Responses extends Equatable {
  final int code;
  final String? errors;
  final dynamic data;
  final BaseRequest? req;

  const Responses(this.code, this.errors, this.data, [this.req]);

  factory Responses.fromMap(Map<String, dynamic> json, [BaseRequest? req]) {
    return Responses(
      json['code'],
      json['errors'] ?? json['errros'],
      json['data'],
      req,
    );
  }

  factory Responses.fromJson(String str, [BaseRequest? req]) {
    return Responses.fromMap(jsonDecode(str), req);
  }

  @override
  String toString() {
    switch (code) {
      case 400:
        return 'Input tidak valid, pastikan semua inputan sudah benar';
      case 401:
        return 'Anda tidak punya akses';
      case 404:
        if (errors == 'branch not found') return 'Cabang tidak ditemukan';
        if (req?.url.path.contains('auth') == true) return 'Anda belum terdaftar';
        return 'Data tidak ditemukan';

      case 409:
        return 'Data pengguna sudah ada';
      case 500:
        return 'Sistem sedang sibuk, silakan coba beberapa saat lagi';
      default:
        return super.toString();
    }
  }

  @override
  List<Object?> get props => [code, errors, data];
}

class Paging<T> extends Equatable {
  final int? next;
  final List<T> items;

  const Paging(this.next, this.items);

  factory Paging.fromMap(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) convert,
  ) {
    return Paging(
      json['next'],
      List<T>.from((json['items'] as List).map((e) => convert(e))),
    );
  }

  Paging<T> copyWith({int? next, List<T>? items}) => Paging(next ?? this.next, items ?? this.items);

  @override
  List<Object?> get props => [next, items];
}

String phoneChange(String phone) {
  if (phone.startsWith('0')) return '+62${phone.substring(1)}';
  if (phone.startsWith('8')) return '+62$phone';
  return phone;
}

class Item extends Equatable {
  final int pageLimit;
  final int pageNumber;
  final String? regionId;
  final String? branchId;
  final String? priceId;
  final int? type;
  final String? brandId;
  final int? team;
  final bool? isPending;
  final String? query;
  final String? qType;
  final String? qValue;
  final String? userId;

  const Item({
    this.pageLimit = 0,
    this.pageNumber = 0,
    this.regionId,
    this.branchId,
    this.priceId,
    this.type,
    this.brandId,
    this.team,
    this.isPending,
    this.query,
    this.qType,
    this.qValue,
    this.userId,
  });

  factory Item.fromMap(Map<String, dynamic> json) => Item(
        pageLimit: json['pageLimit'],
        pageNumber: json['pageNumber'],
        regionId: json['regoinId'] ?? json['regionId'],
        branchId: json['branchId'],
        priceId: json['priceId'],
        type: json['type'],
        brandId: json['brandId'],
        team: json['team'],
        isPending: json['isPending'],
        query: json['query'],
        qType: json['qType'],
        qValue: json['qValue'],
        userId: json['userId'],
      );

  @override
  List<Object?> get props => [
        pageLimit,
        pageNumber,
        regionId,
        branchId,
        priceId,
        type,
        brandId,
        team,
        isPending,
        query,
        qType,
        qValue,
        userId,
      ];
}

class Address extends Equatable {
  final String name;
  final List<double> lngLat;
  const Address({
    this.name = '',
    this.lngLat = const [],
  });

  double get lat => lngLat.last;
  double get lng => lngLat.first;

  Address copyWith({
    String? name,
    List<double>? lngLat,
  }) {
    return Address(
      name: name ?? this.name,
      lngLat: lngLat ?? this.lngLat,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'lngLat': lngLat});

    return result;
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      name: map['name'] ?? '',
      lngLat: List<double>.from(map['lngLat']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Address.fromJson(String source) => Address.fromMap(json.decode(source));

  @override
  String toString() => 'BusinessAddress(name: $name, lngLat: $lngLat)';

  @override
  List<Object> get props => [name, lngLat];
}

class CreatedBy extends Equatable {
  const CreatedBy({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.imageUrl = '',
    this.address = const Address(),
    this.roles = '',
    this.description = '',
    this.note = '',
    this.status = '',
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String imageUrl;
  final Address address;
  final String roles;
  final String description;

  ///hanya dipakai di approval
  final String note;

  ///hanya dipakai di approval
  final String status;

  ///hanya dipakai di approval
  final DateTime? updatedAt;

  factory CreatedBy.fromMap(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        name: json["name"],
        phone: json["phone"] ?? '',
        imageUrl: json["imageUrl"] ?? '',
        address: json["address"] == null ? const Address() : Address.fromMap(json["address"]),
        roles: json["roles"] ?? '',
        description: json['description'] ?? '',
        note: json['note'] ?? '',
        status: json['status'] ?? '',
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']).toLocal() : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "phone": phone,
        "imageUrl": imageUrl,
        "roles": roles,
      };

  Map<String, dynamic> toActivitySave() => {
        'id': id,
        'name': name,
        'roles': roles,
        'imageUrl': imageUrl,
        'description': description,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        imageUrl,
        address,
        roles,
        description,
        note,
        status,
        updatedAt,
      ];
}

class Team {
  ///FOOD SERVICE
  static const int food = 1;

  ///RETAIL
  static const int retail = 2;

  ///DEFAULT
  static const int def = 0;
}

class UserRoles {
  /// SYSTEM ADMIN
  static const int sysAdmin = 1;

  /// DIREKTUR

  static const int direktur = 9;

  /// GENERAL MANAGER
  static const int gm = 10;

  /// NASIONAL SALES MANAGER
  static const int nsm = 11;

  /// REGIONAL MANAGER
  static const int rm = 12;

  /// AREA MANAGER
  static const int am = 13;

  /// SALES
  static const int sales = 14;

  /// COURIER
  static const int courier = 15;

  /// CUSTOMER
  static const int customer = 0;
}

class PaymentMethod {
  static const int cod = 0;
  static const int trf = 2;
  static const int top = 1;
}

Future<T> request<T>(FutureOr<T> Function() computation) async {
  try {
    return await computation();
  } on FirebaseException catch (er) {
    if (er.code == 'network-request-failed') {
      throw 'Tidak terhubung ke internet';
    }
    rethrow;
  } on SocketException {
    throw 'Tidak terhubung ke internet';
  } catch (e) {
    rethrow;
  }
}

class ApplicationType {
  ///ApplicationType
  ///
  /// Value : 1
  static const int customer = 1;

  ///ApplicationType
  ///
  /// Value : 2
  static const int sysAdmin = 2;

  ///ApplicationType
  ///
  /// Value : 3
  static const int findAdmin = 3;

  ///ApplicationType
  ///
  /// Value : 4
  static const int salAdmin = 4;

  ///ApplicationType
  ///
  /// Value : 5
  static const int braAdmin = 5;

  ///ApplicationType
  ///
  /// Value : 6
  static const int warAdmin = 6;

  ///ApplicationType
  ///
  /// Value : 7
  static const int leader = 7;

  ///ApplicationType
  ///
  /// Value : 8
  static const int sales = 8;

  ///ApplicationType
  ///
  /// Value : 9
  static const int courier = 9;
}

double? doubleParse(dynamic v) => v is int ? (v).toDouble() : v;
