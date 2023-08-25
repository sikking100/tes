import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:api/api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/argument.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';

class PageBusiness extends ConsumerWidget {
  const PageBusiness({super.key});
  Future modal(Customer item, WidgetRef ref, BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () => Navigator.pushReplacementNamed(context, Routes.businessDetail, arguments: ArgBusinessDetail(customer: item)),
              title: const Text('Detail'),
            ),
            ListTile(
              title: const Text('Belanja'),
              onTap: () {
                ref.read(customerStateProvider.notifier).update((_) => item);
                Navigator.pushReplacementNamed(context, Routes.shopping);
              },
            )
          ],
        ),
      );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = ref.watch(employeeStateProvider);
    final mine = ref.watch(businessStateNotifierProvider(0));
    final teritory = ref.watch(businessStateNotifierProvider(1));
    return DefaultTabController(
      length:
          //  emp.roles >= UserRoles.direktur && emp.roles <= UserRoles.nsm ? 3 :
          2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bisnis'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Saya'),
              Tab(text: emp.roles == UserRoles.am ? 'Cabang' : 'Region'),
              // if (emp.roles >= UserRoles.direktur && emp.roles <= UserRoles.nsm)
              //   const Tab(
              //     text: 'Semua',
              //   )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(
                () => mine.refresh(),
              ),
              child: PagedListView<int, Customer>.separated(
                pagingController: mine,
                padding: const EdgeInsets.all(16),
                builderDelegate: PagedChildBuilderDelegate<Customer>(
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
                  itemBuilder: (_, item, __) => ListTile(
                    onTap: () => modal(item, ref, context),
                    contentPadding: EdgeInsets.zero,
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(item.imageUrl),
                      ),
                    ),
                    title: Text(item.name.toUpperCase()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.business?.location.branchName ?? ''),
                        Text(item.business?.pic.name.firstLetter ?? ''),
                      ],
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Consumer(
                    builder: (context, r, child) {
                      final indexes = r.watch(indexProvider);
                      final region = ref.watch(regionBusinessNotifierProvider);
                      if (emp.roles >= UserRoles.direktur && emp.roles <= UserRoles.nsm) {
                        return RefreshIndicator.adaptive(
                          child: PagedListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(width: Dimens.px10),
                            padding: const EdgeInsets.symmetric(horizontal: Dimens.px10),
                            scrollDirection: Axis.horizontal,
                            pagingController: region,
                            builderDelegate: PagedChildBuilderDelegate<Region>(
                              itemBuilder: (context, item, index) {
                                return ChoiceChip(
                                  label: Container(
                                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 30 / 100),
                                    height: MediaQuery.of(context).size.height * 4.5 / 100,
                                    child: Center(
                                      child: Text(
                                        item.name,
                                      ),
                                    ),
                                  ),
                                  selected: item.id == indexes,
                                  disabledColor: Colors.grey.shade100,
                                  onSelected: (v) {
                                    ref.read(indexProvider.notifier).update((state) => item.id);
                                    teritory.refresh();
                                  },
                                );
                              },
                            ),
                          ),
                          onRefresh: () => Future.sync(region.refresh),
                        );
                      }
                      return ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(width: Dimens.px10),
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.px10),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ChoiceChip(
                            label: Container(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 30 / 100),
                              height: MediaQuery.of(context).size.height * 4.5 / 100,
                              child: Center(
                                child: Text(
                                  '${emp.location?.name}',
                                ),
                              ),
                            ),
                            selected: '${emp.location?.id}' == indexes,
                            disabledColor: Colors.grey.shade100,
                            onSelected: (v) {
                              ref.read(indexProvider.notifier).update((state) => '${emp.location?.id}');
                              teritory.refresh();
                            },
                          );
                        },
                        itemCount: emp.roles == UserRoles.rm ? 1 : 1,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: RefreshIndicator.adaptive(
                    onRefresh: () => Future.sync(
                      () => teritory.refresh(),
                    ),
                    child: PagedListView<int, Customer>.separated(
                      pagingController: teritory,
                      padding: const EdgeInsets.all(16),
                      builderDelegate: PagedChildBuilderDelegate<Customer>(
                        noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
                        itemBuilder: (_, item, __) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: AspectRatio(
                            aspectRatio: 1,
                            child: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl), radius: 30),
                          ),
                          title: Text(item.name.toUpperCase()),
                          subtitle: item.business == null
                              ? const Text('Walkin Customer')
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.business?.location.branchName ?? ''),
                                    Text(item.business?.pic.name.firstLetter ?? ''),
                                  ],
                                ),
                          onTap: item.business == null ? null : () => modal(item, ref, context),
                        ),
                      ),
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                ),
              ],
            ),
            // if (emp.roles >= UserRoles.direktur && emp.roles <= UserRoles.nsm)
            //   RefreshIndicator.adaptive(
            //     onRefresh: () => Future.sync(
            //       () => all.refresh(),
            //     ),
            //     child: PagedListView<int, Customer>.separated(
            //       pagingController: all,
            //       padding: const EdgeInsets.all(16),
            //       builderDelegate: PagedChildBuilderDelegate<Customer>(
            //         noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
            //         itemBuilder: (_, item, __) => ListTile(
            //           contentPadding: EdgeInsets.zero,
            //           leading: AspectRatio(
            //             aspectRatio: 1,
            //             child: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl), radius: 30),
            //           ),
            //           title: Text(item.name),
            //           subtitle: item.business == null
            //               ? const Text('Walkin Customer')
            //               : Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(item.business?.location.branchName ?? ''),
            //                     Text(item.business?.pic.name ?? ''),
            //                   ],
            //                 ),
            //           onTap: item.business == null ? null : () => modal(item, ref, context),
            //         ),
            //       ),
            //       separatorBuilder: (context, index) => const Divider(),
            //     ),
            //   )
          ],
        ),
      ),
    );
  }
}

final regionBusinessNotifierProvider = StateNotifierProvider.autoDispose<RegionBusinessNotifier, PagingController<int, Region>>((ref) {
  return RegionBusinessNotifier(ref);
});

class RegionBusinessNotifier extends StateNotifier<PagingController<int, Region>> {
  RegionBusinessNotifier(this.ref) : super(PagingController(firstPageKey: 1)) {
    api = ref.read(apiProvider);
    state.addPageRequestListener((pageKey) {
      fetch(pageKey);
    });
  }
  final AutoDisposeRef ref;
  late Api api;

  void fetch(int pageKey) async {
    try {
      Paging<Region> res;
      res = await api.region.find(num: pageKey);
      if (res.next == null) {
        state.appendLastPage(res.items);
      } else {
        final nextPageKey = pageKey + 1;
        state.appendPage(res.items, nextPageKey);
      }
      return;
    } catch (e) {
      state.error = e.toString();
    }
  }
}

final businessStateNotifierProvider = StateNotifierProvider.autoDispose.family<BusinessNotifier, PagingController<int, Customer>, int>((ref, index) {
  return BusinessNotifier(ref, index);
});

class BusinessNotifier extends StateNotifier<PagingController<int, Customer>> {
  BusinessNotifier(this.ref, this.index) : super(PagingController(firstPageKey: 1)) {
    api = ref.read(apiProvider);
    state.addPageRequestListener((pageKey) => fetch(pageKey));
  }

  final AutoDisposeRef ref;
  late Api api;
  final int index;

  void fetch(int pageKey) async {
    try {
      Paging<Customer> res;
      final id = ref.read(indexProvider);
      final emp = ref.read(employeeStateProvider);
      if (index == 1 && id.isEmpty) {
        state.value = const PagingState(nextPageKey: 1, itemList: []);
        return;
      }
      if (index == 0) {
        String query = '${emp.roles}';
        if (emp.location != null) {
          query += ',${emp.location?.id}';
        }
        res = await api.customer.find(
          num: pageKey,
          query: query,
        );
      } else {
        res = await api.customer.find(
          num: pageKey,
          query: id,
        );
      }

      if (res.next == null) {
        state.appendLastPage(res.items);
      } else {
        final nextPageKey = pageKey + 1;
        state.appendPage(res.items, nextPageKey);
      }
      return;
    } catch (e) {
      if (mounted) {
        state.error = e.toString();
      }
      return;
    }
  }
}
