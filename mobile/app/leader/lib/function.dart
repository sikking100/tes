import 'dart:io';

import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

extension ExtDateFormat on DateTime {
  String get toTimeago {
    timeago.setLocaleMessages("id", timeago.IdMessages());
    timeago.setDefaultLocale("id");

    return timeago.format(
      this,
      locale: "id",
      allowFromNow: true,
    );
  }

  String get toCustomFormat {
    return DateFormat("EEEE, dd MMMM yyyy", "id").format(this);
  }

  String get toDDMMMMYYYY {
    return DateFormat("dd MMMM yyyy", "id").format(this);
  }

  String get toDDMMMYYYY {
    return DateFormat("dd MMM yyyy", "id").format(this);
  }

  String get toHHMM {
    return DateFormat("hh:mm a", "id").format(this);
  }

  String get toDDMMMMYYYYHH {
    return DateFormat("EEEE, dd MMMM yyyy  hh:mm a", "id").format(this);
  }
}

Future<File> getImage(ImageSource source) async {
  final ImagePicker imgPicker = ImagePicker();
  final image = await imgPicker.pickImage(source: source);
  if (image != null) {
    final file = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Atur Foto',
          statusBarColor: Colors.white,
          activeControlsWidgetColor: scheme.secondary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (file != null) {
      return File(file.path);
    }
  }

  return Future.error("error");
}

showSnackBar(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: Text(message, textAlign: TextAlign.center),
        shape: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black54,
        elevation: 0.0,
      ),
    );

String gennerateId(String prefix) {
  final suffix = DateTime.now().millisecondsSinceEpoch.toString();
  return '$prefix$suffix';
}

String renameFile(String filePath) {
  String fileExtention = filePath.split('/').last.split('.').last;
  final filename = DateTime.now().millisecondsSinceEpoch.toString();
  return "$filename.$fileExtention";
}
