import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  factory Storage() => instance;
  Storage._();
  static final Storage instance = Storage._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  TaskState get error => TaskState.error;
  TaskState get success => TaskState.success;

  late UploadTask uploadTask;

  void uploadPhoto({required String ref, required File file}) {
    uploadTask = _storage.ref(ref).putFile(file);
    return;
  }

  Stream<TaskSnapshot> get taskEvents => uploadTask.snapshotEvents;
}
