import 'dart:async';

import 'package:common/widget/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Otp extends StatelessWidget {
  final bool? isLoading;
  final void Function() verifikasi;
  final void Function() resend;
  final void Function() back;
  final TextEditingController textEditingController;

  /// this field is for countdown
  /// fill this with your value from your state management
  final int countDown;
  const Otp({
    Key? key,
    this.isLoading,
    required this.verifikasi,
    required this.resend,
    required this.back,
    required this.textEditingController,
    required this.countDown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        back();
        return Future.value(false);
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kode OTP telah terkirim',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Masukkan Kode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  PinCodeTextField(
                    appContext: context,
                    autoDisposeControllers: false,
                    controller: textEditingController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Anda akan menerima sms kode OTP\npada nomor yang telah dimasukkan'),
                  const SizedBox(height: 40),
                  if (countDown > 0)
                    Text(
                      countDown.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  else
                    TextButton(
                      onPressed: resend,
                      child: Text(
                        'Kirim Ulang',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  const SizedBox(height: 50),
                  Buttons.primary('Verifikasi', onPressed: verifikasi, isLoading: isLoading),
                ],
              ),
            ),
          ),
          if (defaultTargetPlatform == TargetPlatform.iOS)
            Positioned(top: MediaQuery.of(context).size.width * 5 / 100, left: 10, child: BackButton(onPressed: back))
        ],
      ),
    );
  }
}
