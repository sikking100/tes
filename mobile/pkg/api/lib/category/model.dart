import 'dart:convert';

import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    this.id = '',
    this.name = '',
    this.team = 0,
    this.target = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;

  ///
  ///1 food
  ///2 retail
  final int team;
  final int target;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"] ?? '',
        name: json["name"] ?? '',
        team: json['team'] ?? 0,
        target: json['target'] ?? 0,
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]).toLocal(),
      );

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, target, team];

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'team': team});
    result.addAll({'target': target});
    if (createdAt != null) {
      result.addAll({'createdAt': createdAt!.millisecondsSinceEpoch});
    }
    if (updatedAt != null) {
      result.addAll({'updatedAt': updatedAt!.millisecondsSinceEpoch});
    }

    return result;
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));
}
