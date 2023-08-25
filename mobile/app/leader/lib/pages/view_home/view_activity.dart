import 'dart:io';

import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/function.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:readmore/readmore.dart';

final buttonAddStateNotifierProvider = StateNotifierProvider.autoDispose<ButtonAdd, double>((_) => ButtonAdd());

class ButtonAdd extends StateNotifier<double> {
  ButtonAdd() : super(10) {
    controller = ScrollController();
    controller.addListener(() {
      if (controller.position.userScrollDirection == ScrollDirection.forward) {
        state = 10;
      } else {
        state = -100;
      }
    });
  }
  late final ScrollController controller;
}

final activityStateNotifierProvider = StateNotifierProvider.autoDispose<ActivityNotifier, PagingController<int, Activity>>((ref) {
  return ActivityNotifier(ref);
});

class ActivityNotifier extends StateNotifier<PagingController<int, Activity>> {
  ActivityNotifier(this.ref) : super(PagingController(firstPageKey: 1)) {
    state.addPageRequestListener((pageKey) => fetch(pageKey));
  }
  final AutoDisposeRef ref;

  void fetch(int pageKey) async {
    try {
      final result = await ref.read(apiProvider).activity.all(num: pageKey);
      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, pageKey + 1);
      }
      return;
    } catch (e) {
      state.error = e.toString();
      return;
    }
  }
}

class ViewActivity extends ConsumerWidget {
  const ViewActivity({super.key});

  void toActivity(BuildContext context, PagingController<int, Activity> pagingController, [ImageSource? source]) async {
    File? file;
    if (source != null) {
      file = await getImage(source);
    }
    if (context.mounted) {
      await Navigator.pushNamed(context, Routes.activityAdd, arguments: file);
      if (context.mounted) {
        Navigator.pop(context);
      }
      pagingController.refresh();
    }
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = ref.watch(activityStateNotifierProvider);
    final value = ref.watch(buttonAddStateNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivitas')),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          pagingController.refresh();
        },
        // triggerMode: RefreshIndicator.adaptiveTriggerMode.anywhere,
        child: PagedListView<int, Activity>.separated(
            scrollController: ref.read(buttonAddStateNotifierProvider.notifier).controller,
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<Activity>(
              itemBuilder: (context, item, index) => WidgetActivity(activity: item),
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
            ),
            separatorBuilder: (_, __) => Container(height: 10, color: Colors.black12)),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(-value, 0, 0),
        child: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Dimens.px16),
                const Ribbon(),
                const SizedBox(height: Dimens.px16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Ambil Gambar'),
                  onTap: () => toActivity(context, pagingController, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Buka Galeri'),
                  onTap: () => toActivity(context, pagingController, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.link_outlined),
                  title: const Text('Url Video'),
                  onTap: () => toActivity(context, pagingController),
                ),
              ],
            ),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class WidgetActivity extends ConsumerWidget {
  final Activity activity;
  const WidgetActivity({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeStateProvider);
    final pagingController = ref.read(activityStateNotifierProvider);
    final size = MediaQuery.of(context).size;
    final scheme = Theme.of(context).colorScheme;
    final count = activity.commentCount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(activity.creator.imageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.creator.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(roleString(activity.creator.roles)),
                    Visibility(
                      visible: activity.creator.description != '-',
                      child: Text(
                        activity.creator.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (employee.id == activity.creator.id)
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Hapus Aktivitas"),
                      content: const Text("Apakah anda yakin ingin menghapus aktivitas ini?"),
                      actions: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(apiProvider)
                              .activity
                              .delete(activity.id)
                              .then((_) => pagingController.refresh())
                              .then((_) => Navigator.pop(context))
                              .catchError((e) => Alerts.dialog(context, content: e.toString())),
                          child: const Text("Hapus"),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.more_vert_rounded),
                ),
            ],
          ),
        ),
        if (activity.videoUrl == '-' && activity.imageUrl.contains('default'))
          Image.network(activity.imageUrl)
        else
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width,
                height: size.width * 0.5625,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  image: !activity.videoUrl.contains('youtube') && !activity.videoUrl.contains('youtu.be')
                      ? null
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            YoutubePlayer.getThumbnail(
                              videoId: YoutubePlayer.convertUrlToId(activity.videoUrl) ?? '',
                              quality: ThumbnailQuality.high,
                            ),
                          ),
                          onError: (exception, stackTrace) => (exception),
                        ),
                ),
              ),
              !activity.videoUrl.contains('youtube') && !activity.videoUrl.contains('youtu.be')
                  ? const Text('Tidak bisa diputar')
                  : Positioned(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            Routes.activity,
                            arguments: activity.id,
                          );
                          pagingController.refresh();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ReadMoreText(
                activity.description,
                trimLines: 4,
                trimCollapsedText: '\n\nSelengkapnya',
                trimExpandedText: '\n\nSembunyikan',
                lessStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.secondary,
                ),
                moreStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      activity.createdAt.toTimeago,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        Routes.activity,
                        arguments: activity.id,
                      );
                      pagingController.refresh();
                    },
                    child: Text("$count Komentar"),
                  )
                ],
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.black26,
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(employee.imageUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          Routes.activity,
                          arguments: activity.id,
                        );
                        pagingController.refresh();
                      },
                      decoration: InputDecoration(
                        hintText: "Tulis Komentar",
                        filled: true,
                        fillColor: Colors.black12,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
