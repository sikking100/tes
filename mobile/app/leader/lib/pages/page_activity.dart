import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:leader/function.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final activityFutureProvider = FutureProvider.autoDispose.family<Activity, String>((ref, id) async {
  return ref.read(apiProvider).activity.byId(id);
});

class PageActivity extends ConsumerWidget {
  final String id;
  const PageActivity({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityFutureProvider(id));

    return activity.when(
      data: (data) {
        if (data.videoUrl != '-' && (data.videoUrl.contains('youtube') || data.videoUrl.contains('youtu.be'))) {
          return VideoWidget(
            url: data.videoUrl,
            child: ActivityDetailWidget(
              data: data,
            ),
          );
        }
        return ActivityDetailWidget(
          data: data,
          video: Container(),
        );
      },
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Detail Aktivitas')),
        body: Center(
          child: Column(
            children: [
              Text('$error'),
              const SizedBox(height: Dimens.px10),
              ElevatedButton(onPressed: () => ref.invalidate(activityFutureProvider(id)), child: const Text('Refresh'))
            ],
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detail Aktivitas')),
        body: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}

final listCommentFutureProvider = FutureProvider.autoDispose.family<List<Comment>, String>((ref, activityId) async {
  return ref.read(apiProvider).activity.comments(activityId);
});

class ActivityDetailWidget extends HookConsumerWidget {
  final Activity data;
  final Widget? video;
  const ActivityDetailWidget({super.key, required this.data, this.video});

  ActivityDetailWidget copyWith(Widget? video) => ActivityDetailWidget(data: data, video: video);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeStateProvider);
    final listComment = ref.watch(listCommentFutureProvider(data.id));
    final text = useTextEditingController();
    final btnLoading = ref.watch(buttonStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Aktivitas')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(data.creator.imageUrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.creator.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(roleString(data.creator.roles)),
                              Visibility(
                                visible: data.creator.description != '-',
                                child: Text(
                                  data.creator.description,
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
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: data.videoUrl == '-' && video != null && !data.videoUrl.contains('youtube') && !data.videoUrl.contains('youtu.be')
                      ? Image.network(data.imageUrl)
                      : video,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.px16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ReadMoreText(
                          data.description,
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
                                data.createdAt.toTimeago,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                listComment.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Text('Belum ada komentar'),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _BuildItemComment(
                          comment: comments[index],
                          emp: ref.watch(employeeStateProvider),
                          isLoading: false,
                          onPressed: () async {
                            try {
                              await ref.read(apiProvider).activity.deleteComment(comments[index].id);
                              ref.invalidate(listCommentFutureProvider(data.id));
                              if (context.mounted) Navigator.pop(context);
                              return;
                            } catch (e) {
                              Alerts.dialog(context, content: '$e');
                              return;
                            }
                          },
                        ),
                        childCount: comments.length,
                      ),
                    );
                  },
                  error: (error, stackTrace) => SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 50 / 100,
                      child: WidgetError(
                        error: error.toString(),
                        onPressed: () => ref.invalidate(listCommentFutureProvider),
                      ),
                    ),
                  ),
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: Colors.black26,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: text,
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
                    IconButton(
                      onPressed: btnLoading
                          ? null
                          : () async {
                              try {
                                ref.read(buttonStateProvider.notifier).update((_) => true);
                                final req = ReqComment(
                                  activityId: data.id,
                                  comment: text.text,
                                  creator: Creator(
                                    id: employee.id,
                                    name: employee.name,
                                    roles: employee.roles,
                                    imageUrl: employee.imageUrl,
                                    description: employee.location != null ? employee.location!.name : '-',
                                  ),
                                );
                                await ref.read(apiProvider).activity.createComment(req);
                                ref.invalidate(listCommentFutureProvider(data.id));
                                FocusManager.instance.primaryFocus?.unfocus();
                                text.clear();
                                return;
                              } catch (e) {
                                Alerts.dialog(context, content: e.toString());
                                return;
                              } finally {
                                ref.read(buttonStateProvider.notifier).update((_) => false);
                              }
                            },
                      icon: btnLoading ? const CircularProgressIndicator.adaptive() : const Icon(Icons.send),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String url;
  final ActivityDetailWidget child;
  const VideoWidget({super.key, required this.url, required this.child});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () => SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]),
      onExitFullScreen: () {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [
            SystemUiOverlay.bottom,
            SystemUiOverlay.top,
          ],
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
      player: YoutubePlayer(
        controller: _controller,
        progressIndicatorColor: scheme.error,
        progressColors: ProgressBarColors(
          playedColor: scheme.error,
          backgroundColor: Colors.grey[50],
        ),
        bottomActions: [
          CurrentPosition(
            controller: _controller,
          ),
          ProgressBar(
            controller: _controller,
            isExpanded: true,
            colors: ProgressBarColors(
              backgroundColor: Colors.grey[50],
              playedColor: scheme.error,
              handleColor: scheme.error,
              bufferedColor: Colors.grey,
            ),
          ),
          RemainingDuration(
            controller: _controller,
          ),
          FullScreenButton(
            controller: _controller,
          ),
        ],
      ),
      builder: (p0, p1) => widget.child.copyWith(p1),
    );
  }
}

class _BuildItemComment extends StatelessWidget {
  const _BuildItemComment({
    required this.comment,
    required this.emp,
    required this.isLoading,
    required this.onPressed,
  });

  final Employee emp;
  final Comment comment;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(100),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(comment.creator.imageUrl),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        comment.creator.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(roleString(comment.creator.roles)),
                      Text(
                        comment.creator.description.isEmpty ? '-' : comment.creator.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(comment.comment),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 5),
                  child: Text(comment.createdAt.toTimeago),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (emp.id == comment.creator.id)
            // isLoading
            //     ? Container(
            //         margin: const EdgeInsets.only(left: 8),
            //         height: 20,
            //         width: 20,
            //         child: const CircularProgressIndicator(strokeWidth: 1.8),
            //       )
            //     :
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              iconSize: 20,
              color: scheme.secondary,
              icon: const Icon(Icons.delete_forever_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('Hapus komentar'),
                      content: const Text('Apakah anda yakin?'),
                      actions: [
                        OutlinedButton(
                          child: const Text('Tidak'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          onPressed: onPressed,
                          child: const Text('Ya'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
