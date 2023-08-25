import 'dart:io';

import 'package:courier/common/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/firebase/storage.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:api/api.dart';
import 'package:common/common.dart';

final profileFutureProvider = FutureProvider.autoDispose<Employee>((ref) {
  final id = FirebaseAuth.instance.currentUser?.uid;
  return ref.read(apiProvider).employee.byId(id ?? "");
});

final branchFutureProvider = FutureProvider.autoDispose<Branch>(((ref) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
  final id = token?.claims?['locationId'];
  return ref.read(apiProvider).branch.byId(id);
}));

final profileStateProvider = StateNotifierProvider.autoDispose<ProfileSate, State>((ref) => ProfileSate(false, ref: ref));

@immutable
class State {
  final bool loading;
  final File? file;

  const State(this.loading, this.file);
}

class ProfileSate extends StateNotifier<State> {
  ProfileSate(bool state, {required this.ref}) : super(const State(false, null)) {
    name = TextEditingController();
    phone = TextEditingController();
    email = TextEditingController();
    id = TextEditingController();
    cabang = TextEditingController();
    _picker = ImagePicker();
    init();
  }
  final AutoDisposeRef ref;

  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController email;
  late final TextEditingController id;
  late final TextEditingController cabang;
  late final ImagePicker _picker;
  File? _files;

  void init() async {
    final result = await ref.watch(profileFutureProvider.future);
    name.text = result.name;
    email.text = result.email;
    id.text = result.id;
    phone.text = result.phone;
  }

  Future<void> onClickImage(bool isGalery) async {
    XFile? files;
    if (isGalery) {
      files = await _picker.pickImage(source: ImageSource.gallery);
    } else {
      files = await _picker.pickImage(source: ImageSource.camera);
    }
    if (files != null) {
      _files = File(files.path);
      state = State(false, File(files.path));
    }
    return;
  }

  Future onClick(BuildContext context, {required Employee courier}) async {
    try {
      state = State(true, _files);
      final storage = Storage.instance;
      final ext = state.file?.path.split('/').last.split('.').last;
      final names = DateTime.now().millisecondsSinceEpoch;
      if (_files != null) {
        storage.uploadPhoto(ref: 'employee/${courier.id}/$names.$ext', file: _files!);

        await for (final val in storage.taskEvents) {
          if (val.state == TaskState.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sukses mengupload gambar')));
            return;
          }
        }
        return;
      }
      if (courier.name != name.text || courier.phone != phone.text || courier.email != email.text) {
        await ref.read(apiProvider).employee.update(
              req: ReqEmployee(
                name: name.text.isEmpty ? courier.name : name.text,
                email: email.text.isEmpty ? courier.email : email.text,
                phone: phone.text.isEmpty ? courier.phone : phone.text,
              ),
              id: courier.id,
            );
      }
      return;
    } catch (e) {
      rethrow;
    } finally {
      state = State(false, _files);
    }
  }
}

class PageEditProfile extends ConsumerWidget {
  const PageEditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courier = ref.watch(profileFutureProvider);
    final state = ref.watch(profileStateProvider.notifier);
    final loading = ref.watch(profileStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Akun'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: mPadding,
        child: courier.when(
          data: (data) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, Routes.photoview, arguments: {'img': data.imageUrl}),
                          child: loading.file == null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(data.imageUrl),
                                  radius: 64,
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(loading.file!),
                                  radius: 64,
                                ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: -80,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () => showModalBottomSheet(
                              context: context,
                              builder: (c) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      try {
                                        await ref.read(profileStateProvider.notifier).onClickImage(false);
                                        return;
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(e.toString()),
                                          ),
                                        );
                                      } finally {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    horizontalTitleGap: 0,
                                    leading: const Icon(Icons.camera_alt_outlined),
                                    title: const Text('Camera'),
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      try {
                                        await ref.read(profileStateProvider.notifier).onClickImage(true);
                                        return;
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(e.toString()),
                                          ),
                                        );
                                      } finally {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    horizontalTitleGap: 0,
                                    leading: const Icon(Icons.image_outlined),
                                    title: const Text('Galeri'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: state.id,
                  enabled: false,
                  decoration: const InputDecoration(
                    label: Text('ID'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: 'COURIER'),
                  enabled: false,
                  decoration: const InputDecoration(
                    label: Text('Role'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                ref.watch(branchFutureProvider).when(
                      data: (data) {
                        return Column(
                          children: [
                            // TextField(
                            //   controller:
                            //       TextEditingController(text: data.regionId),
                            //   enabled: false,
                            //   decoration: const InputDecoration(
                            //     label: Text('Region'),
                            //     alignLabelWithHint: true,
                            //   ),
                            // ),
                            // const SizedBox(height: 10),
                            TextField(
                              controller: TextEditingController(text: data.name),
                              enabled: false,
                              decoration: const InputDecoration(
                                label: Text('Cabang'),
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        );
                      },
                      error: (_, e) => TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          label: Text(e.toString()),
                          alignLabelWithHint: true,
                        ),
                      ),
                      loading: () => const LinearProgressIndicator(),
                    ),
                const SizedBox(height: 10),
                TextField(
                  controller: state.name,
                  decoration: const InputDecoration(
                    label: Text('Nama'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: state.phone,
                  decoration: const InputDecoration(
                    label: Text('Nomor Telepon'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: state.email,
                  decoration: const InputDecoration(
                    label: Text('Email'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: loading.loading
                      ? null
                      : () => ref.read(profileStateProvider.notifier).onClick(context, courier: data).then((value) => Navigator.pop(context)).onError(
                            (error, stackTrace) => myAlert(
                              context,
                              errorText: error.toString(),
                            ),
                          ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loading.loading ? const BtnLoading() : const Text('Simpan'),
                )
              ],
            ),
          ),
          error: (_, e) => Center(child: Text(e.toString())),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}
