import 'dart:convert';

import 'package:api/common.dart';
import 'package:equatable/equatable.dart';

class PriceList extends Equatable {
  final String id;
  final String name;
  final double price;
  final List<Discount> discount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const PriceList({
    this.id = '',
    this.name = '',
    this.price = 0,
    this.discount = const [],
    this.createdAt,
    this.updatedAt,
  });

  PriceList copyWith({
    String? id,
    String? name,
    double? price,
    List<Discount>? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PriceList(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'price': price});
    result.addAll({'discount': discount.map((x) => x.toMap()).toList()});
    if (createdAt != null) {
      result.addAll({'createdAt': createdAt!.millisecondsSinceEpoch});
    }
    if (updatedAt != null) {
      result.addAll({'updatedAt': updatedAt!.millisecondsSinceEpoch});
    }

    return result;
  }

  Map<String, dynamic> toBusiness() {
    final result = <String, dynamic>{};
    result.addAll({'id': id});
    result.addAll({'name': name});
    return result;
  }

  factory PriceList.fromMap(Map<String, dynamic> map) {
    return PriceList(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: doubleParse(map['price']) ?? 0,
      discount: map['discount'] == null ? [] : List<Discount>.from(map['discount']?.map((x) => Discount.fromMap(x))),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PriceList.fromJson(String source) => PriceList.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PriceList(id: $id, name: $name, price: $price, discount: $discount, createdAt: ${createdAt?.toUtc().toIso8601String()}, updatedAt: ${updatedAt?.toUtc().toIso8601String()})';
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      price,
      discount,
      createdAt,
      updatedAt,
    ];
  }
}

class Discount extends Equatable {
  final int min;
  final int? max;
  final double discount;
  final DateTime? startAt;
  final DateTime? expiredAt;
  const Discount({
    this.min = 0,
    this.max,
    this.discount = 0,
    this.startAt,
    this.expiredAt,
  });

  Discount copyWith({
    int? min,
    int? max,
    double? discount,
    DateTime? startAt,
    DateTime? expiredAt,
  }) {
    return Discount(
      min: min ?? this.min,
      max: max ?? this.max,
      discount: discount ?? this.discount,
      startAt: startAt ?? this.startAt,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'min': min});
    if (max != null) {
      result.addAll({'max': max});
    }
    result.addAll({'discount': discount});
    if (startAt != null) {
      result.addAll({'startAt': startAt!.millisecondsSinceEpoch});
    }
    if (expiredAt != null) {
      result.addAll({'expiredAt': expiredAt!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      min: map['min']?.toInt() ?? 0,
      max: map['max']?.toInt(),
      discount: doubleParse(map['discount']) ?? 0,
      startAt: map['startAt'] != null ? DateTime.parse(map['startAt']).toLocal() : null,
      expiredAt: map['expiredAt'] != null ? DateTime.parse(map['expiredAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Discount.fromJson(String source) => Discount.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Discount(min: $min, max: $max, discount: $discount, startAt: ${startAt?.toUtc().toIso8601String()}, expiredAt: ${expiredAt?.toUtc().toIso8601String()})';
  }

  @override
  List<Object?> get props {
    return [
      min,
      max,
      discount,
      startAt,
      expiredAt,
    ];
  }
}
