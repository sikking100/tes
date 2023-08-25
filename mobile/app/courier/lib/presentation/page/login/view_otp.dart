import 'dart:async';

import 'package:common/common.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/presentation/page/page_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpNotifier extends StateNotifier<int> {
  OtpNotifier(int state) : super(state) {
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  late Timer _timer;

  void init() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state > 0) {
          state -= 1;
          return;
        } else {
          _timer.cancel();
        }
      },
    );
  }

  void reset() {
    state = 60;
  }
}

final otpNotifierProvider = StateNotifierProvider.autoDispose<OtpNotifier, int>((ref) {
  return OtpNotifier(60);
});

class ViewOtp extends ConsumerWidget {
  const ViewOtp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(otpNotifierProvider);
    final auth = ref.watch(authProvider);
    return Otp(
      verifikasi: () => ref.read(authProvider.notifier).loginVerify().catchError((e) => myAlert(context, errorText: e.toString())),
      resend: () => ref.read(authProvider.notifier).login(),
      back: () => ref.read(authStateProvider.notifier).update((state) => 0),
      textEditingController: ref.watch(authProvider.notifier).otp,
      countDown: res,
      isLoading: auth,
    );

    // return OtpWidget(
    //   counter: res.toString(),
    //   onPressed: ref.read(authProvider).loginVerify,
    // );
  }
}

// class OtpWidget extends StatefulWidget {
//   final String counter;
//   final Function(String) onPressed;
//   const OtpWidget({Key? key, required this.counter, required this.onPressed}) : super(key: key);

//   @override
//   State<OtpWidget> createState() => _OtpWidgetState();
// }

// class _OtpWidgetState extends State<OtpWidget> {
//   final TextEditingController otp = TextEditingController();
//   @override
//   void dispose() {
//     super.dispose();
//     otp.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Kode OTP telah terkirim',
//               style: Theme.of(context).textTheme.headline5,
//             ),
//             const SizedBox(height: 50),
//             Text(
//               'Masukkan Kode',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             const SizedBox(height: 30),
//             PinCodeTextField(
//               controller: otp,
//               appContext: context,
//               length: 6,
//               autoDisposeControllers: false,
//               onChanged: (value) {},
//               keyboardType: TextInputType.number,
//               textInputAction: TextInputAction.done,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               pinTheme: PinTheme(
//                 shape: PinCodeFieldShape.circle,
//                 inactiveFillColor: mTextfieldLoginColor,
//                 inactiveColor: mTextfieldLoginColor,
//                 selectedColor: mPrimaryColor,
//                 selectedFillColor: mPrimaryColor,
//                 activeColor: mPrimaryColor,
//                 activeFillColor: mPrimaryColor,
//               ),
//             ),
//             const SizedBox(height: 30),
//             Text(
//               'Anda akan menerima sms kode OTP\npada nomor yang telah dimasukkan',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.caption,
//             ),
//             const SizedBox(height: 50),
//             Text(
//               widget.counter,
//               style: Theme.of(context).textTheme.headline5,
//             ),
//             const SizedBox(height: 50),
//             ElevatedButton(
//               onPressed: () {
//                 try {
//                   widget.onPressed(otp.text);
//                 } catch (e) {
//                   showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                             content: Text(e.toString()),
//                           ));
//                 }
//               },
//               child: const Text('Verifikasi'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(MediaQuery.of(context).size.width, 48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
