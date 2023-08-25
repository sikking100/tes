// import 'package:api/common.dart';
// import 'package:equatable/equatable.dart';

// class Activity extends Equatable {
//   const Activity({
//     this.id = '',
//     this.title = '',
//     this.description = '',
//     this.imageUrl = '',
//     this.videoUrl = '',
//     this.createdBy = const CreatedBy(),
//     this.createdAt,
//     this.updatedAt,
//   });

//   final String id;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final String videoUrl;
//   final CreatedBy createdBy;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   factory Activity.fromMap(Map<String, dynamic> json) => Activity(
//         id: json["id"],
//         title: json["title"],
//         description: json["description"],
//         imageUrl: json["imageUrl"],
//         videoUrl: json["videoUrl"],
//         createdBy: CreatedBy.fromMap(json["createdBy"]),
//         createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]).toLocal(),
//         updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]).toLocal(),
//       );

//   @override
//   List<Object?> get props => [id, title, description, imageUrl, videoUrl, createdBy, createdAt, updatedAt];
// }

// class ActivitySave {
//   final String title;

//   ///isi dengan format Branch Name/Region Name/-
//   final String description;
//   final String videoUrl;
//   final CreatedBy createdBy;

//   const ActivitySave({this.title = '', this.description = '', this.videoUrl = '', this.createdBy = const CreatedBy()});

//   Map<String, dynamic> toMap() => {
//         'title': title,
//         'description': description,
//         'videoUrl': videoUrl,
//         'createdBy': createdBy.toActivitySave(),
//       };
// }

// class Comment extends Equatable {
//   const Comment({
//     this.id = '',
//     this.activityId = '',
//     this.createdBy = const CreatedBy(),
//     this.comment = '',
//     this.createdAt,
//   });

//   final String id;
//   final String activityId;
//   final CreatedBy createdBy;
//   final String comment;
//   final DateTime? createdAt;

//   factory Comment.fromMap(Map<String, dynamic> json) => Comment(
//         id: json["id"],
//         activityId: json["activityId"],
//         createdBy: CreatedBy.fromMap(json["createdBy"]),
//         comment: json["comment"],
//         createdAt: DateTime.parse(json["createdAt"]).toLocal(),
//       );

//   @override
//   List<Object?> get props => [id, activityId, createdBy, comment, createdAt];
// }

// class SaveComment {
//   const SaveComment({
//     this.activityId = '',
//     this.createdBy = const CreatedBy(),
//     this.comment = '',
//   });

//   final String activityId;
//   final CreatedBy createdBy;
//   final String comment;

//   Map<String, dynamic> toMap() => {
//         "activityId": activityId,
//         "createdBy": createdBy.toActivitySave(),
//         "comment": comment,
//       };
// }
