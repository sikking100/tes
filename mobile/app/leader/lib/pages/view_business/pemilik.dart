import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leader/ktp.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_business_add.dart';
import 'package:leader/pages/view_business/usaha.dart';
import 'package:leader/storage.dart';

final getImageFirebase = FutureProvider.autoDispose.family<String, String>((_, arg) => Storages.instance.getImageUrl(arg));

class ViewBusinessPemilik extends ConsumerWidget {
  const ViewBusinessPemilik({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingImageProvider);
    final fileKtp = ref.watch(businessStateProvider.notifier).fileKtp;
    final state = ref.watch(businessStateProvider.notifier);
    final formKeys = ref.watch(formKeyProvider);

    DecorationImage images() {
      if (fileKtp != null) {
        return DecorationImage(
          fit: BoxFit.cover,
          image: FileImage(fileKtp),
        );
      }

      return const DecorationImage(
        image: AssetImage('assets/ktp.png'),
        fit: BoxFit.cover,
      );
    }

    return Column(
      children: [
        Expanded(
          child: Form(
            key: formKeys,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () async {
                    try {
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
                        ref.read(businessStateProvider.notifier).pemilikNik.clear();

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
                      state.setFileKtp(File(crops?.path ?? picker.path));

                      if (nikResult.contains(':')) {
                        final lastWithoutColon = nikResult.split(':').last.trim();
                        String withoutNIK;
                        if (lastWithoutColon.contains('NIK')) {
                          withoutNIK = lastWithoutColon.split('NIK').first;
                        } else {
                          withoutNIK = lastWithoutColon;
                        }

                        ref.read(businessStateProvider.notifier).pemilikNik.text = withoutNIK;
                        ref.read(loadingImageProvider.notifier).update((_) => false);
                      } else {
                        ref.read(businessStateProvider.notifier).pemilikNik.text = nikResult.split('NIK').last.trim();
                        ref.read(loadingImageProvider.notifier).update((_) => false);
                      }
                      if (alamatResult.contains(':')) {
                        final lastWithoutColon = alamatResult.split(':').last.trim();
                        String withoutAlamat;
                        if (lastWithoutColon.contains('Alamat')) {
                          withoutAlamat = lastWithoutColon.split('Alamat').first;
                        } else {
                          withoutAlamat = lastWithoutColon;
                        }
                        state.pemilikAlamat.text = withoutAlamat;
                      } else {
                        state.pemilikAlamat.text = alamatResult.split('Alamat').last.trim();
                      }

                      if (nameResult.contains(':')) {
                        final lastWithoutColon = nameResult.split(':').last.trim();
                        String withoutName;
                        if (lastWithoutColon.contains('Nama')) {
                          withoutName = lastWithoutColon.split('Nama').first;
                        } else {
                          withoutName = lastWithoutColon;
                        }
                        state.pemilikNama.text = withoutName;
                      } else {
                        state.pemilikNama.text = nameResult.split('Nama').last.trim();
                      }
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.amber,
                      image: images(),
                    ),
                    child: loading ? const Center(child: CircularProgressIndicator.adaptive()) : null,
                  ),
                ),
                const SizedBox(height: 15),
                const Text('NIK Pemilik'),
                Consumer(
                  builder: (context, ref, child) {
                    final node = ref.watch(keyboardProvider(context));

                    return TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'tidak boleh kosong';
                        if (value.length < 16) return 'Nik harus 16 angka';
                        if (int.tryParse(value) == null) return 'Pastikan semua angka';
                        return null;
                      },
                      controller: state.pemilikNik,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(),
                      ),
                      maxLength: 16,
                      focusNode: node,
                      keyboardType: TextInputType.number,
                      onChanged: (v) async {
                        if (v.length == 16) {
                          // if (!ktpString.contains(v)) {
                          //   await myAlert(context, errorText: 'Nik tidak sama!');
                          // }
                        }
                      },
                    );
                  },
                ),
                // const SizedBox(height: 15),
                // const Text('Nama Pemilik'),
                // TextField(
                //   controller: state.pemilikNama,
                //   decoration: const InputDecoration(
                //     focusedBorder: UnderlineInputBorder(),
                //   ),
                // ),
                // const SizedBox(height: 15),
                const Text('Nomor HP'),
                Consumer(
                  builder: (context, ref, child) {
                    final node = ref.watch(keyboardProvider(context));

                    return TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'tidak boleh kosong';
                        if (int.tryParse(value) == null) return 'Pastikan semua angka';
                        return null;
                      },
                      focusNode: node,
                      controller: state.pemilikPhone,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    );
                  },
                ),
                const SizedBox(height: 15),
                const Text('Email'),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'tidak boleh kosong';
                    if (!value.contains('@')) return 'Masukkan email yang benar';
                    return null;
                  },
                  controller: state.pemilikEmail,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
