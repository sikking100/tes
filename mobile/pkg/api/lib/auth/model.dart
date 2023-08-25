import 'dart:convert';

import 'package:api/common.dart';

class ReqLogin {
  ReqLogin({
    required this.app,
    required this.fcmToken,
    required this.phone,
  });

  ///Ambil di class ApplicationType
  final int app;
  final String fcmToken;
  final String phone;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "app": app,
        "fcmToken": fcmToken,
        "phone": phoneChange(phone),
      };
}

class ReqVerify {
  ReqVerify({
    required this.id,
    required this.otp,
  });

  final String id;
  final String otp;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "id": id,
        "otp": otp,
      };
}
