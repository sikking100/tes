import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/view_auth/login.dart';
import 'package:customer/view_auth/otp.dart';
import 'package:customer/view_auth/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateProvider.autoDispose<int>((_) {
  return 0;
});

final authStateProvider = StateNotifierProvider.autoDispose<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(Ref ref) : super(false) {
    phone = TextEditingController();
    email = TextEditingController();
    name = TextEditingController();
    otp = TextEditingController();
    api = ref.watch(apiProvider);
  }

  late final TextEditingController phone;
  late final TextEditingController email;
  late final TextEditingController name;
  late final TextEditingController otp;
  late final Api api;

  late String id;

  Future<void> login() async {
    try {
      state = true;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      id = await api.auth.login(ReqLogin(app: ApplicationType.customer, fcmToken: fcmToken ?? '', phone: phone.text));
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> verify() async {
    try {
      state = true;
      final result = await api.auth.verify(ReqVerify(id: id, otp: otp.text));
      await FirebaseAuth.instance.signInWithCustomToken(result);
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> register() async {
    try {
      state = true;
      await api.customer.create(ReqCustomer(
        name: name.text,
        email: email.text,
        phone: phone.text,
      ));
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
}

class PageAuth extends StatelessWidget {
  PageAuth({super.key});

  final List<Widget> list = [
    const ViewAuthLogin(),
    const ViewAuthOtp(),
    const ViewAuthRegister(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final res = ref.watch(authProvider);
          return list[res];
        },
      ),
    );
  }
}
