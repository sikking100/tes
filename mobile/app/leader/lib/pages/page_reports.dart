import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/argument.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/routes.dart';

final reportStateNotifierProvider = StateNotifierProvider.autoDispose.family<ReportNotifier, PagingController<int, Report>, int>((ref, index) {
  return ReportNotifier(ref, index);
});

class ReportNotifier extends StateNotifier<PagingController<int, Report>> {
  ReportNotifier(this.ref, this.index) : super(PagingController(firstPageKey: 1)) {
    api = ref.read(apiProvider);
    state.addPageRequestListener((pageKey) => fetch(pageKey));
  }

  late Api api;
  final int index;
  final AutoDisposeRef ref;

  void fetch(int key) async {
    try {
      final emp = ref.read(employeeStateProvider);

      Paging<Report> res;
      if (index == 0) {
        res = await api.report.findAll(
          num: key,
          to: emp.id,
        );
      } else {
        res = await api.report.findAll(
          num: key,
          from: emp.id,
        );
      }

      if (res.next == null) {
        state.appendLastPage(res.items);
      } else {
        state.appendPage(res.items, key + 1);
      }
    } catch (e) {
      state.error = e;
    }
  }
}

class PageReports extends ConsumerWidget {
  const PageReports({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masuk = ref.watch(reportStateNotifierProvider(0));
    final keluar = ref.watch(reportStateNotifierProvider(1));
    final emp = ref.watch(employeeStateProvider);
    final loading = ref.watch(loadingStateProvider);
    if (emp.roles == UserRoles.am) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Keluar'),
        ),
        floatingActionButton: floating(loading, emp, ref, context, keluar),
        body: RefreshIndicator.adaptive(
          onRefresh: () => Future.sync(keluar.refresh),
          child: PagedListView.separated(
            pagingController: keluar,
            builderDelegate: PagedChildBuilderDelegate<Report>(
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
              itemBuilder: (context, item, index) => ListTile(
                onTap: () => Navigator.pushNamed(context, Routes.report, arguments: ArgReport(item.id, false)

                    // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailLaporan(id: item.id, isMasuk: false))
                    ),
                title: Text(item.to.name),
                subtitle: Text(roleString(item.to.roles)),
                trailing: Text(item.sendDate?.fullDateTime ?? ''),
              ),
            ),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      );
    }

    if ((emp.roles == UserRoles.gm && emp.team == Team.food) || (emp.roles == UserRoles.direktur)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Masuk'),
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () => Future.sync(keluar.refresh),
          child: PagedListView.separated(
            pagingController: masuk,
            builderDelegate: PagedChildBuilderDelegate<Report>(
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
              itemBuilder: (context, item, index) => ListTile(
                onTap: () => Navigator.pushNamed(context, Routes.report, arguments: ArgReport(item.id)),
                title: Text(item.from.name),
                subtitle: Text(roleString(item.from.roles)),
                trailing: Text(item.sendDate?.fullDateTime ?? ''),
              ),
            ),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Masuk'),
              Tab(text: 'Keluar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(masuk.refresh),
              child: PagedListView.separated(
                pagingController: masuk,
                builderDelegate: PagedChildBuilderDelegate<Report>(
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
                  itemBuilder: (context, item, index) => ListTile(
                    onTap: () => Navigator.pushNamed(context, Routes.report, arguments: ArgReport(item.id)),
                    title: Text(item.from.name),
                    subtitle: Text(roleString(item.from.roles)),
                    trailing: Text(item.sendDate?.fullDateTime ?? ''),
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(keluar.refresh),
              child: PagedListView.separated(
                pagingController: keluar,
                builderDelegate: PagedChildBuilderDelegate<Report>(
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
                  itemBuilder: (context, item, index) => ListTile(
                    onTap: () => Navigator.pushNamed(context, Routes.report, arguments: ArgReport(item.id, false)),
                    title: Text(item.to.name),
                    subtitle: Text(roleString(item.to.roles)),
                    trailing: Text(item.sendDate?.fullDateTime ?? ''),
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        ),
        floatingActionButton: floating(loading, emp, ref, context, keluar),
      ),
    );
  }

  FloatingActionButton floating(bool loading, Employee emp, WidgetRef ref, BuildContext context, PagingController<int, Report> keluar) {
    return FloatingActionButton(
      onPressed: loading
          ? null
          : () async {
              try {
                ref.read(loadingStateProvider.notifier).update((state) => true);
                String query = '';
                if (emp.roles == UserRoles.am) {
                  final branch = await ref.read(apiProvider).branch.byId(emp.location?.id ?? 'id');
                  query = '${UserRoles.rm},${emp.team},${branch.region?.id}';
                } else if (emp.roles == UserRoles.rm) {
                  if (emp.team == Team.food) {
                    query = '${UserRoles.nsm},${emp.team}';
                  } else {
                    query = '${UserRoles.gm},${emp.team}';
                  }
                } else if (emp.roles == UserRoles.nsm && emp.team == Team.food) {
                  query = '${UserRoles.gm},${emp.team}';
                } else if (emp.roles == UserRoles.gm && emp.team == Team.retail) {
                  query = '${UserRoles.direktur},${emp.team}';
                }
                final empl = await ref.read(apiProvider).employee.find(query: query);

                if (context.mounted) {
                  Navigator.pushNamed(context, Routes.reportAdd, arguments: empl.items.first).then((value) => keluar.refresh());
                }
                ref.read(loadingStateProvider.notifier).update((state) => false);
                return;
              } catch (e) {
                Alerts.dialog(context, content: '$e');
                return;
              }
              // if (emp.roles == UserRoles.am) {
              //   Navigator.pushNamed(context, Routes.leaders);
              //   return;
              // } else {
              //   String query = '';
              //   if (emp.location != null) {
              //     query += '${emp.location?.id}';
              //   }

              //   ref.read(apiProvider).employee.find(num: 1, limit: 50, query: query).then(
              //     (value) {
              //       (emp);
              //       Employee empl = value.items.first;
              //       if (emp.roles == UserRoles.rm) {
              //         if (emp.team == Team.food) {
              //           empl = value.items.firstWhere((element) => element.roles == UserRoles.nsm);
              //         } else {
              //           empl = value.items.firstWhere((element) => element.roles == UserRoles.gm);
              //         }
              //       }

              //       if (emp.roles == UserRoles.nsm) {
              //         empl = value.items.firstWhere((element) => element.roles == UserRoles.gm);
              //       }

              //       if (emp.roles == UserRoles.gm) {
              //         empl = value.items.firstWhere((element) => element.roles == UserRoles.direktur);
              //       }
              //       return Navigator.pushNamed(context, Routes.reportAdd, arguments: empl).then((value) => keluar.refresh());
              //     },
              //   ).catchError((e) => Alerts.dialog(context, content: e.toString()));
              // }
            },
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : const Icon(Icons.add),
    );
  }
}
