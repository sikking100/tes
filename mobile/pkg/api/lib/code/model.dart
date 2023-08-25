import 'package:equatable/equatable.dart';

class Code extends Equatable {
  const Code({
    this.id = '',
    this.description = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Code.fromMap(Map<String, dynamic> json) => Code(
        id: json["id"],
        description: json["description"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  @override
  List<Object?> get props => [
        id,
        description,
        createdAt,
        updatedAt,
      ];
}
