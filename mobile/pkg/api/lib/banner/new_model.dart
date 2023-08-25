import 'package:equatable/equatable.dart';

class BannerType {
  static const int internal = 1;
  static const int external = 2;
}

class Banner extends Equatable {
  const Banner({
    this.id = '',
    this.type = BannerType.internal,
    this.imageUrl = '',
  });

  final String id;
  final int type;
  final String imageUrl;

  factory Banner.fromMap(Map<String, dynamic> json) => Banner(
        id: json["id"],
        type: json["type"],
        imageUrl: json["imageUrl"],
      );

  @override
  List<Object?> get props => [id, type, imageUrl];
}
