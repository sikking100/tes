import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:customer/argument.dart';
import 'package:customer/pages/business_detail.dart';
import 'package:customer/routes.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final formKeyProvider = Provider.autoDispose<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

class ViewBusinessUsaha extends ConsumerWidget {
  const ViewBusinessUsaha({super.key});

  DecorationImage images(bool loading, File? fileUsaha, Customer customer) {
    if (loading) {
      if (fileUsaha == null) {
        return DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage((customer.imageUrl).toString()),
        );
      }

      return DecorationImage(
        fit: BoxFit.cover,
        image: FileImage(fileUsaha),
      );
    }
    if (customer.business == null && fileUsaha == null) {
      return const DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage('assets/usaha.png'),
      );
    }
    if (customer.business == null && fileUsaha != null) {
      return DecorationImage(
        fit: BoxFit.cover,
        image: FileImage(fileUsaha),
      );
    }

    if (fileUsaha != null) {
      return DecorationImage(
        fit: BoxFit.cover,
        image: FileImage(fileUsaha),
      );
    }

    return DecorationImage(
      image: NetworkImage(customer.imageUrl),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingImageProvider);
    final fileUsaha = ref.watch(businessStateProvider.notifier).fileUsaha;
    final state = ref.watch(businessStateProvider.notifier);
    final customer = ref.watch(businessStateProvider.notifier).customer;
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
                        if (customer.business != null) {
                          await showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Lihat Gambar'),
                                  onTap: () {
                                    Navigator.popAndPushNamed(
                                      context,
                                      Routes.photoView,
                                      arguments: ArgPhotoView((customer.imageUrl).toString(), false),
                                    );
                                    return;
                                  },
                                ),
                                ListTile(
                                  title: const Text('Ganti Gambar'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                                    if (picker != null) {
                                      state.setFileKtp(File(picker.path), isUsaha: true);
                                    }
                                    return;
                                  },
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (picker != null) {
                          state.setFileKtp(File(picker.path), isUsaha: true);
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
                        image: images(loading, fileUsaha, customer),
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
                    enabled: customer.business == null,
                    initialValue: state.usahaNama,
                    // controller: state.usahaNama,
                    onChanged: state.changeName,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Alamat Usaha'),
                  GestureDetector(
                    onTap: customer.business == null
                        ?
                        // ? () async {
                        //     if (MediaQuery.of(context).viewInsets.bottom > 0) {
                        //       FocusManager.instance.primaryFocus?.unfocus();
                        //     }
                        //     final result = await Navigator.pushNamed(context, Routes.mapPick) as BusinessAddress?;
                        //     if (result != null) {
                        //       state.usahaAlamat.text = result.name;
                        //     }
                        //   }
                        () => Navigator.pushNamed(context, Routes.mapPick,
                            arguments: ArgMap(
                              action: (v) => state.usahaAlamat.text = v.name,
                            ))
                        : () {},
                    child: AbsorbPointer(
                      child: TextFormField(
                        validator: (value) {
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
                      try {
                        if (MediaQuery.of(context).viewInsets.bottom > 0) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                        final result = await Navigator.pushNamed(context, Routes.businessAddress,
                            arguments: ArgBusinessListAddress(ref.watch(businessStateProvider.notifier).shippingAddress)) as List<BusinessAddress>?;

                        if (result != null) {
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
