import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/storage.dart';

final activityNotifierProvider = StateNotifierProvider.autoDispose<ActivityNotifier, bool>(
  (ref) => ActivityNotifier(ref),
);

// final activityProvider = StateNotifierProvider.family<ActivityNotifier, bool, String>((ref, arg) {
//   return  ActivityNotifier(ref, arg);
// });

class ActivityNotifier extends StateNotifier<bool> {
  ActivityNotifier(this.ref) : super(false) {
    emp = ref.read(employeeStateProvider);
    formKey = GlobalKey<FormState>();
    title = TextEditingController();
    description = TextEditingController();
    videoUrl = TextEditingController();
  }

  late Employee emp;
  final AutoDisposeRef ref;
  late final GlobalKey<FormState> formKey;
  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController videoUrl;

  Future add(BuildContext context, File? file) async {
    if (formKey.currentState!.validate()) {
      if (file == null && !videoUrl.text.contains('https://www')) throw 'Url tidak benar, pastikan menggunakan https://www';
      try {
        state = true;
        final req = ReqActivity(
          title: title.text,
          description: description.text,
          videoUrl: videoUrl.text.isEmpty ? 'https://google.com' : videoUrl.text,
          creator: Creator(
            id: emp.id,
            name: emp.name,
            roles: emp.roles,
            imageUrl: emp.imageUrl,
            description: emp.location?.id != null ? emp.location?.name ?? '-' : '-',
          ),
        );
        final result = await ref.read(apiProvider).activity.create(req);
        final f = file;
        if (f != null) {
          final ref = Storages.instance.path(ref: 'activity/${result.id}/', file: f);
          Storages.instance.uploadPhoto(file: f, ref: ref);
          await for (var p in Storages.instance.taskEvents) {
            if (p.state == Storages.instance.success) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menambahkan aktivitas")));
              await Future.delayed(const Duration(seconds: 2));
              return;
            }

            if (p.state == Storages.instance.error) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menambahkan aktivitas")));
              return;
            }
          }
        }

        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menambahkan aktivitas")));
        return;
      } catch (e) {
        throw e.toString();
      } finally {
        state = false;
      }
    }
  }

  void clear() {
    title.clear();
    description.clear();
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    description.dispose();
    videoUrl.dispose();
  }
}

class PageActivityAdd extends ConsumerWidget {
  final File? image;
  const PageActivityAdd({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(activityNotifierProvider);
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Aktivitas'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (image != null) Image.file(image!, width: size.width),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: ref.read(activityNotifierProvider.notifier).formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: ref.read(activityNotifierProvider.notifier).title,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Judul',
                          hintText: 'Masukkan judul aktivitas',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ref.read(activityNotifierProvider.notifier).description,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Keterangan',
                          hintText: 'Masukkan keterangan aktivitas',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Keterangan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (image == null)
                        TextFormField(
                          controller: ref.read(activityNotifierProvider.notifier).videoUrl,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Url Video',
                            hintText: 'Masukkan url video dari youtube',
                          ),
                          validator: (value) {
                            if (image == null && value!.isEmpty) {
                              return 'Keterangan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          SizedBox(
            width: size.width,
            height: 50,
            child: ElevatedButton(
              onPressed: loading == true
                  ? null
                  : () {
                      ref
                          .read(activityNotifierProvider.notifier)
                          .add(
                            context,
                            image,
                          )
                          .then((value) => Navigator.of(context).pop())
                          .catchError((e) => Alerts.dialog(context, content: e.toString()));
                    },
              child: loading == true ? const CircularProgressIndicator.adaptive() : const Text('Posting'),
            ),
          ),
        ],
      ),
    );
  }
}
