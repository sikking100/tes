import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final riwayatStateNotifier = StateNotifierProvider.autoDispose<RiwayatState, PagingController<int, Delivery>>((ref) => RiwayatState(ref));

class RiwayatState extends StateNotifier<PagingController<int, Delivery>> {
  RiwayatState(AutoDisposeRef ref) : super(PagingController<int, Delivery>(firstPageKey: 1)) {
    api = ref.read(apiProvider);
    employee = ref.watch(userStateProvider);
    state.addPageRequestListener(listener);
  }
  late final Api api;
  late final Employee employee;
  String error = '';

  void listener(int pageKey) async {
    try {
      final result = await api.delivery.find(status: 9, num: pageKey);
      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, result.next);
      }
      return;
    } catch (e) {
      state.error = '$e';
      return;
    }
  }
}

class PageRiwayatPengantaran extends ConsumerWidget {
  const PageRiwayatPengantaran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayatState = ref.watch(riwayatStateNotifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengantaran'),
      ),
      body: PagedListView.separated(
        padding: const EdgeInsets.all(Dimens.px16),
        pagingController: riwayatState,
        builderDelegate: PagedChildBuilderDelegate<Delivery>(
          noItemsFoundIndicatorBuilder: (context) => const Center(
            child: Text('Pengantaran Kosong'),
          ),
          itemBuilder: (context, item, index) => WidgetPengantaran(datas: item, ref: ref, isRiwayat: true),
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
