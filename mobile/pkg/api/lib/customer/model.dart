// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:api/common.dart';
import 'package:api/price_list/model.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class Business extends Equatable {
  final Location location;
  final PriceList priceList;
  final BusinessCustomer customer;
  final BusinessPic pic;
  final List<BusinessAddress> address;
  final int viewer;
  final Credit credit;
  final Tax? tax;
  const Business({
    this.location = const Location(),
    this.priceList = const PriceList(),
    this.customer = const BusinessCustomer(),
    this.pic = const BusinessPic(),
    this.address = const [],
    this.viewer = 0,
    this.credit = const Credit(),
    this.tax,
  });

  Business copyWith({
    Location? location,
    PriceList? priceList,
    BusinessCustomer? customer,
    BusinessPic? pic,
    List<BusinessAddress>? address,
    int? viewer,
    Credit? credit,
    Tax? tax,
  }) {
    return Business(
      location: location ?? this.location,
      priceList: priceList ?? this.priceList,
      customer: customer ?? this.customer,
      pic: pic ?? this.pic,
      address: address ?? this.address,
      viewer: viewer ?? this.viewer,
      credit: credit ?? this.credit,
      tax: tax ?? this.tax,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'location': location.toMap(),
      'priceList': priceList.toMap(),
      'customer': customer.toMap(),
      'pic': pic.toMap(),
      'address': address.map((x) => x.toMap()).toList(),
      'viewer': viewer,
      'credit': credit.toMap(),
      'tax': tax?.toMap(),
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
      priceList: PriceList.fromMap(map['priceList'] as Map<String, dynamic>),
      customer: BusinessCustomer.fromMap(map['customer'] as Map<String, dynamic>),
      pic: BusinessPic.fromMap(map['pic'] as Map<String, dynamic>),
      address: List<BusinessAddress>.from(
        (map['address'] as List<dynamic>).map<BusinessAddress>(
          (x) => BusinessAddress.fromMap(x as Map<String, dynamic>),
        ),
      ),
      viewer: map['viewer'] as int,
      credit: Credit.fromMap(map['credit'] as Map<String, dynamic>),
      tax: map['tax'] != null ? Tax.fromMap(map['tax'] as Map<String, dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Business.fromJson(String source) => Business.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      location,
      priceList,
      customer,
      pic,
      address,
      viewer,
      credit,
      tax,
    ];
  }
}

class Customer extends Equatable {
  final String id;
  final String phone;
  final String email;
  final String name;
  final String imageUrl;
  final Business? business;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Customer({
    this.id = '',
    this.phone = '',
    this.email = '',
    this.name = '',
    this.imageUrl = '',
    this.business,
    this.createdAt,
    this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? imageUrl,
    Business? business,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      business: business ?? this.business,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phone': phoneChange(phone),
      'email': email,
      'name': name,
      'imageUrl': imageUrl,
      'business': business?.toMap(),
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      business: map['business'] != null ? Business.fromMap(map['business'] as Map<String, dynamic>) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) => Customer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      email,
      name,
      imageUrl,
      business,
      createdAt,
      updatedAt,
    ];
  }
}

class ReqCustomer {
  final String phone;
  final String email;
  final String name;
  ReqCustomer({
    required this.phone,
    required this.email,
    required this.name,
  });

  ReqCustomer copyWith({
    String? phone,
    String? email,
    String? name,
  }) {
    return ReqCustomer(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone': phoneChange(phone),
      'email': email,
      'name': name,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'ReqCustomer(phone: $phone, email: $email, name: $name)';
}

class Apply extends Equatable {
  final String id;
  final Location location;
  final PriceList priceList;
  final ApplyCustomer customer;
  final BusinessPic pic;
  final List<BusinessAddress> address;
  final int viewer;
  final Credit creditProposal;
  final Credit creditActual;
  final Tax? tax;
  final int transactionLastMonth;
  final int transactionPerMonth;
  final List<ApplyUserApprover> userApprover;

  /// 1. new business
  /// 2. new limit
  final int type;

  /// 0. pending
  /// 1. waiting limit
  /// 2. waiting approve
  /// 3. waiting id
  /// 4. approve
  /// 5. reject
  final int status;

  final DateTime? expiredAt;
  final DateTime? updatedAt;
  const Apply({
    this.id = '',
    this.location = const Location(),
    this.priceList = const PriceList(),
    this.customer = const ApplyCustomer(),
    this.pic = const BusinessPic(),
    this.address = const [],
    this.viewer = 0,
    this.creditProposal = const Credit(),
    this.creditActual = const Credit(),
    this.tax,
    this.transactionLastMonth = 0,
    this.transactionPerMonth = 0,
    this.userApprover = const [],
    this.type = 0,
    this.status = 0,
    this.expiredAt,
    this.updatedAt,
  });

  Apply copyWith({
    String? id,
    Location? location,
    PriceList? priceList,
    ApplyCustomer? customer,
    BusinessPic? pic,
    List<BusinessAddress>? address,
    int? viewer,
    Credit? creditProposal,
    Credit? creditActual,
    Tax? tax,
    int? transactionLastMonth,
    int? transactionPerMonth,
    List<ApplyUserApprover>? userApprover,
    int? type,
    int? status,
    DateTime? expiredAt,
  }) {
    return Apply(
      id: id ?? this.id,
      location: location ?? this.location,
      priceList: priceList ?? this.priceList,
      customer: customer ?? this.customer,
      pic: pic ?? this.pic,
      address: address ?? this.address,
      viewer: viewer ?? this.viewer,
      creditProposal: creditProposal ?? this.creditProposal,
      creditActual: creditActual ?? this.creditActual,
      tax: tax ?? this.tax,
      transactionLastMonth: transactionLastMonth ?? this.transactionLastMonth,
      transactionPerMonth: transactionPerMonth ?? this.transactionPerMonth,
      userApprover: userApprover ?? this.userApprover,
      type: type ?? this.type,
      status: status ?? this.status,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'location': location.toMap(),
      'priceList': priceList.toMap(),
      'customer': customer.toMap(),
      'pic': pic.toMap(),
      'address': address.map((x) => x.toMap()).toList(),
      'viewer': viewer,
      'creditProposal': creditProposal.toMap(),
      'creditActual': creditActual.toMap(),
      'tax': tax?.toMap(),
      'transactionLastMonth': transactionLastMonth,
      'transactionPerMonth': transactionPerMonth,
      'userApprover': userApprover.map((x) => x.toMap()).toList(),
      'type': type,
      'status': status,
      'expiredAt': expiredAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory Apply.fromMap(Map<String, dynamic> map) {
    return Apply(
      id: map['id'] as String,
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
      priceList: PriceList.fromMap(map['priceList'] as Map<String, dynamic>),
      customer: ApplyCustomer.fromMap(map['customer'] as Map<String, dynamic>),
      pic: BusinessPic.fromMap(map['pic'] as Map<String, dynamic>),
      address: List<BusinessAddress>.from(
        (map['address'] as List<dynamic>).map<BusinessAddress>(
          (x) => BusinessAddress.fromMap(x as Map<String, dynamic>),
        ),
      ),
      viewer: map['viewer'] as int,
      creditProposal: Credit.fromMap(map['creditProposal'] as Map<String, dynamic>),
      creditActual: Credit.fromMap(map['creditActual'] as Map<String, dynamic>),
      tax: map['tax'] != null ? Tax.fromMap(map['tax'] as Map<String, dynamic>) : null,
      transactionLastMonth: map['transactionLastMonth'] as int,
      transactionPerMonth: map['transactionPerMonth'] as int,
      userApprover: List<ApplyUserApprover>.from(
        (map['userApprover'] as List<dynamic>).map<ApplyUserApprover>(
          (x) => ApplyUserApprover.fromMap(x as Map<String, dynamic>),
        ),
      ),
      type: map['type'] as int,
      status: map['status'] as int,
      expiredAt: map['expiredAt'] != null ? DateTime.parse(map['expiredAt']).toLocal() : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Apply.fromJson(String source) => Apply.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  List<ApplyUserApprover> get user => userApprover.where((element) {
        if (element.status == 2) {
          return element.note.isNotEmpty;
        }
        return element.status != 0 || element.note.isNotEmpty;
      }).toList();

  bool isNotMe(String id) {
    if (!user.map((e) => e.id).contains(id)) return true;
    return user.firstWhere((element) => element.id == id).status != 1;
  }

  @override
  List<Object?> get props {
    return [
      id,
      location,
      priceList,
      customer,
      pic,
      address,
      viewer,
      creditProposal,
      creditActual,
      tax,
      transactionLastMonth,
      transactionPerMonth,
      userApprover,
      type,
      status,
      expiredAt,
    ];
  }
}

class UpdateBusiness {
  final Location location;
  final BusinessPic pic;
  final List<BusinessAddress> address;
  final int viewer;
  final Tax? tax;
  UpdateBusiness({
    this.location = const Location(),
    this.pic = const BusinessPic(),
    this.address = const [],
    this.viewer = 0,
    this.tax,
  });

  UpdateBusiness copyWith({
    Location? location,
    BusinessPic? pic,
    List<BusinessAddress>? address,
    int? viewer,
    Tax? tax,
  }) {
    return UpdateBusiness(
      location: location ?? this.location,
      pic: pic ?? this.pic,
      address: address ?? this.address,
      viewer: viewer ?? this.viewer,
      tax: tax ?? this.tax,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'location': location.toMap(),
      'pic': pic.toMap(),
      'address': address.map((x) => x.toMap()).toList(),
      'viewer': viewer,
      'tax': tax?.toMap(),
    };
  }

  factory UpdateBusiness.fromMap(Map<String, dynamic> map) {
    return UpdateBusiness(
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
      pic: BusinessPic.fromMap(map['pic'] as Map<String, dynamic>),
      address: List<BusinessAddress>.from(
        (map['address'] as List<dynamic>).map<BusinessAddress>(
          (x) => BusinessAddress.fromMap(x as Map<String, dynamic>),
        ),
      ),
      viewer: map['viewer'] as int,
      tax: map['tax'] != null ? Tax.fromMap(map['tax'] as Map<String, dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateBusiness.fromJson(String source) => UpdateBusiness.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UpdateBusiness(location: $location, pic: $pic, address: $address, viewer: $viewer, tax: $tax)';
  }

  @override
  bool operator ==(covariant UpdateBusiness other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.location == location && other.pic == pic && listEquals(other.address, address) && other.viewer == viewer && other.tax == tax;
  }

  @override
  int get hashCode {
    return location.hashCode ^ pic.hashCode ^ address.hashCode ^ viewer.hashCode ^ tax.hashCode;
  }
}

class ApplyUserApprover extends Equatable {
  final String id;
  final String phone;
  final String email;
  final String name;
  final String imageUrl;
  final String fcmToken;
  final String note;
  final int roles;

  /// 0. Pending
  ///
  /// 1. waiting approve
  ///
  /// 2. approve
  ///
  /// 3. reject
  ///
  final int status;
  final DateTime? updatedAt;
  const ApplyUserApprover({
    this.id = '',
    this.phone = '',
    this.email = '',
    this.name = '',
    this.imageUrl = '',
    this.fcmToken = '',
    this.note = '',
    this.roles = 0,
    this.status = 0,
    this.updatedAt,
  });

  @override
  List<Object?> get props {
    return [
      id,
      phone,
      email,
      name,
      imageUrl,
      fcmToken,
      note,
      roles,
      status,
      updatedAt,
    ];
  }

  ApplyUserApprover copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? imageUrl,
    String? fcmToken,
    String? note,
    int? roles,
    int? status,
    DateTime? updatedAt,
  }) {
    return ApplyUserApprover(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      note: note ?? this.note,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phone': phoneChange(phone),
      'email': email,
      'name': name,
      'imageUrl': imageUrl,
      'fcmToken': fcmToken,
      'note': note,
      'roles': roles,
      'status': status,
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory ApplyUserApprover.fromMap(Map<String, dynamic> map) {
    return ApplyUserApprover(
      id: map['id'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      fcmToken: map['fcmToken'] as String,
      note: (map['note'] as String),
      roles: map['roles'] as int,
      status: map['status'] as int,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApplyUserApprover.fromJson(String source) => ApplyUserApprover.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}

class ReqApproval {
  ReqApproval({
    required this.id,
    required this.note,
    required this.team,
    required this.priceList,
    required this.creditProposal,
    required this.userApprover,
  });

  final String id;
  final String note;
  final int team;
  final PriceList priceList;
  final Credit creditProposal;
  final List<ApplyUserApprover> userApprover;

  // String toJson([bool isApprove = true]) => json.encode(toMap(isApprove));

  // Map<String, dynamic> toMap(bool isApprove) {
  //   final Map<String, dynamic> map = {
  //     "id": id,
  //     "note": note,
  //     "userApprover": List<dynamic>.from(userApprover.map((x) => x.toMap())),
  //   };
  //   if (isApprove) {
  //     map.addAll({
  //       "team": team,
  //       "creditProposal": creditProposal.toMap(),
  //     });
  //   }
  //   return map;
  // }

  Map<String, dynamic> toMap(bool isApprove) {
    final Map<String, dynamic> map = {
      'id': id,
      'note': note,
      'userApprover': userApprover.map((x) => x.toMap()).toList(),
    };

    if (isApprove) {
      map.addAll({
        'team': team,
        'priceList': priceList.toBusiness(),
        'creditProposal': creditProposal.toMap(),
      });
    }

    return map;
  }

  String toJson([bool isApprove = true]) => json.encode(toMap(isApprove));
}

class ReqApply extends Equatable {
  const ReqApply({
    this.location = const Location(),
    this.priceList = const PriceList(),
    this.customer = const BusinessCustomer(),
    this.pic = const BusinessPic(),
    this.address = const [],
    this.viewer = 0,
    this.creditProposal = const Credit(),
    this.tax,
    this.transactionLastMonth = 0,
    this.transactionPerMonth = 0,
  });

  final Location location;
  final PriceList priceList;
  final BusinessCustomer customer;
  final BusinessPic pic;
  final List<BusinessAddress> address;
  final int viewer;
  final Credit creditProposal;
  final Tax? tax;
  final int transactionLastMonth;
  final int transactionPerMonth;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "location": location.toMap(),
        "priceList": priceList.toBusiness(),
        "customer": customer.toMap(),
        "pic": pic.toMap(),
        "address": List<dynamic>.from(address.map((x) => x.toMap())),
        "viewer": viewer,
        "creditProposal": creditProposal.toMap(),
        "tax": tax?.toMap(),
        "transactionLastMonth": transactionLastMonth,
        "transactionPerMonth": transactionPerMonth,
      };

  @override
  List<Object?> get props {
    return [
      location,
      priceList,
      customer,
      pic,
      address,
      viewer,
      creditProposal,
      tax,
      transactionLastMonth,
      transactionPerMonth,
    ];
  }

  ReqApply copyWith({
    Location? location,
    PriceList? priceList,
    BusinessCustomer? customer,
    BusinessPic? pic,
    List<BusinessAddress>? address,
    int? viewer,
    Credit? creditProposal,
    Tax? tax,
    int? transactionLastMonth,
    int? transactionPerMonth,
  }) {
    return ReqApply(
      location: location ?? this.location,
      priceList: priceList ?? this.priceList,
      customer: customer ?? this.customer,
      pic: pic ?? this.pic,
      address: address ?? this.address,
      viewer: viewer ?? this.viewer,
      creditProposal: creditProposal ?? this.creditProposal,
      tax: tax ?? this.tax,
      transactionLastMonth: transactionLastMonth ?? this.transactionLastMonth,
      transactionPerMonth: transactionPerMonth ?? this.transactionPerMonth,
    );
  }
}

class BusinessCustomer extends Equatable {
  final String id;
  final String idCardPath;
  final String idCardNumber;
  final String address;
  const BusinessCustomer({
    this.id = '',
    this.idCardPath = '',
    this.idCardNumber = '',
    this.address = '',
  });

  BusinessCustomer copyWith({
    String? id,
    String? idCardPath,
    String? idCardNumber,
    String? address,
  }) {
    return BusinessCustomer(
      id: id ?? this.id,
      idCardPath: idCardPath ?? this.idCardPath,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'idCardPath': idCardPath});
    result.addAll({'id': id});
    result.addAll({'idCardNumber': idCardNumber});
    result.addAll({'address': address});

    return result;
  }

  factory BusinessCustomer.fromMap(Map<String, dynamic> map) {
    return BusinessCustomer(
      idCardPath: map['idCardPath'] ?? '',
      id: map['id'] ?? '',
      idCardNumber: map['idCardNumber'] ?? '',
      address: map['address'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessCustomer.fromJson(String source) => BusinessCustomer.fromMap(json.decode(source));

  @override
  String toString() => 'BusinessCustomer(idCardPath: $idCardPath, idCardNumber: $idCardNumber, address: $address)';

  @override
  List<Object> get props => [idCardPath, idCardNumber, address, id];
}

class BusinessPic extends Equatable {
  final String idCardPath;
  final String idCardNumber;
  final String name;
  final String phone;
  final String email;
  final String address;
  const BusinessPic({
    this.idCardPath = '',
    this.idCardNumber = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  BusinessPic copyWith({
    String? idCardPath,
    String? idCardNumber,
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return BusinessPic(
      idCardPath: idCardPath ?? this.idCardPath,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'idCardPath': idCardPath});
    result.addAll({'idCardNumber': idCardNumber});
    result.addAll({'name': name});
    result.addAll({'phone': phoneChange(phone)});
    result.addAll({'email': email});
    result.addAll({'address': address});

    return result;
  }

  factory BusinessPic.fromMap(Map<String, dynamic> map) {
    return BusinessPic(
      idCardPath: map['idCardPath'] ?? '',
      idCardNumber: map['idCardNumber'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessPic.fromJson(String source) => BusinessPic.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BusinessPic(idCardPath: $idCardPath, idCardNumber: $idCardNumber, name: $name, phone: $phone, email: $email, address: $address)';
  }

  @override
  List<Object> get props {
    return [
      idCardPath,
      idCardNumber,
      name,
      phone,
      email,
      address,
    ];
  }
}

class BusinessCreator extends Equatable {
  final String id;
  final String name;
  final int roles;
  final String imageUrl;
  const BusinessCreator({
    this.id = '',
    this.name = '',
    this.roles = 0,
    this.imageUrl = '',
  });

  BusinessCreator copyWith({
    String? id,
    String? name,
    int? roles,
    String? imageUrl,
  }) {
    return BusinessCreator(
      id: id ?? this.id,
      name: name ?? this.name,
      roles: roles ?? this.roles,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'roles': roles});
    result.addAll({'imageUrl': imageUrl});

    return result;
  }

  factory BusinessCreator.fromMap(Map<String, dynamic> map) {
    return BusinessCreator(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      roles: map['roles']?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessCreator.fromJson(String source) => BusinessCreator.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BusinessCreator(id: $id, name: $name, roles: $roles, imageUrl: $imageUrl)';
  }

  @override
  List<Object> get props => [id, name, roles, imageUrl];
}

class BusinessAddress extends Equatable {
  final String name;
  final List<double> lngLat;
  const BusinessAddress({
    this.name = '',
    this.lngLat = const [],
  });

  double get lat => lngLat.last;
  double get lng => lngLat.first;

  BusinessAddress copyWith({
    String? name,
    List<double>? lngLat,
  }) {
    return BusinessAddress(
      name: name ?? this.name,
      lngLat: lngLat ?? this.lngLat,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'lngLat': lngLat});

    return result;
  }

  factory BusinessAddress.fromMap(Map<String, dynamic> map) {
    return BusinessAddress(
      name: map['name'] ?? '',
      lngLat: List<double>.from(map['lngLat']),
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessAddress.fromJson(String source) => BusinessAddress.fromMap(json.decode(source));

  @override
  String toString() => 'BusinessAddress(name: $name, lngLat: $lngLat)';

  @override
  List<Object> get props => [name, lngLat];
}

class Credit extends Equatable {
  final double limit;
  final int term;
  final int termInvoice;
  final double used;
  const Credit({
    this.limit = 0,
    this.term = 0,
    this.termInvoice = 0,
    this.used = 0,
  });

  Credit copyWith({
    double? limit,
    int? term,
    int? termInvoice,
    double? used,
  }) {
    return Credit(
      limit: limit ?? this.limit,
      term: term ?? this.term,
      termInvoice: termInvoice ?? this.termInvoice,
      used: used ?? this.used,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'used': used});
    result.addAll({'limit': limit});
    result.addAll({'term': term});
    result.addAll({'termInvoice': termInvoice});

    return result;
  }

  factory Credit.fromMap(Map<String, dynamic> map) {
    return Credit(
      limit: map['limit']?.toDouble() ?? 0,
      term: map['term']?.toInt() ?? 0,
      termInvoice: map['termInvoice']?.toInt() ?? 0,
      used: map['used']?.toDouble() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Credit.fromJson(String source) => Credit.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Credit(limit: $limit, term: $term, termInvoice: $termInvoice, used: $used)';
  }

  @override
  List<Object> get props => [limit, term, termInvoice, used];
}

class Tax extends Equatable {
  ///Isi dengan integer
  ///0 Sunday
  ///....
  ///6 Saturday
  final int exchangeDay;
  final String legalityPath;

  ///Isi dengan integer
  ///
  ///0 = NON PKP
  ///1 = PKP
  final int type;
  const Tax({
    this.exchangeDay = 0,
    this.legalityPath = '',
    this.type = 0,
  });

  Tax copyWith({
    int? exchangeDay,
    String? legalityPath,
    int? type,
  }) {
    return Tax(
      exchangeDay: exchangeDay ?? this.exchangeDay,
      legalityPath: legalityPath ?? this.legalityPath,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'exchangeDay': exchangeDay});
    result.addAll({'legalityPath': legalityPath});
    result.addAll({'type': type});

    return result;
  }

  factory Tax.fromMap(Map<String, dynamic> map) {
    return Tax(
      exchangeDay: map['exchangeDay']?.toInt() ?? 0,
      legalityPath: map['legalityPath'] ?? '',
      type: map['type']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tax.fromJson(String source) => Tax.fromMap(json.decode(source));

  @override
  String toString() => 'Tax(exchangeDay: $exchangeDay, legalityPath: $legalityPath, type: $type)';

  @override
  List<Object> get props => [exchangeDay, legalityPath, type];
}

class Location extends Equatable {
  const Location({
    this.regionId = '',
    this.regionName = '',
    this.branchId = '',
    this.branchName = '',
  });

  final String regionId;
  final String regionName;
  final String branchId;
  final String branchName;

  factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Location.fromMap(Map<String, dynamic> json) => Location(
        regionId: json["regionId"],
        regionName: json["regionName"],
        branchId: json["branchId"],
        branchName: json["branchName"],
      );

  Map<String, dynamic> toMap() => {
        "regionId": regionId,
        "regionName": regionName,
        "branchId": branchId,
        "branchName": branchName,
      };

  @override
  List<Object?> get props => [
        regionId,
        regionName,
        branchId,
        branchName,
      ];
}

class ApplyCustomer extends Equatable {
  final String idCardPath;
  final String idCardNumber;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String imageUrl;

  const ApplyCustomer({
    this.idCardPath = '',
    this.idCardNumber = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.imageUrl = '',
  });

  @override
  List<Object> get props {
    return [
      idCardPath,
      idCardNumber,
      name,
      phone,
      email,
      address,
      imageUrl,
    ];
  }

  ApplyCustomer copyWith({
    String? idCardPath,
    String? idCardNumber,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? imageUrl,
  }) {
    return ApplyCustomer(
      idCardPath: idCardPath ?? this.idCardPath,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCardPath': idCardPath,
      'idCardNumber': idCardNumber,
      'name': name,
      'phone': phoneChange(phone),
      'email': email,
      'address': address,
      'imageUrl': imageUrl,
    };
  }

  factory ApplyCustomer.fromMap(Map<String, dynamic> map) {
    return ApplyCustomer(
      idCardPath: map['idCardPath'] as String,
      idCardNumber: map['idCardNumber'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApplyCustomer.fromJson(String source) => ApplyCustomer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
