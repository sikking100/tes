import 'package:equatable/equatable.dart';

class Region extends Equatable {
  const Region({
    this.id = '',
    this.name = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Region.fromMap(Map<String, dynamic> json) => Region(
        id: json["id"],
        name: json["name"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "createdAt": createdAt?.toUtc().toIso8601String(),
        "updatedAt": updatedAt?.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
