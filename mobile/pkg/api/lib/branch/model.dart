import 'dart:convert';

import 'package:api/common.dart';
import 'package:api/customer/model.dart';
import 'package:api/region/model.dart';
import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  const Branch({
    this.id = '',
    this.region = const Region(),
    this.name = '',
    this.address = const Address(),
    this.warehouse = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final Region? region;
  final String name;
  final Address? address;
  final List<Warehouse> warehouse;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Branch.fromMap(Map<String, dynamic> json) => Branch(
        id: json["id"],
        region: json["region"] == null ? null : Region.fromMap(json["region"]),
        name: json["name"],
        address: json['address'] == null
            ? null
            : json["address"].runtimeType == String
                ? Address(name: json["address"])
                : Address.fromMap(json["address"]),
        warehouse: List<Warehouse>.from(json['warehouse'].map((e) => Warehouse.fromMap(e))),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "region": region?.toMap(),
        "name": name,
        "address": address == null
            ? null
            : address!.lngLat.isEmpty
                ? address!.name
                : address!.toMap(),
        "createdAt": createdAt?.toUtc().toIso8601String(),
        "updatedAt": updatedAt?.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        region,
        name,
        address,
        warehouse,
        createdAt,
        updatedAt,
      ];
}

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String phone;
  final BusinessAddress address;
  final bool isDefault;
  const Warehouse({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.address = const BusinessAddress(),
    this.isDefault = false,
  });

  Warehouse copyWith({
    String? id,
    String? name,
    String? phone,
    BusinessAddress? address,
    bool? isDefault,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'phone': phone});
    result.addAll({'address': address.toMap()});
    result.addAll({'isDefault': isDefault});

    return result;
  }

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: BusinessAddress.fromMap(map['address']),
      isDefault: map['isDefault'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Warehouse.fromJson(String source) => Warehouse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, phone: $phone, address: $address, isDefault: $isDefault)';
  }

  @override
  List<Object> get props {
    return [
      id,
      name,
      phone,
      address,
      isDefault,
    ];
  }
}
