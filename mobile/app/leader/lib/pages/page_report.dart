import 'dart:isolate';
import 'dart:ui';

import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:leader/storage.dart';
import 'package:url_launcher/url_launcher.dart';

final detailLaporanProvider = FutureProvider.autoDispose.family<Report, String>((ref, arg) async {
  return ref.read(apiProvider).report.find(arg);
});

class PageReport extends ConsumerStatefulWidget {
  final ArgReport arg;
  const PageReport({super.key, required this.arg});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PageReportState();
}

class _PageReportState extends ConsumerState<PageReport> {
  double progress = 0.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    final gets = ref.watch(detailLaporanProvider(widget.arg.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
      ),
      body: gets.when(
        data: (data) {
          final file = data.filePath;
          return RefreshIndicator.adaptive(
            onRefresh: () async => ref.invalidate(detailLaporanProvider(widget.arg.id)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimens.px16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.arg.isMasuk)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ke', style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(data.to.imageUrl)),
                          title: Text(data.to.name),
                          subtitle: Text(roleString(data.to.roles)),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dari', style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(data.from.imageUrl)),
                          title: Text(data.from.name),
                          subtitle: Text(roleString(data.from.roles)),
                        ),
                      ],
                    ),
                  Text('${data.sendDate?.fullDateTime}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: Dimens.px16),
                  const Text('Judul', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(data.title),
                  const SizedBox(height: Dimens.px16),
                  const Text('Isi', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(data.description),
                  file == null || file.isEmpty
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: Dimens.px16),
                            const Text('Lampiran', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            ListTile(
                              style: ListTileStyle.list,
                              dense: true,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Colors.blue)),
                              title: Text((data.filePath?.split('/').last).toString()),
                              trailing: GestureDetector(
                                  onTap: progress > 0.0
                                      ? null
                                      : () async {
                                          // final status = await p.Permission.storage.request();
                                          // if (status == p.PermissionStatus.denied) return;
                                          // ref.read(loadingStateProvider.notifier).update((state) => true);
                                          // String url = '';
                                          // for (var u in data.filePath?.split('/') ?? <String>[]) {
                                          //   if (u != 'dairy-food-development.appspot.com') url += '$u/';
                                          // }

                                          // (url);
                                          // final download = await getExternalStorageDirectory();

                                          final String imageUrl = await Storages.instance.getImageUrl(file);

                                          if (file.split('.').last == 'pdf' && context.mounted) {
                                            Navigator.pushNamed(context, Routes.pdf, arguments: ArgPdf('File Laporan', imageUrl));
                                            return;
                                          }
                                          if (await canLaunchUrl(Uri.parse(imageUrl))) {
                                            await launchUrl(Uri.parse(imageUrl), mode: LaunchMode.externalApplication);
                                          }
                                          return;

                                          // await FlutterDownloader.enqueue(
                                          //     url: imageUrl,
                                          //     savedDir: download?.path ?? '',
                                          //     showNotification: true,
                                          //     fileName: '${data.filePath?.split('/').last.split('.').first}-${DateTime.now().second}');

                                          // ref.read(loadingStateProvider.notifier).update((state) => false);
                                        },
                                  child: progress > 0.0 ? CircularProgressIndicator(value: progress) : const Icon(Icons.download)),
                            ),
                            const SizedBox(height: Dimens.px16),
                          ],
                        ),
                  data.imageUrl.isEmpty || data.imageUrl.contains('default')
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: Dimens.px16),
                            const Text('Gambar', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Image.network(data.imageUrl),
                            const SizedBox(height: Dimens.px16),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
