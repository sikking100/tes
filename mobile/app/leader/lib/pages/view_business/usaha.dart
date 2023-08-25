import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leader/argument.dart';
import 'package:leader/pages/page_business_add.dart';
import 'package:leader/routes.dart';

final formKeyProvider = Provider.autoDispose<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

class ViewBusinessUsaha extends ConsumerWidget {
  const ViewBusinessUsaha({super.key});

  DecorationImage images(bool loading, File? fileUsaha) {
    if (fileUsaha == null) {
      return const DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage('assets/usaha.png'),
      );
    } else {
      return DecorationImage(
        fit: BoxFit.cover,
        image: FileImage(fileUsaha),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingImageProvider);
    final fileUsaha = ref.watch(businessStateProvider.notifier).fileUsaha;
    final state = ref.read(businessStateProvider.notifier);
    final formKeys = ref.watch(formKeyProvider);

    return Column(
      children: [
        Expanded(
          child: Form(
            key: formKeys,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (picker != null) {
                          state.setFileKtp(File(picker.path), isUsaha: true);
                          return;
                        }
                        return;
                      } catch (e) {
                        ref.read(loadingImageProvider.notifier).update((_) => false);
                        Alerts.dialog(context, content: e.toString());
                        return;
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height / upgradAccountHeight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey,
                        image: images(loading, fileUsaha),
                      ),
                      child: loading ? const Center(child: CircularProgressIndicator.adaptive()) : Container(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Nama Usaha'),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'tidak boleh kosong';
                      return null;
                    },
                    // controller: state.usahaNama,
                    initialValue: state.usahaNama,
                    onChanged: state.changeName,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Alamat Usaha'),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.map,
                        arguments: ArgMap(
                          action: (v) {
                            state.usahaAlamat.text = v.name;
                          },
                        ),
                      );
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        validator: (value) {
                          if (MediaQuery.of(context).viewInsets.bottom > 0) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                          if (value == null || value.isEmpty) return 'tidak boleh kosong';
                          return null;
                        },
                        controller: state.usahaAlamat,
                        decoration: const InputDecoration(suffixIcon: Icon(Icons.location_on), disabledBorder: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Alamat Pengantaran'),
                  GestureDetector(
                    onTap: () async {
                      if (MediaQuery.of(context).viewInsets.bottom > 0) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                      try {
                        final result = await Navigator.pushNamed(context, Routes.businessListAddress,
                            arguments: ArgBusinessListAddress(ref.watch(businessStateProvider.notifier).shippingAddress)) as List<BusinessAddress>?;

                        if (result != null) {
                          (result);
                          ref.read(businessStateProvider.notifier).shippingAddress.clear();
                          ref.read(businessStateProvider.notifier).shippingAddress.addAll(result);
                          state.shippingCount.text = result.length.toString();
                        }
                        return;
                      } catch (e) {
                        Alerts.dialog(context, content: '$e');
                        return;
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'tidak boleh kosong';
                          if (value == '0') return 'Alamat pengantaran minimal 1';
                          return null;
                        },
                        // enabled: false,
                        controller: state.shippingCount,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ElevatedButton(
        //   onPressed: () async {
        //     final result = await Navigator.pushNamed(context, Routes.businessAddress,
        //         arguments: ArgBusinessListAddress(ref.watch(businessStateProvider.notifier).shippingAddress ?? [])) as List<Address>?;

        //     if (result != null) {
        //       (result);
        //       ref.read(businessStateProvider.notifier).shippingAddress?.clear();
        //       ref.read(businessStateProvider.notifier).shippingAddress?.addAll(result);
        //     }
        //   },
        //   child: Text(state.shippingAddress != null ? 'Edit Alamat Pengantaran' : 'Tambah Alamat Pengantaran'),
        // )
      ],
    );
  }
}
