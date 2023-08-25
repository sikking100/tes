import 'package:common/common.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/presentation/page/page_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animatedProvider = StateNotifierProvider<Animated, bool>((ref) {
  return Animated(false);
});

class Animated extends StateNotifier<bool> {
  Animated(state) : super(state) {
    init();
  }

  void init() {
    Future.delayed(const Duration(seconds: 2)).then((value) => state = true);
  }
}

class ViewLogin extends ConsumerWidget {
  const ViewLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(animatedProvider);
    final auth = ref.watch(authProvider);
    return Login(
      imageUrl: "newlogo.png",
      textEditingController: ref.read(authProvider.notifier).phoneNumber,
      isReady: res,
      login: () => ref.read(authProvider.notifier).login().catchError(
            (e) => myAlert(context, errorText: e.toString()),
          ),
      isLoading: auth,
    );
    // return LoginWidget(
    //   res: res,
    //   onPressed: ref.read(authProvider).login,
    // );
  }
}

// class LoginWidget extends StatefulWidget {
//   final bool res;
//   final Function(String) onPressed;
//   const LoginWidget({Key? key, required this.res, required this.onPressed}) : super(key: key);

//   @override
//   State<LoginWidget> createState() => _LoginWidgetState();
// }

// class _LoginWidgetState extends State<LoginWidget> {
//   final TextEditingController phoneNumber = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     phoneNumber.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: mPrimaryColor,
//       child: Stack(
//         children: [
//           AnimatedPositioned(
//             top: widget.res ? 200 : MediaQuery.of(context).size.height * 40 / 100,
//             duration: const Duration(milliseconds: 800),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: Center(
//                 child: Image.asset('assets/logo.png'),
//               ),
//             ),
//           ),
//           AnimatedPositioned(
//             bottom: widget.res ? 0 : -1000,
//             duration: const Duration(milliseconds: 800),
//             child: Container(
//               padding: const EdgeInsets.all(25),
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(25),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Masuk dengan Nomor HP',
//                     style: Theme.of(context).textTheme.subtitle1,
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: phoneNumber,
//                     keyboardType: TextInputType.phone,
//                     textInputAction: TextInputAction.done,
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.zero,
//                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//                       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//                       fillColor: mTextfieldLoginColor,
//                       alignLabelWithHint: true,
//                       prefixIcon: Container(
//                         margin: const EdgeInsets.only(right: 10),
//                         padding: const EdgeInsets.all(15),
//                         decoration: const BoxDecoration(
//                           color: mTextfieldLoginNumberColor,
//                           borderRadius: BorderRadiusDirectional.only(
//                             topStart: Radius.circular(30),
//                             bottomStart: Radius.circular(30),
//                           ),
//                         ),
//                         child: Text(
//                           '+62',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                       ),
//                       filled: true,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     '6 digit OTP akan dikirim ke HP Anda\nuntuk verifikasi',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.caption,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       try {
//                         widget.onPressed(phoneNumber.text);
//                       } catch (e) {
//                         showDialog(
//                           context: context,
//                           builder: (_) => AlertDialog(
//                             title: const Text('Oops'),
//                             content: Text(e.toString()),
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(MediaQuery.of(context).size.width, 48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: SizedBox(width: MediaQuery.of(context).size.width, child: const Center(child: Text('Login'))),
//                   ),
//                   const SizedBox(height: 50),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class ViewLogin extends StatefulWidget {
//   final VoidCallback callback;
//   const ViewLogin({Key? key, required this.callback}) : super(key: key);

//   @override
//   State<ViewLogin> createState() => _ViewLoginState();
// }

// class _ViewLoginState extends State<ViewLogin> with SingleTickerProviderStateMixin {
//   bool isReady = false;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1)).then((value) => setState(() => isReady = true));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: mPrimaryColor,
//       child: Stack(
//         children: [
//           AnimatedPositioned(
//             top: isReady ? 200 : MediaQuery.of(context).size.height * 40 / 100,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: Center(
//                 child: Image.asset('assets/logo.png'),
//               ),
//             ),
//             duration: const Duration(milliseconds: 800),
//           ),
//           AnimatedPositioned(
//             bottom: isReady ? 0 : -1000,
//             child: Container(
//               padding: const EdgeInsets.all(25),
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(25),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Masuk dengan Nomor HP',
//                     style: Theme.of(context).textTheme.subtitle1,
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     keyboardType: TextInputType.phone,
//                     textInputAction: TextInputAction.done,
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.zero,
//                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//                       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
//                       fillColor: mTextfieldLoginColor,
//                       alignLabelWithHint: true,
//                       prefixIcon: Container(
//                         margin: const EdgeInsets.only(right: 10),
//                         padding: const EdgeInsets.all(15),
//                         decoration: const BoxDecoration(
//                           color: mTextfieldLoginNumberColor,
//                           borderRadius: BorderRadiusDirectional.only(
//                             topStart: Radius.circular(30),
//                             bottomStart: Radius.circular(30),
//                           ),
//                         ),
//                         child: Text(
//                           '+62',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                       ),
//                       filled: true,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     '6 digit OTP akan dikirim ke HP Anda\nuntuk verifikasi',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.caption,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: widget.callback,
//                     child: SizedBox(width: MediaQuery.of(context).size.width, child: const Center(child: Text('Login'))),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(MediaQuery.of(context).size.width, 48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 50),
//                 ],
//               ),
//             ),
//             duration: const Duration(milliseconds: 800),
//           )
//         ],
//       ),
//     );
//   }
// }
