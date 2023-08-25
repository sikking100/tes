import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/routes/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final prosesStateNotifier = StateNotifierProvider.autoDispose<ProsesState, PagingController<int, Delivery>>((ref) => ProsesState(ref));

class ProsesState extends StateNotifier<PagingController<int, Delivery>> {
  ProsesState(AutoDisposeRef ref) : super(PagingController<int, Delivery>(firstPageKey: 1)) {
    api = ref.watch(apiProvider);
    state.addPageRequestListener(listener);
  }
  late final Api api;

  void listener(int pageKey) async {
    try {
      final result = await api.delivery.find(status: 7, num: pageKey);
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

class ViewProses extends ConsumerWidget {
  const ViewProses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prosesState = ref.watch(prosesStateNotifier);
    return Scaffold(
      body: RefreshIndicator.adaptive(
        child: PagedListView.separated(
          padding: const EdgeInsets.all(Dimens.px16),
          pagingController: prosesState,
          builderDelegate: PagedChildBuilderDelegate<Delivery>(
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Belum ada data'),
            ),
            animateTransitions: true,
            itemBuilder: (context, item, index) => WidgetPengantaran(datas: item, ref: ref),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
        onRefresh: () => Future.sync(() => prosesState.refresh()),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.inventory_2_outlined),
        onPressed: () => Navigator.pushNamed(context, Routes.looaded),
      ),
    );
  }
}
