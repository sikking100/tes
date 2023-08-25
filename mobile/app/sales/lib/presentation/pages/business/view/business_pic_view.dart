import 'dart:io';

import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/business/provider/business_create_provider.dart';
import 'package:sales/presentation/pages/business/provider/ktp_provider.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';

class BusinessPicView extends ConsumerWidget {
  const BusinessPicView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(businessCreateSatetNotifier.notifier);
    final stateWatchNotifier = ref.watch(businessCreateSatetNotifier.notifier);
    final stateWatch = ref.watch(businessCreateSatetNotifier);
    final imageRead = ref.read(imageParamProvider.notifier);
    final imageWatch = ref.watch(imageParamProvider);
    final isSameAsOwner = ref.watch(isSameAsOwnerProvider);

    RegExp regexEmailvalid = RegExp(
      r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final reg = ref.watch(ktpRecognitionStateNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(Dimens.px16),
      children: [
        CheckboxListTile(
          title: const Text('Sama dengan profil pemilik'),
          value: isSameAsOwner,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onChanged: (v) {
            stateRead.isSame(ref, v!);
          },
        ),
        InkWell(
          onTap: () async {
            try {
              final result = await reg.getImage();
              File file = File(result.path);
              final ktp = await reg.setKtpRecognition(file);
              if (ktp.nik.isNotEmpty) {
                imageRead.setImagePic(file);
                stateRead.setState(
                  stateWatch.copyWith(
                    pic: stateWatch.pic.copyWith(
                      idCardPath: result.path,
                      idCardNumber: ktp.nik,
                      name: ktp.name,
                    ),
                  ),
                );
                stateRead.picNik.text = ktp.nik;
                stateRead.picName.text = ktp.name;
                stateRead.picAddress.text = ktp.address;
              }
            } catch (e) {
              AppScaffoldMessanger.showSnackBar(
                  context: context, message: e.toString());
            }
          },
          child: Builder(builder: (context) {
            if (imageWatch.imagePic.path.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.px12),
                child: Image.file(
                  File(imageWatch.imagePic.path),
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
          controller: stateRead.picNik,
          readOnly: stateWatchNotifier.picNik.text == '' ? true : false,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'NIK',
            hintText: 'Masukkan NIK',
            suffixIcon: Icon(
                stateWatchNotifier.picNik.text == "" ? Icons.lock : Icons.edit),
          ),
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                pic: stateWatch.pic.copyWith(
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
          keyboardType: TextInputType.text,
          controller: stateRead.picName,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nama PIC',
            hintText: 'Masukkan nama PIC',
            suffixIcon: Icon(Icons.edit),
          ),
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                pic: stateWatch.pic.copyWith(
                  name: value,
                ),
              ),
            );
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Nama PIC tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: stateRead.picAddress,
          textInputAction: TextInputAction.done,
          maxLines: 5,
          minLines: 1,
          decoration: const InputDecoration(
            labelText: 'Alamat PIC',
            hintText: 'Masukkan alamat PIC',
            suffixIcon: Icon(Icons.edit),
          ),
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                pic: stateWatch.pic.copyWith(
                  address: value,
                ),
              ),
            );
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Alamat PIC tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          controller: stateRead.picPhone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nomor Telepon PIC',
            hintText: 'Masukkan nomor telepon PIC',
            suffixIcon: Icon(Icons.edit),
          ),
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                pic: stateWatch.pic.copyWith(
                  phone: value,
                ),
              ),
            );
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Nomor telepon PIC tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: Dimens.px20),
        TextFormField(
          controller: stateRead.picEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Email PIC',
            hintText: 'Masukkan email PIC',
            suffixIcon: Icon(Icons.edit),
          ),
          onChanged: (value) {
            stateRead.setState(
              stateWatch.copyWith(
                pic: stateWatch.pic.copyWith(
                  email: value,
                ),
              ),
            );
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Email PIC tidak boleh kosong';
            }

            if (!regexEmailvalid.hasMatch(
              value,
            )) {
              return 'Email PIC tidak valid';
            }

            return null;
          },
        ),
      ],
    );
  }
}
