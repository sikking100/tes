import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final dimuatStateNotifier = StateNotifierProvider.autoDispose<DimuatState, PagingController<int, Delivery>>((ref) => DimuatState(ref));

class DimuatState extends StateNotifier<PagingController<int, Delivery>> {
  DimuatState(AutoDisposeRef ref) : super(PagingController<int, Delivery>(firstPageKey: 1)) {
    api = ref.watch(apiProvider);
    state.addPageRequestListener(listener);
  }
  late final Api api;

  void listener(int pageKey) async {
    try {
      final result = await api.delivery.find(status: 6, num: pageKey);
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

class ViewDimuat extends ConsumerWidget {
  const ViewDimuat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diMuatState = ref.watch(dimuatStateNotifier);
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(() => diMuatState.refresh()),
        child: PagedListView.separated(
          padding: const EdgeInsets.all(Dimens.px16),
          pagingController: diMuatState,
          builderDelegate: PagedChildBuilderDelegate<Delivery>(
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Belum ada data'),
            ),
            itemBuilder: (context, item, index) => WidgetPengantaran(datas: item, ref: ref),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.inventory_2_outlined),
        onPressed: () => Navigator.pushNamed(context, Routes.looaded),
      ),
    );
  }
}
