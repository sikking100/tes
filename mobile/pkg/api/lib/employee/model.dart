import 'dart:convert';

import 'package:api/api.dart';
import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String phone;
  final String email;
  final String name;
  final String imageUrl;

  ///UserRoles
  /// 1 sys admin
  ///
  /// 2 finanace admin
  ///
  /// 3 sales admin
  ///
  /// 4 warehouse admin
  ///
  /// 5 branch admin
  ///
  /// 6 branch finance admin
  ///
  /// 7 branch sales admin
  ///
  /// 8 branch warehouse admin
  ///
  /// 9 dir
  ///
  /// 10 gm
  ///
  /// 11 nsm
  ///
  /// 12 rm
  ///
  /// 13 am
  ///
  /// 14 sales
  ///
  /// 15 courier
  final int roles;
  final LocationEmployee? location;

  /// 0 : NO TEAM
  /// 1 : FOOD SERVICE
  /// 2 : RETAIL
  final int team;
  final String fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Employee({
    this.id = '',
    this.phone = '',
    this.email = '',
    this.name = '',
    this.imageUrl = '',
    this.roles = 0,
    this.location,
    this.team = 0,
    this.fcmToken = '',
    this.createdAt,
    this.updatedAt,
  });

  Employee copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? imageUrl,
    int? roles,
    LocationEmployee? location,
    int? team,
    List<Category>? category,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      roles: roles ?? this.roles,
      location: location ?? this.location,
      team: team ?? this.team,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'phone': phone});
    result.addAll({'email': email});
    result.addAll({'name': name});
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'roles': roles});
    if (location != null) {
      result.addAll({'location': location!.toMap()});
    }
    result.addAll({'team': team});
    result.addAll({'fcmToken': fcmToken});
    if (createdAt != null) {
      result.addAll({'createdAt': createdAt!.millisecondsSinceEpoch});
    }
    if (updatedAt != null) {
      result.addAll({'updatedAt': updatedAt!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      roles: map['roles']?.toInt() ?? 0,
      location: map['location'] != null ? LocationEmployee.fromMap(map['location']) : null,
      team: map['team']?.toInt() ?? 0,
      fcmToken: map['fcmToken'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Employee.fromJson(String source) => Employee.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Employee(id: $id, phone: $phone, email: $email, name: $name, imageUrl: $imageUrl, roles: $roles, location: $location, team: $team, fcmToken: $fcmToken, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      email,
      name,
      imageUrl,
      roles,
      location,
      team,
      fcmToken,
      createdAt,
      updatedAt,
    ];
  }
}

class ReqEmployee {
  ReqEmployee({
    required this.phone,
    required this.email,
    required this.name,
  });

  final String phone;
  final String email;
  final String name;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "phone": phone,
        "email": email,
        "name": name,
      };

  ReqEmployee copyWith({
    String? phone,
    String? email,
    String? name,
  }) =>
      ReqEmployee(
        phone: phone ?? this.phone,
        email: email ?? this.email,
        name: name ?? this.name,
      );
}

class LocationEmployee extends Equatable {
  final String id;
  final String name;

  /// 1 region
  /// 2 branch
  final int type;
  const LocationEmployee({
    this.id = '',
    this.name = '',
    this.type = 0,
  });

  LocationEmployee copyWith({
    String? id,
    String? name,
    int? type,
  }) {
    return LocationEmployee(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'type': type});

    return result;
  }

  factory LocationEmployee.fromMap(Map<String, dynamic> map) {
    return LocationEmployee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationEmployee.fromJson(String source) => LocationEmployee.fromMap(json.decode(source));

  @override
  String toString() => 'LocationEmployee(id: $id, name: $name, type: $type)';

  @override
  List<Object> get props => [id, name, type];
}
