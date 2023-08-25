import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  factory Storage() => instance;
  Storage._();
  static final Storage instance = Storage._();

  final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: 'dairy-food-development.appspot.com');

  TaskState get error => TaskState.error;
  TaskState get success => TaskState.success;

  late UploadTask uploadTask;

  String path({required String ref, required File file}) {
    final ext = file.path.split('.').last;
    ref += '${DateTime.now().microsecondsSinceEpoch}.$ext';
    return ref;
  }

  Future<String> uploadPhoto({required String ref, required File file}) async {
    uploadTask = _storage.ref(ref).putFile(file);
    return ref;
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
