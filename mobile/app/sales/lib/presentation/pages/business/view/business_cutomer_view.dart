import 'dart:io';

import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';
import 'package:sales/presentation/pages/business/provider/ktp_provider.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';

class BusinessCustomerView extends ConsumerWidget {
  const BusinessCustomerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(businessCreateSatetNotifier.notifier);
    final stateWatchNotifier = ref.watch(businessCreateSatetNotifier.notifier);
    final stateWatch = ref.watch(businessCreateSatetNotifier);
    final imageRead = ref.read(imageParamProvider.notifier);
    final imageWatch = ref.watch(imageParamProvider);
    final reg = ref.watch(ktpRecognitionStateNotifierProvider.notifier);

    RegExp regexEmailvalid = RegExp(
      r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return ListView(
      padding: const EdgeInsets.all(Dimens.px16),
      children: [
        InkWell(
          onTap: () async {
            try {
              final result = await reg.getImage();
              File file = File(result.path);
              final ktp = await reg.setKtpRecognition(file);
              if (ktp.nik.isNotEmpty) {
                imageRead.setImageUser(File(result.path));
                stateRead.setState(
                  stateWatch.copyWith(
                    customer: stateWatch.customer.copyWith(
                      idCardPath: result.path,
                      idCardNumber: ktp.nik,
                    ),
                  ),
                );
                stateRead.cusNik.text = ktp.nik;
              }
            } catch (e) {
              AppScaffoldMessanger.showSnackBar(
                  context: context, message: e.toString());
            }
          },
          child: Builder(builder: (context) {
            if (imageWatch.imageUser.path.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.px12),
                child: Image.file(
                  File(imageWatch.imageUser.path),
                  height: size.height * 0.3,
                  fit: BoxFit.cover,
                ),
              );
            }

            return Container(
              height: size.height * 0.3,
              decoration: BoxDecoration(
                color: theme.highlightColor,
                borderRadius: BorderRadius.circular(Dimens.px16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_rounded,
                    size: 80,
                    color: Theme.of(context).dividerColor,
                  ),
                  Text(
                    'Unggah foto KTP',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          readOnly: stateWatchNotifier.cusNik.text == "" ? true : false,
          controller: stateRead.cusNik,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'NIK',
            hintText: 'Masukkan NIK',
            suffixIcon: Icon(
                stateWatchNotifier.cusNik.text == "" ? Icons.lock : Icons.edit),
          ),
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                customer: stateWatch.customer.copyWith(
                  idCardNumber: value,
                ),
              ),
            );
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'NIK tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          controller: stateRead.cusPhone,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor Telepon Pemilik',
            hintText: 'Masukkan nomor telepon',
            suffixIcon: Icon(Icons.edit),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Nomor telepon pemilik tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          controller: stateRead.cusEmail,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Pemilik',
            hintText: 'Masukkan email pemilik',
            suffixIcon: Icon(Icons.edit),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Email pemilik tidak boleh kosong';
            }

            if (!regexEmailvalid.hasMatch(
              value,
            )) {
              return 'Email pemilik tidak valid';
            }

            return null;
          },
        ),
      ],
    );
  }
}
