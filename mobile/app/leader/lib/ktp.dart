import 'dart:io';

import 'package:path/path.dart' show dirname;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class KtpDataEntityConverter {
  final String? nik;

  KtpDataEntityConverter({this.nik});

  factory KtpDataEntityConverter.from({required nik}) => KtpDataEntityConverter(nik: normalizeNikText(nik));
}

String normalizeNikText(String text) {
  String result = text.toUpperCase();

  result = result.replaceAll('NIK', '').replaceAll(':', '').trim();

  return result;
}

String normalizeNpwpText(String text) {
  String result = text.toUpperCase();

  result = result.replaceAll('NPWP', '').replaceAll(':', '').trim();

  return result;
}

bool checkNikField(String dataText) {
  final text = dataText.toLowerCase().trim();
  return text == 'nik';
}

bool checkAlamat(String dataText) {
  final text = dataText.toLowerCase().trim();
  return text == 'alamat';
}

bool checkName(String dataText) {
  final text = dataText.toLowerCase().trim();
  return text == 'nama';
}

bool checkNpwpField(String dataText) {
  final text = dataText.toLowerCase().trim();
  return text == 'npwp';
}

bool isInside(Rect? rect, Rect? isInside) {
  if (rect == null) {
    return false;
  }

  if (isInside == null) {
    return false;
  }

  if (rect.center.dy <= isInside.bottom && rect.center.dy >= isInside.top && rect.center.dy >= isInside.right) {
    return true;
  }

  return false;
}

bool isInside3Rect({Rect? isThisRect, Rect? isInside, Rect? andAbove}) {
  if (isThisRect == null) {
    return false;
  }

  if (isInside == null) {
    return false;
  }

  if (andAbove == null) {
    return false;
  }

  if (isThisRect.center.dy <= andAbove.top && isThisRect.center.dy >= isInside.top && isThisRect.center.dx >= isInside.left) {
    return true;
  }

  return false;
}

Future<String> getModel(String assetPath) async {
  if (Platform.isAndroid) {
    return 'flutter_assets/$assetPath';
  }
  final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}
