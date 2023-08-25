import 'package:api/auth/model.dart';
import 'package:api/common.dart';
import 'package:courier/firebase/auth.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/page/login/view_login.dart';
import 'package:courier/presentation/page/login/view_otp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this.ref) : super(false) {
    phoneNumber = TextEditingController();
    otp = TextEditingController();
  }

  late String id;

  late TextEditingController phoneNumber;
  late TextEditingController otp;
  final Ref ref;

  @override
  void dispose() {
    super.dispose();
    phoneNumber.dispose();
    otp.dispose();
  }

  Future login() async {
    try {
      state = true;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final result =
          await ref.read(apiProvider).auth.login(ReqLogin(app: ApplicationType.courier, fcmToken: fcmToken ?? '', phone: phoneNumber.text));
      id = result;
      ref.read(authStateProvider.notifier).state = 1;
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future loginVerify() async {
    try {
      state = true;
      final result = await ref.read(apiProvider).auth.verify(ReqVerify(id: id, otp: otp.text));
      await Auth.instance.signInWithCustomToken(result);
      return;
    } catch (e) {
      throw e.toString();
    } finally {
      state = false;
      phoneNumber.clear();
      otp.clear();
    }
  }
}

final authProvider = StateNotifierProvider.autoDispose<AuthNotifier, bool>(
  (ref) => AuthNotifier(ref),
);

final authStateProvider = StateProvider.autoDispose<int>((_) => 0);

class PageAuth extends ConsumerWidget {
  PageAuth({Key? key}) : super(key: key);
  final page = [
    const ViewLogin(),
    const ViewOtp(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(authStateProvider);
    return Scaffold(
      body: page[res],
    );
  }
}

// class PageLogin extends StatefulWidget {
//   const PageLogin({Key? key}) : super(key: key);

//   @override
//   State<PageLogin> createState() => _PageLoginState();
// }

// class _PageLoginState extends State<PageLogin> {
//   int _index = 0;

//   @override
//   Widget build(BuildContext context) {
//     final _page = [
//       ViewLogin(
//         callback: () => setState(
//           () {
//             _index = 1;
//           },
//         ),
//       ),
//       ViewOtp(
//         callback: () => Navigator.pushNamed(context, Routes.home),
//       ),
//     ];

//     return Scaffold(
//       body: _page[_index],
//     );
//   }
// }
