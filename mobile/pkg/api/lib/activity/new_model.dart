import 'dart:convert';

import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.imageUrl,
    required this.comment,
    required this.commentCount,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String imageUrl;
  final List<Comment> comment;
  final int commentCount;
  final Creator creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Activity.fromJson(String str) => Activity.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Activity.fromMap(Map<String, dynamic> json) => Activity(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        videoUrl: json["videoUrl"],
        imageUrl: json["imageUrl"],
        comment: List<Comment>.from(json["comment"].map((x) => Comment.fromMap(x))),
        commentCount: json["commentCount"],
        creator: Creator.fromMap(json["creator"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "description": description,
        "videoUrl": videoUrl,
        "imageUrl": imageUrl,
        "comment": List<dynamic>.from(comment.map((x) => x.toMap())),
        "commentCount": commentCount,
        "creator": creator.toMap(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        videoUrl,
        imageUrl,
        comment,
        commentCount,
        creator,
        createdAt,
        updatedAt,
      ];
}

class Creator extends Equatable {
  const Creator({
    required this.id,
    required this.name,
    required this.roles,
    required this.imageUrl,
    required this.description,
  });

  final String id;
  final String name;
  final int roles;
  final String imageUrl;
  final String description;

  factory Creator.fromJson(String str) => Creator.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Creator.fromMap(Map<String, dynamic> json) => Creator(
        id: json["id"],
        name: json["name"],
        roles: json["roles"],
        imageUrl: json["imageUrl"],
        description: json["description"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "roles": roles,
        "imageUrl": imageUrl,
        "description": description,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        roles,
        imageUrl,
        description,
      ];
}

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.activityId,
    required this.comment,
    required this.creator,
    required this.createdAt,
  });

  final String id;
  final String activityId;
  final String comment;
  final Creator creator;
  final DateTime createdAt;

  factory Comment.fromJson(String str) => Comment.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Comment.fromMap(Map<String, dynamic> json) => Comment(
        id: json["id"],
        activityId: json["activityId"],
        comment: json["comment"],
        creator: Creator.fromMap(json["creator"]),
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "activityId": activityId,
        "comment": comment,
        "creator": creator.toMap(),
        "createdAt": createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        activityId,
        comment,
        creator,
        createdAt,
      ];
}

class ReqActivity {
  ReqActivity({
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.creator,
  });

  final String title;
  final String description;
  final String videoUrl;
  final Creator creator;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "title": title,
        "description": description,
        "videoUrl": videoUrl,
        "creator": creator.toMap(),
      };
}

class ReqComment {
  ReqComment({
    required this.activityId,
    required this.comment,
    required this.creator,
  });

  final String activityId;
  final String comment;
  final Creator creator;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "activityId": activityId,
        "comment": comment,
        "creator": creator.toMap(),
      };
}
