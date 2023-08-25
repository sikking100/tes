import 'package:customer/argument.dart';
import 'package:customer/storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final getImageProvider = FutureProvider.family.autoDispose<String, String>((ref, arg) async {
  return Storage.instance.getImageUrl(arg);
});

class PagePhotoView extends ConsumerWidget {
  final ArgPhotoView arg;
  const PagePhotoView({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(getImageProvider(arg.imgUrl));
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: arg.isFb
          ? result.when(
              data: (data) => InteractiveViewer(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(data))),
                ),
              ),
              error: (error, stackTrace) => Text('$error'),
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            )
          : InteractiveViewer(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(arg.imgUrl))),
              ),
            ),
    );
  }
}
