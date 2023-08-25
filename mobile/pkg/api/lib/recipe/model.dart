import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  const Recipe({
    this.id = '',
    this.category = '',
    this.title = '',
    this.imageUrl = '',
    this.description = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String category;
  final String title;
  final String imageUrl;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Recipe.fromMap(Map<String, dynamic> json) => Recipe(
        id: json["id"],
        category: json["category"],
        title: json["title"],
        imageUrl: json["imageUrl"],
        description: json["description"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  @override
  List<Object?> get props => [id, category, title, imageUrl, description, createdAt, updatedAt];
}
