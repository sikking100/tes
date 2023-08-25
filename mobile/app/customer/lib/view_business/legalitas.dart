import 'dart:io';

import 'package:common/function/function.dart';
import 'package:common/widget/alert.dart';
import 'package:customer/argument.dart';
import 'package:customer/ktp.dart';
import 'package:customer/pages/business_detail.dart';
import 'package:customer/routes.dart';
import 'package:customer/view_business/pemilik.dart';
import 'package:customer/view_business/usaha.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ViewBusinessLegalitas extends ConsumerWidget {
  const ViewBusinessLegalitas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingImageProvider);
    final fileTax = ref.watch(businessStateProvider.notifier).fileTax;
    final state = ref.watch(businessStateProvider.notifier);
    final customer = ref.watch(businessStateProvider.notifier).customer;

    DecorationImage images() {
      if (customer.business != null && customer.business?.tax?.legalityPath != null) {
        final getImage = ref.watch(getImageFirebase(customer.business?.tax?.legalityPath ?? ''));
        if (fileTax == null) {
          return DecorationImage(
            fit: BoxFit.cover,
            image: getImage.when(
              data: (data) => NetworkImage(data),
              error: (error, stackTrace) => const AssetImage('assets/npwp.png'),
              loading: () => const AssetImage('assets/npwp.png'),
            ),
          );
        }
        return DecorationImage(
          fit: BoxFit.cover,
          image: FileImage(fileTax),
        );
      }
      if (fileTax == null) {
        return const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/npwp.png'),
        );
      }

      return DecorationImage(
        image: FileImage(fileTax),
        fit: BoxFit.cover,
      );
    }

    final taxState = [1, 0];
    const List<int> taxDay = [0, 1, 2, 3, 4, 5, 6];

    return Form(
      key: ref.watch(formKeyProvider),
      child: ListView(
        children: [
          GestureDetector(
            onTap: () async {
              try {
                if (customer.business != null && (customer.business?.tax?.legalityPath != null)) {
                  final image = customer.business?.tax?.legalityPath;
                  if (image == null || image.isEmpty || image == '-') return;
                  Navigator.pushNamed(
                    context,
                    Routes.photoView,
                    arguments: ArgPhotoView(customer.business?.tax?.legalityPath ?? '', true),
                  );
                  // await showModalBottomSheet(
                  //   context: context,
                  //   builder: (_) => Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       ListTile(
                  //         title: const Text('Lihat Gambar'),
                  //         onTap: () {
                  //           Navigator.popAndPushNamed(
                  //             context,
                  //             Routes.photoView,
                  //             arguments: ArgPhotoView(customer.business?.tax?.legalityPath ?? '', true),
                  //           );
                  //           return;
                  //         },
                  //       ),
                  //       // ListTile(
                  //       //   title: const Text('Ganti Gambar'),
                  //       //   onTap: () async {
                  //       //     try {
                  //       //       Navigator.pop(context);
                  //       //       final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                  //       //       if (picker == null) return;
                  //       //       ref.read(loadingImageProvider.notifier).update((_) => true);

                  //       //       final crops = await ImageCropper().cropImage(
                  //       //         sourcePath: picker.path,
                  //       //         aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
                  //       //       );

                  //       //       String npwpResult = '';
                  //       //       Rect npwpRect = Offset.zero & Size.zero;
                  //       //       final InputImage inputImage = InputImage.fromFilePath(crops?.path ?? picker.path);
                  //       //       final modelPath = await getModel('assets/model_unquant_metadata.tflite');
                  //       //       final label = ObjectDetector(
                  //       //         options: LocalObjectDetectorOptions(
                  //       //           modelPath: modelPath,
                  //       //           classifyObjects: true,
                  //       //           mode: DetectionMode.single,
                  //       //           multipleObjects: false,
                  //       //         ),
                  //       //       );
                  //       //       final recognizedLabel = await label.processImage(inputImage);
                  //       //       await label.close();

                  //       //       for (var element in recognizedLabel) {
                  //       //         ('label');
                  //       //         (element.boundingBox);
                  //       //         (element.trackingId);
                  //       //         if (element.labels.isEmpty) {
                  //       //           ref.read(loadingImageProvider.notifier).update((_) => false);
                  //       //           throw 'NPWP tidak terdeteksi';
                  //       //         }
                  //       //         for (var el in element.labels) {
                  //       //           (el.text);
                  //       //           (el.confidence);
                  //       //           if (el.text.isEmpty || !el.text.contains('NPWP') || el.confidence < 0.8) {
                  //       //             ref.read(loadingImageProvider.notifier).update((_) => false);
                  //       //             throw 'Mohon foto ulang NPWP Anda - Tidak mengandung NPWP';
                  //       //           }
                  //       //         }
                  //       //       }

                  //       //       final textDetector = TextRecognizer();
                  //       //       final recognizedText = await textDetector.processImage(inputImage);
                  //       //       await textDetector.close();
                  //       //       for (var i in recognizedText.blocks) {
                  //       //         for (var j in i.lines) {
                  //       //           for (var k in j.elements) {
                  //       //             // (k.text.toLowerCase().trim().replaceAll(" ", "") + " " + k.boundingBox.center.toString());
                  //       //             if (checkNpwpField(k.text)) {
                  //       //               npwpRect = k.boundingBox;
                  //       //             }
                  //       //           }
                  //       //         }
                  //       //       }

                  //       //       for (var i in recognizedText.blocks) {
                  //       //         for (var j in i.lines) {
                  //       //           if (isInside(j.boundingBox, npwpRect)) {
                  //       //             npwpResult += j.text;
                  //       //           }
                  //       //         }
                  //       //       }

                  //       //       if (npwpResult.isEmpty) {
                  //       //         ref.read(loadingImageProvider.notifier).update((_) => false);
                  //       //         throw 'Npwp tidak terdeteksi';
                  //       //       }
                  //       //       state.setFileKtp(File(crops?.path ?? picker.path), isNpwp: true);
                  //       //       ref.read(loadingImageProvider.notifier).update((_) => false);

                  //       //       return;
                  //       //     } catch (e) {
                  //       //       ref.read(loadingImageProvider.notifier).update((_) => false);
                  //       //       Alerts.dialog(context, content: e.toString());
                  //       //       return;
                  //       //     }
                  //       //   },
                  //       // ),
                  //     ],
                  //   ),
                  // );
                  return;
                }

                final picker = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picker == null) return;
                ref.read(loadingImageProvider.notifier).update((_) => true);

                final crops = await ImageCropper().cropImage(
                  sourcePath: picker.path,
                  aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
                );

                String npwpResult = '';
                Rect npwpRect = Offset.zero & Size.zero;
                final InputImage inputImage = InputImage.fromFilePath(crops?.path ?? picker.path);
                final modelPath = await getModel('assets/model_unquant_metadata.tflite');
                final label = ObjectDetector(
                  options: LocalObjectDetectorOptions(
                    modelPath: modelPath,
                    classifyObjects: true,
                    mode: DetectionMode.single,
                    multipleObjects: false,
                  ),
                );
                final recognizedLabel = await label.processImage(inputImage);
                await label.close();

                for (var element in recognizedLabel) {
                  if (element.labels.isEmpty) {
                    ref.read(loadingImageProvider.notifier).update((_) => false);
                    throw 'NPWP tidak terdeteksi';
                  }
                  for (var el in element.labels) {
                    if (el.text.isEmpty || !el.text.contains('NPWP') || el.confidence < 0.8) {
                      ref.read(loadingImageProvider.notifier).update((_) => false);

                      throw 'Mohon foto ulang NPWP Anda - Tidak mengandung NPWP';
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
                      if (checkNpwpField(k.text)) {
                        npwpRect = k.boundingBox;
                      }
                    }
                  }
                }

                for (var i in recognizedText.blocks) {
                  for (var j in i.lines) {
                    if (isInside(j.boundingBox, npwpRect)) {
                      npwpResult += j.text;
                    }
                  }
                }

                if (npwpResult.isEmpty) {
                  ref.read(loadingImageProvider.notifier).update((_) => false);

                  throw 'Npwp tidak terdeteksi.  Silakan foto ulang Npwp Anda.';
                }
                state.setFileKtp(File(crops?.path ?? picker.path), isNpwp: true);
                ref.read(loadingImageProvider.notifier).update((_) => false);

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
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.amber, image: images()),
              child: loading ? const Center(child: CircularProgressIndicator.adaptive()) : Container(),
            ),
          ),
          // const SizedBox(height: 15),
          // const Text('NPWP (*jika ada)'),
          // TextField(
          //   controller: state.,
          //   decoration: const InputDecoration(
          //     focusedBorder: UnderlineInputBorder(),
          //   ),
          // ),
          // const SizedBox(height: 15),
          // const Text('Status Faktur'),
          // const SizedBox(height: 5),
          // DropdownButtonFormField<String>(
          //   decoration: InputDecoration(
          //     enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
          //     focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
          //     border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
          //     contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          //   ),
          //   hint: const Text('Pilih Status Faktur'),
          //   items: status
          //       .map(
          //         (e) => DropdownMenuItem<String>(
          //           value: e,
          //           child: Text(e),
          //         ),
          //       )
          //       .toList(),
          //   onChanged: (e) {},
          // ),
          const SizedBox(height: 15),
          const Text('Hari Tukar Faktur (*jika berlaku)'),
          const SizedBox(height: 5),
          DropdownButtonFormField<int>(
            validator: (value) {
              if (fileTax != null && value == null) return 'tidak boleh kosong';
              return null;
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            hint: const Text('Pilih Hari Tukar Faktur'),
            items: taxDay
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e,
                    child: Text(taxExchangeDayString(e)),
                  ),
                )
                .toList(),
            onChanged: (e) {
              if (e == null) return;
              state.taxHari = e;
              return;
            },
            value: state.taxHari,
          ),
          const SizedBox(height: 15),
          const Text('Status Pajak (*jika berlaku)'),
          const SizedBox(height: 5),
          DropdownButtonFormField<int>(
            validator: (value) {
              if (fileTax != null && value == null) return 'tidak boleh kosong';
              return null;
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            hint: const Text('Pilih Status Pajak'),
            items: taxState
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e,
                    child: Text(taxStateString(e)),
                  ),
                )
                .toList(),
            onChanged: (e) {
              if (e == null) return;
              state.taxState = e;
            },
            value: state.taxState,
          ),
        ],
      ),
    );
  }
}
