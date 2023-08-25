import 'dart:convert';

import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  const Brand({
    this.id = '',
    this.name = '',
    this.imageUrl = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, name, imageUrl, createdAt, updatedAt];

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'imageUrl': imageUrl});
    if (createdAt != null) {
      result.addAll({'createdAt': createdAt!.millisecondsSinceEpoch});
    }
    if (updatedAt != null) {
      result.addAll({'updatedAt': updatedAt!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Brand.fromJson(String source) => Brand.fromMap(json.decode(source));
}
