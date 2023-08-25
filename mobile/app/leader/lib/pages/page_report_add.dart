import 'dart:io';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leader/main_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/storage.dart';

final imageStateProvider = StateProvider.autoDispose<File?>((_) {
  return;
});

final fileProvider = StateProvider.autoDispose<File?>((_) {
  return;
});

class PageReportAdd extends ConsumerStatefulWidget {
  const PageReportAdd({super.key, required this.empTo});
  final Employee empTo;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PageReportAddState();
}

class _PageReportAddState extends ConsumerState<PageReportAdd> {
  late Api api;

  bool isLoading = false;

  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;

  @override
  void initState() {
    api = ref.read(apiProvider);
    _formKey = GlobalKey<FormState>();
    _titleCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    super.initState();
  }

  void _sendReport() async {
    final image = ref.read(imageStateProvider);
    final file = ref.read(fileProvider);
    final emp = ref.watch(employeeStateProvider);

    final report = SaveReport(
      from: ReportUser(
        id: emp.id,
        name: emp.name,
        roles: emp.roles,
        imageUrl: emp.imageUrl,
        description: emp.location?.id ?? '-',
      ),
      to: ReportUser(
        id: widget.empTo.id,
        name: widget.empTo.name,
        roles: widget.empTo.roles,
        imageUrl: widget.empTo.imageUrl,
        description: '-',
      ),
      title: _titleCtrl.text,
      description: _descriptionCtrl.text,
    );

    if (_formKey.currentState!.validate()) {
      try {
        setState(() => isLoading = true);
        final result = await api.report.create(report);

        if (image != null) {
          Storages.instance.uploadPhoto(ref: Storages.instance.path(ref: 'report/${result.id}/', file: image), file: image);
        }

        if (file != null) {
          Storages.instance.uploadPhoto(ref: Storages.instance.files(ref: 'private/report/${result.id}/', file: file), file: file);
        }

        if (!mounted) return;
        if (ref.read(employeeStateProvider).roles == UserRoles.am) {
          Navigator.pop(context);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil dibuat.")));
        return;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Laporan gagal dibuat. $e")));
        return;
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(fileProvider);
    final images = ref.watch(imageStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            // Text('Kepada: ${widget.empTo.name}'),
            Text('Buat Laporan'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.empTo.imageUrl),
                    radius: 50,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kepada : ${widget.empTo.name}'),
                        Text('Roles : ${roleString(widget.empTo.roles)}'),
                        if (widget.empTo.location != null) Text('Lokasi : ${widget.empTo.location?.name}'),
                        Text('Tim : ${teamString(widget.empTo.team)}'),
                        Text('No. Telp : ${widget.empTo.phone}'),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Judul',
                      hintText: "Masukkan judul laporan",
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Deskripsi',
                      hintText: "Masukkan deskripsi laporan",
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  if (files != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimens.px16),
                        const Text('Lampiran'),
                        const SizedBox(height: Dimens.px10),
                        ListTile(
                          style: ListTileStyle.list,
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Colors.blue)),
                          title: Text(files.path.split('/').last),
                          trailing: GestureDetector(
                              onTap: () => ref.read(fileProvider.notifier).update((state) => null),
                              child: const Icon(Icons.highlight_remove_outlined)),
                        ),
                        const SizedBox(height: 5)
                      ],
                    ),
                  if (images != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimens.px16),
                        const Text('Gambar'),
                        const SizedBox(height: Dimens.px10),
                        Image.file(images),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => showModalBottomSheet(
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
                                ref.read(imageStateProvider.notifier).update((state) => File(result.path));
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
                                ref.read(imageStateProvider.notifier).update((state) => File(result.path));
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
                icon: const Icon(Icons.camera_alt),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'docx', 'doc'],
                      allowMultiple: false,
                    );
                    if (result != null) {
                      ref.read(fileProvider.notifier).update((state) => File(result.paths.first ?? ''));
                    }
                  } catch (e) {
                    Alerts.dialog(context, content: e.toString());
                    return;
                  }
                },
                icon: const Icon(Icons.attach_file),
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isLoading ? null : _sendReport,
                child: isLoading ? const CircularProgressIndicator.adaptive() : const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
