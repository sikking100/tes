import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storages {
  factory Storages() => instance;
  Storages._();
  static final Storages instance = Storages._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  TaskState get error => TaskState.error;
  TaskState get success => TaskState.success;
  TaskState get run => TaskState.running;

  late UploadTask uploadTask;

  String path({required String ref, required File file}) {
    final ext = file.path.split('.').last;
    ref += '${DateTime.now().microsecondsSinceEpoch}.$ext';
    return ref;
  }

  String files({required String ref, required File file}) {
    final ext = file.path.split('/').last;
    ref += ext;
    return ref;
  }

  Future<void> uploadPhoto({required String ref, required File file}) async {
    uploadTask = _storage.ref(ref).putFile(file);
    return;
  }

  Stream<TaskSnapshot> get taskEvents => uploadTask.snapshotEvents;

  Future<String> imageUrl(String ref) async {
    final list = await _storage.ref(ref).listAll();
    return list.items.first.getDownloadURL();
  }

  Future<String> getImageUrl(String ref) async {
    final res = await _storage.ref(ref).getDownloadURL();
    return res;
  }
}
