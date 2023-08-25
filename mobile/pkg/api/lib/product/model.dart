// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:api/brand/model.dart';
import 'package:api/category/model.dart';
import 'package:api/price_list/model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

class Product extends Equatable {
  final String id;
  final String branchId;
  final String productId;
  final String salesId;
  final String salesName;
  final Category category;
  final Brand brand;
  final String name;
  final String description;
  final String size;
  final String imageUrl;
  final double point;
  final List<PriceList> price;
  final List<WarehouseList> warehouse;
  final int orderCount;
  final bool isVisible;
  final double additionalDiscount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PriceList kPrice([String? id]) {
    // price.sort((a, b) => b.price.compareTo(a.price));
    if (id == null || !price.map((e) => e.id).contains(id)) {
      // if (id == null) {
      final que = PriorityQueue<PriceList>((a, b) => b.price.compareTo(a.price));
      que.addAll(price);
      return que.first;
    }
    return price.firstWhere((element) => element.id == id);
  }

  const Product({
    this.id = '',
    this.branchId = '',
    this.productId = '',
    this.salesId = '',
    this.salesName = '',
    this.category = const Category(),
    this.brand = const Brand(),
    this.name = '',
    this.description = '',
    this.size = '',
    this.imageUrl = '',
    this.point = 0.0,
    required this.price,
    required this.warehouse,
    this.orderCount = 0,
    this.isVisible = true,
    this.additionalDiscount = 0,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? branchId,
    String? productId,
    String? salesId,
    String? salesName,
    Category? category,
    Brand? brand,
    String? name,
    String? description,
    String? size,
    String? imageUrl,
    double? point,
    List<PriceList>? price,
    List<WarehouseList>? warehouse,
    int? orderCount,
    bool? isVisible,
    double? additionalDiscount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      salesId: salesId ?? this.salesId,
      salesName: salesName ?? this.salesName,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      description: description ?? this.description,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
      point: point ?? this.point,
      price: price ?? this.price,
      warehouse: warehouse ?? this.warehouse,
      orderCount: orderCount ?? this.orderCount,
      isVisible: isVisible ?? this.isVisible,
      additionalDiscount: additionalDiscount ?? this.additionalDiscount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'branchId': branchId,
      'productId': productId,
      'salesId': salesId,
      'salesName': salesName,
      'category': category.toMap(),
      'brand': brand.toMap(),
      'name': name,
      'description': description,
      'size': size,
      'imageUrl': imageUrl,
      'point': point,
      'price': price.map((x) => x.toMap()).toList(),
      'warehouse': warehouse.map((x) => x.toMap()).toList(),
      'orderCount': orderCount,
      'isVisible': isVisible,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      branchId: map['branchId'] as String,
      productId: map['productId'] as String,
      salesId: map['salesId'] as String,
      salesName: map['salesName'] as String,
      category: Category.fromMap(map['category'] as Map<String, dynamic>),
      brand: Brand.fromMap(map['brand'] as Map<String, dynamic>),
      name: map['name'] as String,
      description: map['description'] as String,
      size: map['size'] as String,
      imageUrl: map['imageUrl'] as String,
      point: map['point'].toDouble(),
      price: List<PriceList>.from(
        (map['price'] as List<dynamic>).map<PriceList>(
          (x) => PriceList.fromMap(x as Map<String, dynamic>),
        ),
      ),
      warehouse: List<WarehouseList>.from(
        (map['warehouse'] as List<dynamic>).map<WarehouseList>(
          (x) => WarehouseList.fromMap(x as Map<String, dynamic>),
        ),
      ),
      orderCount: map['orderCount'] as int,
      isVisible: map['isVisible'] as bool,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(id: $id, branchId: $branchId, productId: $productId, category: $category, brand: $brand, name: $name, description: $description, size: $size, imageUrl: $imageUrl, point: $point, price: $price, warehouse: $warehouse, orderCount: $orderCount, isVisible: $isVisible, createdAt: ${createdAt?.toUtc().toIso8601String()}, updatedAt: ${updatedAt?.toUtc().toIso8601String()})';
  }

  @override
  List<Object?> get props {
    return [
      id,
      branchId,
      productId,
      salesId,
      salesName,
      category,
      brand,
      name,
      description,
      size,
      imageUrl,
      point,
      price,
      warehouse,
      orderCount,
      isVisible,
      additionalDiscount,
      createdAt,
      updatedAt,
    ];
  }

  @override
  bool get stringify => true;
}

class WarehouseList extends Equatable {
  const WarehouseList({
    required this.id,
    required this.name,
    required this.qty,
  });

  final String id;
  final String name;
  final int qty;

  factory WarehouseList.fromJson(String str) => WarehouseList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory WarehouseList.fromMap(Map<String, dynamic> json) => WarehouseList(
        id: json["id"],
        name: json["name"],
        qty: json["qty"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "qty": qty,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        qty,
      ];
}
