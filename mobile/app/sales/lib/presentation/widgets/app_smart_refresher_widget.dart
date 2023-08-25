import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class SmartRefresherWidget extends StatelessWidget {
  final RefreshController controller;
  final void Function() onLoading;
  final void Function() onRefresh;
  final Widget child;
  const SmartRefresherWidget(
      {Key? key,
      required this.controller,
      required this.onLoading,
      required this.onRefresh,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.caption;
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("tarik kebawah untuk memuat data", style: caption);
          }
          if (mode == LoadStatus.idle) {
            body = Text("tarik kebawah untuk memuat data", style: caption);
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("gagal memuat data, coba lagi ?", style: caption);
          } else if (mode == LoadStatus.canLoading) {
            body = Text("lepaskan untuk memuat data lagi", style: caption);
          } else {
            body = Text("tidak ada lagi data", style: caption);
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: controller,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: child,
    );
  }
}
