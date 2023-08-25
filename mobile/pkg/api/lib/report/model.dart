import 'dart:convert';

import 'package:equatable/equatable.dart';

class Report extends Equatable {
  const Report({
    this.id = '',
    this.from = const ReportUser(),
    this.to = const ReportUser(),
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.filePath,
    this.sendDate,
  });

  final String id;
  final ReportUser from;
  final ReportUser to;
  final String title;
  final String description;
  final String imageUrl;
  final String? filePath;
  final DateTime? sendDate;

  factory Report.fromMap(Map<String, dynamic> json) {
    return Report(
      id: json["id"],
      from: ReportUser.fromMap(json["from"]),
      to: ReportUser.fromMap(json["to"]),
      title: json["title"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      filePath: json["filePath"],
      sendDate: DateTime.parse(json["sendDate"]).toLocal(),
    );
  }

  @override
  List<Object?> get props => [id, from, to, title, imageUrl, filePath, sendDate, description];
}

class SaveReport {
  const SaveReport({
    this.to = const ReportUser(),
    this.from = const ReportUser(),
    this.title = '',
    this.description = '',
  });

  final ReportUser to;
  final ReportUser from;
  final String title;
  final String description;

  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        "to": to.toMap(),
        "from": from.toMap(),
        "title": title,
        "description": description,
      };
}

class ReportUser extends Equatable {
  const ReportUser({
    this.id = '',
    this.name = '',
    this.roles = 0,
    this.imageUrl = '',
    this.description = '',
  });

  final String id;
  final String name;
  final int roles;
  final String imageUrl;
  final String description;

  factory ReportUser.fromMap(Map<String, dynamic> json) => ReportUser(
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
  List<Object?> get props => [id, name, roles, imageUrl, description];
}
