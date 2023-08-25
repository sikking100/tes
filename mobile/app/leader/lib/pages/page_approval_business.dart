import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';

final businessApprovalProvider = StateNotifierProvider.autoDispose.family<BusinessApprovalNotifier, PagingController<int, Apply>, int>((ref, arg) {
  return BusinessApprovalNotifier(ref, arg);
});

class BusinessApprovalNotifier extends StateNotifier<PagingController<int, Apply>> {
  BusinessApprovalNotifier(this.ref, this.arg) : super(PagingController(firstPageKey: 1)) {
    api = ref.read(apiProvider);
    state.addPageRequestListener((pageKey) {
      waitingApprove(pageKey);
    });
  }

  final int arg;
  final AutoDisposeRef ref;
  late Api api;

  void waitingApprove(int pageKey) async {
    try {
      final emp = ref.read(employeeStateProvider);
      Paging<Apply> res;

      switch (arg) {
        case 2:
          res = await api.apply.find(userId: emp.id, type: 0, num: pageKey);
          break;
        case 1:
          res = await api.apply.find(userId: emp.id, type: 2, num: pageKey);
          break;
        default:
          res = await api.apply.find(userId: emp.id, type: 2, num: pageKey);
      }
      if (res.next == null) {
        state.appendLastPage(res.items);
      } else {
        state.appendPage(res.items, res.next);
      }
      return;
    } catch (error) {
      state.error = error;
    }
  }
}

final regionNotifierProvider = StateNotifierProvider.autoDispose<RegionNotifier, PagingController<int, Region>>((ref) {
  return RegionNotifier(ref);
});

class RegionNotifier extends StateNotifier<PagingController<int, Region>> {
  RegionNotifier(this.ref) : super(PagingController(firstPageKey: 1)) {
    api = ref.read(apiProvider);
    state.addPageRequestListener(fetch);
  }
  final AutoDisposeRef ref;
  late Api api;

  void fetch(int pageKey) async {
    try {
      Paging<Region> res;
      res = await api.region.find(num: pageKey);
      // if (pageKey == 1 && ref.read(indexProvider).isEmpty) {
      // ref.read(indexProvider.notifier).update((_) => res.items.first.id);
      // ref.read(businessApprovalProvider(2)).refresh();
      // }
      if (res.next == null) {
        state.appendLastPage(res.items);
      } else {
        state.appendPage(res.items, res.next);
      }
      return;
    } catch (e) {
      state.error = e.toString();
    }
  }
}

const String pageBusinessApproval = '/business-approval';

class PageApprovalBusiness extends ConsumerWidget {
  const PageApprovalBusiness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final diajukan = ref.watch(businessApprovalProvider(0));
    final menunggu = ref.watch(businessApprovalProvider(1));
    final riwayat = ref.watch(businessApprovalProvider(2));
    // final emp = ref.watch(employeeStateProvider);
    // final region = ref.watch(regionNotifierProvider);
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengajuan Bisnis'),
          bottom: const TabBar(
            tabs: [
              // Tab(text: 'Diajukan'),
              Tab(text: 'Menunggu Persetujuan'),
              Tab(text: 'Riwayat'),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            // RefreshIndicator.adaptive(
            //   onRefresh: () => Future.sync(() => diajukan.refresh()),
            //   child: PagedListView<int, Apply>.separated(
            //     pagingController: diajukan,
            //     padding: const EdgeInsets.all(16),
            //     builderDelegate: PagedChildBuilderDelegate<Apply>(
            //       noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
            //       itemBuilder: (_, item, __) => BusinessApprovalItem(item: item),
            //     ),
            //     separatorBuilder: (context, index) => const Divider(),
            //   ),
            // ),
            RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(() => menunggu.refresh()),
              child: PagedListView<int, Apply>.separated(
                pagingController: menunggu,
                padding: const EdgeInsets.all(16),
                builderDelegate: PagedChildBuilderDelegate<Apply>(
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
                  itemBuilder: (_, item, __) => BusinessApprovalItem(item: item),
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(() => menunggu.refresh()),
              child: PagedListView<int, Apply>.separated(
                pagingController: riwayat,
                padding: const EdgeInsets.all(16),
                builderDelegate: PagedChildBuilderDelegate<Apply>(
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
                  itemBuilder: (_, item, __) => BusinessApprovalItem(item: item),
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            // RefreshIndicator.adaptive(
            //   onRefresh: () => Future.sync(() => riwayat.refresh()),
            //   child: emp.roles >= UserRoles.direktur && emp.roles <= UserRoles.nsm
            //       ? Column(
            //           children: [
            //             Expanded(
            //               flex: 1,
            //               child: Consumer(
            //                 builder: (context, ref, child) {
            //                   final indexes = ref.watch(indexProvider);
            //                   return RefreshIndicator.adaptive(
            //                     child: PagedListView.separated(
            //                       separatorBuilder: (context, index) => const SizedBox(width: Dimens.px10),
            //                       padding: const EdgeInsets.symmetric(horizontal: Dimens.px10),
            //                       scrollDirection: Axis.horizontal,
            //                       pagingController: region,
            //                       builderDelegate: PagedChildBuilderDelegate<Region>(
            //                         itemBuilder: (context, item, index) => ChoiceChip(
            //                           label: Container(
            //                             constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 30 / 100),
            //                             height: MediaQuery.of(context).size.height * 4.5 / 100,
            //                             child: Center(
            //                               child: Text(
            //                                 item.name,
            //                               ),
            //                             ),
            //                           ),
            //                           selected: item.id == indexes,
            //                           disabledColor: Colors.grey.shade100,
            //                           onSelected: (v) {
            //                             ref.read(indexProvider.notifier).update((state) => item.id);
            //                             riwayat.refresh();
            //                           },
            //                         ),
            //                       ),
            //                     ),
            //                     onRefresh: () => Future.sync(region.refresh),
            //                   );
            //                 },
            //               ),
            //             ),
            //             Expanded(
            //               flex: 7,
            //               child: PagedListView<int, Apply>.separated(
            //                 pagingController: riwayat,
            //                 padding: const EdgeInsets.all(16),
            //                 builderDelegate: PagedChildBuilderDelegate<Apply>(
            //                   noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
            //                   itemBuilder: (_, item, __) => BusinessApprovalItem(item: item),
            //                 ),
            //                 separatorBuilder: (context, index) => const Divider(),
            //               ),
            //             )
            //           ],
            //         )
            //       : Column(
            //           children: [
            //             Expanded(
            //               flex: 1,
            //               child: Consumer(
            //                 builder: (context, ref, child) {
            //                   final indexes = ref.watch(indexProvider);
            //                   return ListView.separated(
            //                     separatorBuilder: (context, index) => const SizedBox(width: Dimens.px10),
            //                     padding: const EdgeInsets.symmetric(horizontal: Dimens.px10),
            //                     scrollDirection: Axis.horizontal,
            //                     itemBuilder: (context, index) {
            //                       return ChoiceChip(
            //                         label: Container(
            //                           constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 30 / 100),
            //                           height: MediaQuery.of(context).size.height * 4.5 / 100,
            //                           child: Center(
            //                             child: Text(
            //                               '${emp.location?.name}',
            //                             ),
            //                           ),
            //                         ),
            //                         selected: '${emp.location?.id}' == indexes,
            //                         disabledColor: Colors.grey.shade100,
            //                         onSelected: (v) {
            //                           ref.read(indexProvider.notifier).update((state) => '${emp.location?.id}');
            //                           riwayat.refresh();
            //                         },
            //                       );
            //                     },
            //                     itemCount: emp.roles == UserRoles.rm ? 1 : 1,
            //                   );
            //                 },
            //               ),
            //             ),
            //             Expanded(
            //               flex: 7,
            //               child: PagedListView<int, Apply>.separated(
            //                 pagingController: riwayat,
            //                 padding: const EdgeInsets.all(16),
            //                 builderDelegate: PagedChildBuilderDelegate<Apply>(
            //                   noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
            //                   itemBuilder: (_, item, __) => BusinessApprovalItem(item: item),
            //                 ),
            //                 separatorBuilder: (context, index) => const Divider(),
            //               ),
            //             )
            //           ],
            //         ),
            // ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.businessAdd);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class BusinessApprovalItem extends ConsumerWidget {
  final Apply item;
  const BusinessApprovalItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AspectRatio(
        aspectRatio: 1,
        child: CircleAvatar(
          backgroundImage: NetworkImage(item.customer.imageUrl),
          radius: 30,
        ),
      ),
      title: Text(item.customer.name.toUpperCase()),
      subtitle: Text(item.pic.name.firstLetter),
      onTap: () {
        if (item.userApprover.isEmpty) return;
        Navigator.pushNamed(
          context,
          Routes.approvalBusinessDetail,
          arguments: item,
        );
      },
    );
  }
}
