import 'dart:developer';
import 'dart:io';

import 'package:common/constant/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

final ktpRecognitionStateNotifierProvider =
    StateNotifierProvider<KtpRecognition, KtpEntity>(
  (ref) => KtpRecognition(),
);

class KtpEntity extends Equatable {
  final String nik;
  final String name;
  final String address;

  const KtpEntity({
    this.nik = '',
    this.name = '',
    this.address = '',
  });

  @override
  List<Object> get props => [nik, name, address];
}

class KtpRecognition extends StateNotifier<KtpEntity> {
  KtpRecognition() : super(const KtpEntity());

  Future<String> setNpwpRec(File image) async {
    String resultNPWP = '';
    Rect recNPWP = Offset.zero & Size.zero;
    final InputImage inputImage = InputImage.fromFile(image);
    final label = ObjectDetector(
      options: LocalObjectDetectorOptions(
        modelPath: 'flutter_assets/assets/model_unquant_metadata.tflite',
        classifyObjects: true,
        mode: DetectionMode.single,
        multipleObjects: false,
      ),
    );
    final recognizedLabel = await label.processImage(inputImage);
    await label.close();
    for (var element in recognizedLabel) {
      if (element.labels.isEmpty) {
        throw "NPWP tidak terdeteksi";
      }
      for (var el in element.labels) {
        if (el.text.isEmpty ||
            !el.text.contains("NPWP") ||
            el.confidence < 0.8) {
          log(el.text);
          throw "Mohon foto ulang NPWP Anda";
        }
      }
    }
    final textDetector = TextRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    for (var i in recognizedText.blocks) {
      for (var j in i.lines) {
        for (var k in j.elements) {
          if (checkNpwpField(k.text)) {
            recNPWP = k.boundingBox;
          }
        }
      }
    }

    for (var i in recognizedText.blocks) {
      for (var j in i.lines) {
        if (isInside(j.boundingBox, recNPWP)) {
          resultNPWP += j.text;
        }
      }
    }
    if (resultNPWP.isEmpty) {
      throw 'Npwp tidak terdeteksi.  Silakan foto ulang Npwp Anda.';
    }
    return resultNPWP;
  }

  Future<KtpEntity> setKtpRecognition(File image) async {
    String resultNik = '';
    String resultName = '';
    String resultAddress = '';
    Rect rectNik = Offset.zero & Size.zero;
    Rect rectName = Offset.zero & Size.zero;
    Rect rectAddress = Offset.zero & Size.zero;
    final InputImage inputImage = InputImage.fromFile(image);
    final label = ObjectDetector(
      options: LocalObjectDetectorOptions(
        modelPath: 'flutter_assets/assets/model_unquant_metadata.tflite',
        classifyObjects: true,
        mode: DetectionMode.single,
        multipleObjects: false,
      ),
    );
    final recognizedLabel = await label.processImage(inputImage);
    await label.close();
    for (var element in recognizedLabel) {
      if (element.labels.isEmpty) {
        throw "KTP tidak terdeteksi";
      }
      for (var el in element.labels) {
        if (el.text.isEmpty ||
            !el.text.contains("KTP") ||
            el.confidence < 0.8) {
          log(el.text);
          throw "Mohon foto ulang KTP Anda";
        }
      }
    }
    final textDetector = TextRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    for (var i in recognizedText.blocks) {
      for (var j in i.lines) {
        for (var nik in j.elements) {
          if (checkNikField(nik.text)) {
            rectNik = nik.boundingBox;
          }
        }
        for (var name in j.elements) {
          if (checkNameField(name.text)) {
            rectName = name.boundingBox;
          }
        }
        for (var address in j.elements) {
          if (checkAdressField(address.text)) {
            rectAddress = address.boundingBox;
          }
        }
      }
    }
    for (var i in recognizedText.blocks) {
      for (var nik in i.lines) {
        if (isInside(nik.boundingBox, rectNik)) {
          if (nik.text.contains(":")) {
            resultNik = nik.text.split(':').last.replaceFirst(" ", "");
          } else if (nik.text.contains("NIK")) {
            resultNik = nik.text.split(':').last.split('NIK').first.trim();
          } else {
            resultNik = nik.text.replaceFirst(" ", "");
          }
        }
      }
      for (var name in i.lines) {
        if (isInside(name.boundingBox, rectName)) {
          resultName += name.text;
          if (name.text.contains(":")) {
            resultName = name.text.split(':').last;
          } else if (name.text.contains("Nama")) {
            resultName = name.text.split(':').last.split('Nama').first.trim();
          } else {
            resultName = name.text;
          }
        }
      }
      for (var address in i.lines) {
        if (isInside(address.boundingBox, rectAddress)) {
          resultAddress += address.text;
          if (address.text.contains(":")) {
            resultAddress = address.text.split(':').last;
          } else if (address.text.contains("Alamat")) {
            resultAddress =
                address.text.split(':').last.split('Alamat').first.trim();
          } else {
            resultAddress = address.text;
          }
        }
      }
    }
    if (resultNik.isEmpty) {
      throw "Mohon foto ulang KTP Anda";
    }
    return KtpEntity(nik: resultNik, name: resultName, address: resultAddress);
  }

  Future<File> getImage() async {
    final ImagePicker imgPicker = ImagePicker();
    final image = await imgPicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final file = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Foto',
            statusBarColor: theme.primaryColor,
            activeControlsWidgetColor: theme.primaryColor,
          ),
        ],
      );
      if (file != null) {
        return File(file.path);
      }
    }
    throw "Foto tidak ditemukan";
  }

  bool isInside(Rect? rect, Rect? isInside) {
    if (rect == null) {
      return false;
    }

    if (isInside == null) {
      return false;
    }

    if (rect.center.dy <= isInside.bottom &&
        rect.center.dy >= isInside.top &&
        rect.center.dy >= isInside.right) {
      return true;
    }

    return false;
  }

  bool checkNpwpField(String dataText) {
    final text = dataText.toLowerCase().trim();
    return text == 'npwp';
  }

  bool checkNikField(String dataText) {
    final text = dataText.toLowerCase().trim();
    return text == 'nik';
  }

  bool checkAdressField(String dataText) {
    final text = dataText.toLowerCase().trim();
    return text == 'alamat';
  }

  bool checkNameField(String dataText) {
    final text = dataText.toLowerCase().trim();
    return text == 'nama';
  }
}
