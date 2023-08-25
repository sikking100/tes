import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/storage.dart';
import 'package:image_picker/image_picker.dart';

final fileStateProvider = StateProvider.autoDispose<File?>((_) {
  return;
});

final progressStateProvider = StateProvider.autoDispose<double>((ref) {
  return 0.0;
});

final profileStateNotifierProvider = StateNotifierProvider.autoDispose<ProfileNotifier, bool>((ref) {
  return ProfileNotifier(ref);
});

class ProfileNotifier extends StateNotifier<bool> {
  ProfileNotifier(this.ref) : super(false) {
    employee = ref.watch(employeeStateProvider);
    init();
  }

  init() {
    phone = TextEditingController(text: employee.phone);
    name = TextEditingController(text: employee.name);
    email = TextEditingController(text: employee.email);
    branch = TextEditingController(text: employee.location?.name);
    region = TextEditingController(text: employee.location?.name);
  }

  final AutoDisposeRef ref;
  late final TextEditingController phone;
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController branch;
  late final TextEditingController region;
  late final Employee employee;

  Future save(BuildContext context) async {
    state = true;
    Employee result = employee;
    final image = ref.read(fileStateProvider);
    if (employee.name != name.text || employee.phone != phone.text || employee.email != email.text) {
      result = await ref.read(apiProvider).employee.update(
            id: employee.id,
            req: ReqEmployee(
              email: email.text,
              name: name.text,
              phone: phone.text,
            ),
          );
    }

    if (image != null) {
      final path = Storages.instance.path(ref: 'employee/${result.id}/', file: image);
      Storages.instance.uploadPhoto(ref: path, file: image);
      await for (var u in Storages.instance.taskEvents) {
        if (u.state == Storages.instance.success) {
          ref.read(progressStateProvider.notifier).update((_) => 0.0);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mengupload foto')));
          ref.invalidate(fileStateProvider);
          break;
        }
        if (u.state == Storages.instance.run) {
          final progress = u.bytesTransferred / u.totalBytes;
          ref.read(progressStateProvider.notifier).update((_) => progress);
        }
        if (u.state == Storages.instance.error) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengupload foto')));
          break;
        }
      }
    }
    await Future.delayed(const Duration(seconds: 2));
    final getData = await ref.read(apiProvider).employee.byId(result.id);
    ref.read(employeeStateProvider.notifier).update((state) => getData);
    state = false;
    return;
  }
}

class PageProfile extends ConsumerWidget {
  const PageProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressStateProvider);
    final theme = Theme.of(context);
    final notifier = ref.read(profileStateNotifierProvider.notifier);
    final file = ref.watch(fileStateProvider);
    final loading = ref.watch(profileStateNotifierProvider);
    final node = ref.watch(keyboardProvider(context));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: InkWell(
                        onTap: () {},
                        child: Stack(
                          children: [
                            progress > 0.0
                                ? Container(
                                    height: 120,
                                    width: 120,
                                    decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: Center(
                                      child: CircularProgressIndicator(value: progress),
                                    ),
                                  )
                                : file != null
                                    ? CircleAvatar(
                                        backgroundImage: FileImage(file),
                                        radius: 50,
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(notifier.employee.imageUrl),
                                        radius: 50,
                                      ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  builder: (context) => ListTileTheme(
                                    horizontalTitleGap: 0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt_outlined),
                                          title: const Text('Kamera'),
                                          onTap: () async {
                                            try {
                                              final result = await ImagePicker().pickImage(source: ImageSource.camera);

                                              if (result != null) {
                                                ref.read(fileStateProvider.notifier).update((state) => File(result.path));
                                              }
                                              return;
                                            } catch (e) {
                                              await Alerts.dialog(context, content: e.toString());
                                              return;
                                            } finally {
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            try {
                                              final result = await ImagePicker().pickImage(source: ImageSource.gallery);
                                              if (result != null) {
                                                ref.read(fileStateProvider.notifier).update((state) => File(result.path));
                                              }
                                              return;
                                            } catch (e) {
                                              await Alerts.dialog(context, content: e.toString());
                                              return;
                                            } finally {
                                              Navigator.pop(context);
                                            }
                                          },
                                          leading: const Icon(Icons.image_outlined),
                                          title: const Text('Galeri'),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: theme.scaffoldBackgroundColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: notifier.employee.id,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'ID',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: roleString(notifier.employee.roles),
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                      ),
                    ),
                    notifier.employee.location?.type == 2 ? const SizedBox(height: 10) : const SizedBox(),
                    notifier.employee.location?.type == 2
                        ? TextFormField(
                            controller: notifier.branch,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Cabang',
                            ),
                          )
                        : const SizedBox(),
                    notifier.employee.location?.type == 1 ? const SizedBox(height: 10) : const SizedBox(),
                    notifier.employee.location?.type == 1
                        ? TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Region',
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: teamString(notifier.employee.team),
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Tim',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notifier.name,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      focusNode: node,
                      keyboardType: TextInputType.phone,
                      controller: notifier.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notifier.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
                onPressed: loading
                    ? null
                    : () => notifier.save(context).then(
                          (value) => Alerts.dialog(context, content: 'Sukses mengubah data', title: 'Berhasil')
                              .then((value) => ref.invalidate(profileStateNotifierProvider)),
                        ),
                child: loading ? const CircularProgressIndicator.adaptive() : const Text('Perbarui'))
          ],
        ),
      ),
    );
  }
}
