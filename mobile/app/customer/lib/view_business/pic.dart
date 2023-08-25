import 'dart:io';

import 'package:common/widget/alert.dart';
import 'package:customer/argument.dart';
import 'package:customer/ktp.dart';
import 'package:customer/pages/business_detail.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/routes.dart';
import 'package:customer/view_business/pemilik.dart';
import 'package:customer/view_business/usaha.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ViewBusinessPic extends ConsumerWidget {
  const ViewBusinessPic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkboxValue = ref.watch(isSameStateProvider);
    final loading = ref.watch(loadingImageProvider);
    final filePic = ref.watch(businessStateProvider.notifier).filePic;
    final state = ref.watch(businessStateProvider.notifier);
    final customer = ref.watch(businessStateProvider.notifier).customer;

    DecorationImage images() {
      if (customer.business != null) {
        final getImageKtp = ref.watch(getImageFirebase(customer.business?.pic.idCardPath ?? ''));
        if (filePic == null) {
          return DecorationImage(
            fit: BoxFit.cover,
            image: getImageKtp.when(
              data: (data) => NetworkImage(data),
              error: (error, stackTrace) => const AssetImage('assets/ktp.png'),
              loading: () => const AssetImage('assets/ktp.png'),
            ),
          );
        }
        return DecorationImage(fit: BoxFit.cover, image: FileImage(filePic));
      }
      // if (checkboxValue) {
      //   if (fileKtp != null) {
      //     return DecorationImage(
      //       fit: BoxFit.cover,
      //       image: FileImage(fileKtp),
      //     );
      //   }
      //   return DecorationImage(
      //     fit: BoxFit.cover,
      //     image: getImageKtp.when(
      //       data: (data) => NetworkImage(data),
      //       error: (error, stackTrace) => const AssetImage('assets/ktp.png'),
      //       loading: () => const AssetImage('assets/ktp.png'),
      //     ),
      //   );
      // }
      // if (filePic == null) {
      //   return const DecorationImage(
      //     fit: BoxFit.cover,
      //     image: AssetImage('assets/ktp.png'),
      //   );
      // }
      if (filePic != null) {
        return DecorationImage(
          fit: BoxFit.cover,
          image: FileImage(filePic),
        );
      }

      return const DecorationImage(
        image: AssetImage('assets/ktp.png'),
        fit: BoxFit.cover,
      );
    }

    return Form(
      key: ref.watch(formKeyProvider),
      child: ListView(
        children: [
          if (customer.business == null)
            CheckboxListTile(
              value: checkboxValue,
              onChanged: (v) {
                (v);
                ref.read(isSameStateProvider.notifier).state = v!;
              },
              title: const Text('Data sama dengan pemilik'),
            ),
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    if (customer.business != null) {
                      await showModalBottomSheet(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('Lihat Gambar'),
                              onTap: () {
                                Navigator.popAndPushNamed(
                                  context,
                                  Routes.photoView,
                                  arguments: ArgPhotoView(customer.business!.pic.idCardPath, true),
                                );
                                return;
                              },
                            ),
                            ListTile(
                              title: const Text('Ganti Gambar'),
                              onTap: () async {
                                try {
                                  Navigator.pop(context);

                                  final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                                  if (picker == null) return;
                                  final crops = await ImageCropper().cropImage(
                                    sourcePath: picker.path,
                                    aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
                                  );

                                  ref.read(loadingImageProvider.notifier).update((_) => true);

                                  String nikResult = '';
                                  String alamatResult = '';
                                  Rect alamatRect = Offset.zero & Size.zero;
                                  Rect nikRect = Offset.zero & Size.zero;
                                  Rect nameRect = Offset.zero & Size.zero;
                                  String nameResult = '';
                                  final InputImage inputImage = InputImage.fromFilePath(crops?.path ?? picker.path);
                                  final modelPath = await getModel('assets/model_unquant_metadata.tflite');
                                  final object = ObjectDetector(
                                    options: LocalObjectDetectorOptions(
                                      modelPath: modelPath,
                                      classifyObjects: true,
                                      mode: DetectionMode.single,
                                      multipleObjects: false,
                                    ),
                                  );
                                  final recognizedObject = await object.processImage(inputImage);
                                  await object.close();

                                  for (var element in recognizedObject) {
                                    state.picNik.clear();
                                    if (element.labels.isEmpty) {
                                      ref.read(loadingImageProvider.notifier).update((_) => false);

                                      throw 'KTP tidak terdeteksi';
                                    }
                                    for (var el in element.labels) {
                                      if (el.text.isEmpty || !el.text.contains('KTP') || el.confidence < 0.8) {
                                        ref.read(loadingImageProvider.notifier).update((_) => false);

                                        throw 'Mohon foto ulang KTP Anda';
                                      }
                                    }
                                  }

                                  final textDetector = TextRecognizer();
                                  final recognizedText = await textDetector.processImage(inputImage);
                                  await textDetector.close();
                                  for (var i in recognizedText.blocks) {
                                    for (var j in i.lines) {
                                      for (var k in j.elements) {
                                        // (k.text.toLowerCase().trim().replaceAll(" ", "") + " " + k.boundingBox.center.toString());
                                        if (checkNikField(k.text)) {
                                          nikRect = k.boundingBox;
                                        }
                                        if (checkAlamat(k.text)) {
                                          alamatRect = k.boundingBox;
                                        }
                                        if (checkName(k.text)) {
                                          nameRect = k.boundingBox;
                                        }
                                      }
                                    }
                                  }
                                  for (var i in recognizedText.blocks) {
                                    for (var j in i.lines) {
                                      if (isInside(j.boundingBox, nikRect)) {
                                        nikResult += j.text;
                                      }
                                      if (isInside(j.boundingBox, alamatRect)) {
                                        alamatResult += j.text;
                                      }
                                      if (isInside(j.boundingBox, nameRect)) {
                                        nameResult += j.text;
                                      }
                                    }
                                  }
                                  if (nikResult.isEmpty) {
                                    ref.read(loadingImageProvider.notifier).update((_) => false);

                                    throw 'NIK tidak terdeteksi.  Silakan foto ulang ktp Anda.';
                                  }

                                  if (nikResult.contains(':')) {
                                    final lastWithoutColon = nikResult.split(':').last.trim();
                                    (lastWithoutColon);
                                    String withoutNIK;
                                    if (lastWithoutColon.contains('NIK')) {
                                      withoutNIK = lastWithoutColon.split('NIK').first;
                                    } else {
                                      withoutNIK = lastWithoutColon;
                                    }
                                    state.picNik.text = withoutNIK;
                                  } else {
                                    state.picNik.text = nikResult.split('NIK').last.trim();
                                  }

                                  if (alamatResult.contains(':')) {
                                    final lastWithoutColon = alamatResult.split(':').last.trim();
                                    String withoutAlamat;
                                    if (lastWithoutColon.contains('Alamat')) {
                                      withoutAlamat = lastWithoutColon.split('Alamat').first;
                                    } else {
                                      withoutAlamat = lastWithoutColon;
                                    }
                                    state.picAlamat.text = withoutAlamat;
                                  } else {
                                    state.picAlamat.text = alamatResult.split('Alamat').last.trim();
                                  }

                                  if (nameResult.contains(':')) {
                                    final lastWithoutColon = nameResult.split(':').last.trim();
                                    String withoutName;
                                    if (lastWithoutColon.contains('Nama')) {
                                      withoutName = lastWithoutColon.split('Nama').first;
                                    } else {
                                      withoutName = lastWithoutColon;
                                    }
                                    state.picNama.text = withoutName;
                                  } else {
                                    state.picNama.text = nameResult.split('Nama').last.trim();
                                  }

                                  state.setFileKtp(File(crops?.path ?? picker.path), isKtpPic: true);
                                  return;
                                } catch (e) {
                                  ref.read(loadingImageProvider.notifier).update((_) => false);

                                  Alerts.dialog(context, content: e.toString());
                                  return;
                                }
                              },
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (picker == null) return;
                    ref.read(loadingImageProvider.notifier).update((_) => true);

                    final crops = await ImageCropper().cropImage(
                      sourcePath: picker.path,
                      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
                    );

                    String nikResult = '';
                    Rect nikRect = Offset.zero & Size.zero;
                    String alamatResult = '';
                    Rect alamatRect = Offset.zero & Size.zero;
                    String nameResult = '';
                    Rect nameRect = Offset.zero & Size.zero;
                    final InputImage inputImage = InputImage.fromFilePath(crops?.path ?? picker.path);
                    final modelPath = await getModel('assets/model_unquant_metadata.tflite');
                    final object = ObjectDetector(
                      options: LocalObjectDetectorOptions(
                        modelPath: modelPath,
                        classifyObjects: true,
                        mode: DetectionMode.single,
                        multipleObjects: false,
                      ),
                    );
                    final recognizedObject = await object.processImage(inputImage);
                    await object.close();

                    for (var element in recognizedObject) {
                      state.picNik.clear();
                      if (element.labels.isEmpty) {
                        ref.read(loadingImageProvider.notifier).update((_) => false);

                        throw 'KTP tidak terdeteksi';
                      }
                      for (var el in element.labels) {
                        if (el.text.isEmpty || !el.text.contains('KTP') || el.confidence < 0.8) {
                          ref.read(loadingImageProvider.notifier).update((_) => false);

                          throw 'Mohon foto ulang KTP Anda';
                        }
                      }
                    }

                    final textDetector = TextRecognizer();
                    final recognizedText = await textDetector.processImage(inputImage);
                    await textDetector.close();
                    for (var i in recognizedText.blocks) {
                      for (var j in i.lines) {
                        for (var k in j.elements) {
                          // (k.text.toLowerCase().trim().replaceAll(" ", "") + " " + k.boundingBox.center.toString());
                          if (checkNikField(k.text)) {
                            nikRect = k.boundingBox;
                          }

                          if (checkAlamat(k.text)) {
                            alamatRect = k.boundingBox;
                          }
                          if (checkName(k.text)) {
                            nameRect = k.boundingBox;
                          }
                        }
                      }
                    }
                    for (var i in recognizedText.blocks) {
                      for (var j in i.lines) {
                        if (isInside(j.boundingBox, nikRect)) {
                          nikResult += j.text;
                        }

                        if (isInside(j.boundingBox, alamatRect)) {
                          alamatResult += j.text;
                        }
                        if (isInside(j.boundingBox, nameRect)) {
                          nameResult += j.text;
                        }
                      }
                    }
                    if (nikResult.isEmpty) {
                      ref.read(loadingImageProvider.notifier).update((_) => false);

                      throw 'NIK tidak terdeteksi.  Silakan foto ulang ktp Anda.';
                    }
                    if (nikResult.contains(':')) {
                      final lastWithoutColon = nikResult.split(':').last.trim();
                      (lastWithoutColon);
                      String withoutNIK;
                      if (lastWithoutColon.contains('NIK')) {
                        withoutNIK = lastWithoutColon.split('NIK').first;
                      } else {
                        withoutNIK = lastWithoutColon;
                      }
                      state.picNik.text = withoutNIK;
                    } else {
                      state.picNik.text = nikResult.split('NIK').last.trim();
                    }

                    if (alamatResult.contains(':')) {
                      final lastWithoutColon = alamatResult.split(':').last.trim();
                      String withoutAlamat;
                      if (lastWithoutColon.contains('Alamat')) {
                        withoutAlamat = lastWithoutColon.split('Alamat').first;
                      } else {
                        withoutAlamat = lastWithoutColon;
                      }
                      state.picAlamat.text = withoutAlamat;
                    } else {
                      state.picAlamat.text = alamatResult.split('Alamat').last.trim();
                    }

                    if (nameResult.contains(':')) {
                      final lastWithoutColon = nameResult.split(':').last.trim();
                      String withoutName;
                      if (lastWithoutColon.contains('Nama')) {
                        withoutName = lastWithoutColon.split('Nama').first;
                      } else {
                        withoutName = lastWithoutColon;
                      }
                      state.picNama.text = withoutName;
                    } else {
                      state.picNama.text = nameResult.split('Nama').last.trim();
                    }

                    state.setFileKtp(File(crops?.path ?? picker.path), isKtpPic: true);
                    ref.read(loadingImageProvider.notifier).update((_) => false);
                    return;
                  } catch (e) {
                    ref.read(loadingImageProvider.notifier).update((_) => false);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(e.toString()),
                      ),
                    );
                    return;
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / upgradAccountHeight,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.amber, image: images()),
                  child: loading ? const Center(child: CircularProgressIndicator.adaptive()) : null,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
          const Text('NIK PIC'),
          Consumer(builder: (context, ref, child) {
            final node = ref.watch(keyboardProvider(context));

            return TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) return 'tidak boleh kosong';
                if (value.length < 16) return 'Nik harus 16 angka';
                if (int.tryParse(value) == null) return 'Pastikan semua angka';
                return null;
              },
              controller: state.picNik,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(),
              ),
              focusNode: node,
              keyboardType: TextInputType.number,
              maxLength: 16,
              enabled: !checkboxValue || state.picNik.text.isEmpty,
              onChanged: (v) async {
                // if (v.length == 16) {
                //   if (!ktpString.contains(v)) {
                //     await myAlert(context, errorText: 'Nik tidak sama!');
                //   }
                // }
              },
            );
          }),
          // const SizedBox(height: 15),
          const Text('Nama PIC'),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) return 'tidak boleh kosong';
              return null;
            },
            controller: state.picNama,
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(),
            ),
            enabled: !checkboxValue || state.picNama.text.isEmpty,
          ),
          const SizedBox(height: 15),
          const Text('Alamat Rumah'),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) return 'tidak boleh kosong';
              return null;
            },
            controller: state.picAlamat,
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          const Text('Nomor HP'),
          Consumer(builder: (context, ref, child) {
            final node = ref.watch(keyboardProvider(context));

            return TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) return 'tidak boleh kosong';
                if (int.tryParse(value) == null) return 'Pastikan semua angka';
                return null;
              },
              focusNode: node,
              controller: state.picPhone,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            );
          }),
          const SizedBox(height: 15),
          const Text('Email'),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) return 'tidak boleh kosong';
              if (!value.contains('@')) return 'Masukkan email yang benar';
              return null;
            },
            controller: state.picEmail,
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
