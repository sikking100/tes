import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/common.dart';

// final pendingStateNotifier = StateNotifierProvider.autoDispose<PendingState, Paging<Order>>((ref) => PendingState(ref));

// class PendingState extends StateNotifier<Paging<Order>> {
//   PendingState(AutoDisposeRef ref) : super(const Paging<Order>(null, null, [])) {
//     api = ref.watch(apiProvider);
//     employee = ref.watch(userStateProvider);
//     controller = RefreshController(initialRefresh: true);
//   }
//   late final Api api;
//   late final RefreshController controller;
//   late final Employee employee;

//   void getPending() async {
//     try {
//       controller.resetNoData();
//       final result = await api.order.all(query: employee.id, isPending: false);
//       final list = result.items.where((element) => element.delivery.items.isEmpty);
//       state = result;
//       state.items.setAll(0, list);
//       controller.refreshCompleted();
//       return;
//     } catch (e) {
//       controller.refreshFailed();
//       rethrow;
//     }
//   }

//   void getPendingNext() async {
//     try {
//       if (state.next == null) {
//         controller.loadNoData();
//         return;
//       }
//       final result = await api.order.all(query: employee.id, isPending: false, pageNumber: state.next?.pageNumber);
//       final list = result.items.where((element) => element.delivery.items.isEmpty);
//       state.items.addAll(list);
//       state = state.copyWith(next: result.next);
//       controller.loadComplete();
//       return;
//     } catch (e) {
//       controller.loadFailed();
//       rethrow;
//     }
//   }
// }

final pendingProvider = FutureProvider.autoDispose<List<PackingListCourier>>((ref) async {
  final api = ref.read(apiProvider);
  return api.delivery.packingListCourier(4);
});

final listDeliveryDestinationProvider = FutureProvider.autoDispose<List<PackingDestination>>((ref) async {
  return ref.read(apiProvider).delivery.packingListDestination();
});

class ViewPending extends ConsumerWidget {
  const ViewPending({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final listPending = ref.watch(pendingFutureProvider);
    // final pendingState = ref.watch(pendingStateNotifier);
    // return SmartRefresher(
    //   controller: ref.read(pendingStateNotifier.notifier).controller,
    //   enablePullUp: true,
    //   enablePullDown: true,
    //   onRefresh: ref.read(pendingStateNotifier.notifier).getPending,
    //   onLoading: ref.read(pendingStateNotifier.notifier).getPendingNext,
    //   header: CustomHeader(
    //     builder: (context, mode) {
    //       if (mode == RefreshStatus.refreshing) return const Center(child: CircularProgressIndicator.adaptive());
    //       return Container();
    //     },
    //   ),
    //   footer: CustomFooter(
    //     builder: (context, mode) {
    //       if (mode == LoadStatus.loading) return const Center(child: CircularProgressIndicator.adaptive());
    //       return Container();
    //     },
    //     loadStyle: LoadStyle.ShowWhenLoading,
    //   ),
    //   child: pendingState.items.isEmpty
    //       ? const Center(child: Text('Belum ada data'))
    //       : ListView.separated(
    //           padding: mPadding,
    //           itemBuilder: (context, index) {
    //             final datas = pendingState.items[index];
    //             return WidgetPengantaran(datas: datas);
    //           },
    //           separatorBuilder: (context, index) => const Divider(),
    //           itemCount: pendingState.items.length,
    //         ),
    // );

    final pending = ref.watch(pendingProvider);
    return pending.when(
      data: (data) => Scaffold(
        body: RefreshIndicator.adaptive(
          onRefresh: () async => ref.refresh(pendingProvider),
          child: data.isEmpty
              ? LayoutBuilder(
                  builder: (p0, p1) => ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        constraints: BoxConstraints(minHeight: p1.maxHeight),
                        child: const Center(
                          child: Text('Belum ada data'),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(Dimens.px16),
                  itemBuilder: (context, index) {
                    final e = data[index];
                    return WarehouseItem(
                      number: index,
                      packingList: e,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: data.length,
                ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.assistant_navigation),
          onPressed: () => showModalBottomSheet(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dimens.px16))),
            context: context,
            builder: (context) => Column(children: [
              const SizedBox(height: Dimens.px16),
              const Ribbon(),
              const SizedBox(height: Dimens.px10),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final list = ref.watch(listDeliveryDestinationProvider);
                    return list.when(
                      data: (data) => ListView.separated(
                        itemBuilder: (context, index) => ListTile(
                          title: Text('Id Deliver : ${data[index].deliveryId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama : ${data[index].customer.name}'),
                              Text('Alamat : ${data[index].customer.addressName}'),
                            ],
                          ),
                        ),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: data.length,
                      ),
                      error: (error, stackTrace) => Center(child: Text('$error')),
                      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    );
                  },
                ),
              )
            ]),
          ),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$error'),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => ref.refresh(pendingProvider), child: const Text('Refresh'))
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
