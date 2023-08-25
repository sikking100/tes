import 'dart:io';

import 'package:api/customer/model.dart';
import 'package:common/constant/constant.dart';
import 'package:common/widget/alert.dart';
import 'package:customer/argument.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:customer/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imageStateProvider = StateProvider.autoDispose<File?>((_) {
  return null;
});

final processProvider = StateProvider.autoDispose<double>((_) {
  return 0.0;
});

class PageProfile extends HookConsumerWidget {
  const PageProfile({super.key});

  Future onPressed(BuildContext context, TextEditingController name, TextEditingController email, TextEditingController phone, WidgetRef ref,
      Customer customer) async {
    final img = ref.watch(imageStateProvider);
    if (img == null && email.text == customer.email && phone.text == customer.phone && name.text == customer.name) return;
    ref.read(loadingProvider.notifier).update((__) => true);
    await ref.read(apiProvider).customer.update(ReqCustomer(phone: phone.text, email: email.text, name: name.text));
    if (img != null) {
      final refs = Storage.instance.path(ref: 'customer/${customer.id}/', file: img);
      Storage.instance.uploadPhoto(ref: refs, file: img);
      await for (final v in Storage.instance.taskEvents) {
        ref.read(processProvider.notifier).update((state) => v.bytesTransferred / v.totalBytes);
        if (v.state == Storage.instance.success) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mengupload foto')));
          break;
        }
        if (v.state == Storage.instance.error) {
          throw 'Error upload image';
        }
      }
    }
    await Future.delayed(const Duration(seconds: 5));
    final c = await ref.read(apiProvider).customer.byId(customer.id);
    ref.read(customerStateProvider.notifier).update((_) => c);
    ref.invalidate(processProvider);
    ref.read(loadingProvider.notifier).update((_) => false);
    if (context.mounted) Alerts.dialog(context, content: 'Berhasil mengubah profile', title: 'Sukses');
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imageStateProvider);
    final node = ref.watch(keyboardProvider(context));
    final customer = ref.watch(customerStateProvider);
    final name = useTextEditingController(text: customer.name);
    final email = useTextEditingController(text: customer.email);
    final phone = useTextEditingController(text: customer.phone);
    final loading = ref.watch(loadingProvider);
    final process = ref.watch(processProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(Dimens.px16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (defaultTargetPlatform == TargetPlatform.iOS) {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (c) => CupertinoActionSheet(
                              actions: [
                                CupertinoActionSheetAction(
                                  child: Text('Kamera', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
                                  onPressed: () async {
                                    final result = await ImagePicker().pickImage(source: ImageSource.camera);
                                    if (result != null) {
                                      ref.read(imageStateProvider.notifier).state = File(result.path);
                                    }
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: Text('Galeri', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
                                  onPressed: () async {
                                    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
                                    if (result != null) {
                                      ref.read(imageStateProvider.notifier).state = File(result.path);
                                    }
                                  },
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          );
                          return;
                        }

                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListTileTheme(
                            horizontalTitleGap: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_outlined),
                                  title: const Text('Kamera'),
                                  onTap: () async {
                                    try {
                                      final result = await ImagePicker().pickImage(source: ImageSource.camera);

                                      if (result != null) {
                                        ref.read(imageStateProvider.notifier).state = File(result.path);
                                      }
                                      return;
                                    } catch (e) {
                                      await Alerts.dialog(context, content: e.toString());
                                      return;
                                    } finally {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                                ListTile(
                                  onTap: () async {
                                    try {
                                      final result = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if (result != null) {
                                        ref.read(imageStateProvider.notifier).state = File(result.path);
                                      }
                                      return;
                                    } catch (e) {
                                      await Alerts.dialog(context, content: e.toString());
                                      return;
                                    } finally {
                                      Navigator.pop(context);
                                    }
                                  },
                                  leading: const Icon(Icons.image_outlined),
                                  title: const Text('Galeri'),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      child: image != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(image),
                              radius: 64,
                              child: process > 0.0 && process < 1.0
                                  ? CircularProgressIndicator.adaptive(
                                      value: process,
                                    )
                                  : Container(),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(customer.imageUrl),
                              radius: 64,
                            ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: name,
                      decoration: InputDecoration(
                        label: const Text('Nama'),
                        alignLabelWithHint: true,
                        focusedBorder: const UnderlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.phone,
                      controller: phone,
                      focusNode: node,
                      decoration: InputDecoration(
                        label: const Text('Nomor HP'),
                        alignLabelWithHint: true,
                        focusedBorder: const UnderlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      decoration: InputDecoration(
                        label: const Text('Email'),
                        alignLabelWithHint: true,
                        focusedBorder: const UnderlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    customer.business != null
                        ? Container()
                        : SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KONTROL AKUN',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, Routes.businessDetail, arguments: ArgBusinessDetail(first: true)),
                                  style: TextButton.styleFrom(foregroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 5)),
                                  child: const Text(
                                    'Upgrade ke akun Bisnis',
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () => onPressed(context, name, email, phone, ref, customer).catchError((e) => Alerts.dialog(context, content: '$e')),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size(MediaQuery.of(context).size.width, 48),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
