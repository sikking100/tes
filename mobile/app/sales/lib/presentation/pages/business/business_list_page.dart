import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/business/widget/business_widget.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer_customer.dart';

class BusinessListPage extends ConsumerStatefulWidget {
  const BusinessListPage({super.key});

  @override
  ConsumerState<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends ConsumerState<BusinessListPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Tab> tabs = [
    const Tab(text: 'Saya'),
    const Tab(text: 'Cabang'),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pelanggan'),
          bottom: TabBar(
            tabs: tabs,
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.extentAfter == 0.0) {
                setState(
                  () {
                    _currentIndex = 1;
                  },
                );
              }
              if (notification.metrics.extentBefore == 0.0) {
                setState(
                  () {
                    _currentIndex = 0;
                  },
                );
              }
            }
            return true;
          },
          child: const TabBarView(
            children: [MyBusiness(), BusinessInBranch()],
          ),
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.businessCreate),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}

class MyBusiness extends ConsumerStatefulWidget {
  const MyBusiness({super.key});

  @override
  ConsumerState<MyBusiness> createState() => _MyBusinessState();
}

class _MyBusinessState extends ConsumerState<MyBusiness> {
  final PagingController<int, Customer> _pagingMyBusinessController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    _pagingMyBusinessController.addPageRequestListener((pageKey) {
      _fetchCustomer(pageKey);
    });
  }

  Future<void> _fetchCustomer(int pageKey) async {
    try {
      final api = ref.read(apiProvider);
      final mEmployee = ref.watch(employee);
      final res = await api.customer.find(
        query: mEmployee.roles.toString(),
      );
      if (res.items.isNotEmpty) {
        _pagingMyBusinessController.appendLastPage(
            res.items.where((element) => element.business != null).toList());
      } else {
        _pagingMyBusinessController.appendPage(
            res.items.where((element) => element.business != null).toList(),
            pageKey + 1);
      }
    } catch (error) {
      _pagingMyBusinessController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () async {
        _pagingMyBusinessController.refresh();
      },
      child: PagedListView.separated(
          padding: const EdgeInsets.all(Dimens.px16),
          pagingController: _pagingMyBusinessController,
          builderDelegate: PagedChildBuilderDelegate<Customer>(
            itemBuilder: (_, itemCus, index) {
              return BusinessWidget(
                customer: itemCus,
              );
            },
            newPageProgressIndicatorBuilder: (context) =>
                const AppShimmerCustomer(),
            firstPageProgressIndicatorBuilder: (_) =>
                const AppShimmerCustomer(),
            noItemsFoundIndicatorBuilder: (_) => const AppEmptyWidget(
              title: "Belum ada pelanggan",
            ),
          ),
          separatorBuilder: (_, index) => const SizedBox()),
    );
  }
}

class BusinessInBranch extends ConsumerStatefulWidget {
  const BusinessInBranch({super.key});

  @override
  ConsumerState<BusinessInBranch> createState() => _BusinessInBranchState();
}

class _BusinessInBranchState extends ConsumerState<BusinessInBranch> {
  final PagingController<int, Customer> _pagingMyBusinessController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    _pagingMyBusinessController.addPageRequestListener((pageKey) {
      _fetchCustomer(pageKey);
    });
  }

  Future<void> _fetchCustomer(int pageKey) async {
    try {
      final api = ref.read(apiProvider);
      final mEmployee = ref.watch(employee);
      final res = await api.customer.find(
        query: mEmployee.location!.id,
      );
      if (res.items.isNotEmpty) {
        _pagingMyBusinessController.appendLastPage(
            res.items.where((element) => element.business != null).toList());
      } else {
        _pagingMyBusinessController.appendPage(
            res.items.where((element) => element.business != null).toList(),
            pageKey + 1);
      }
    } catch (error) {
      _pagingMyBusinessController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () async {
        _pagingMyBusinessController.refresh();
      },
      child: PagedListView.separated(
          padding: const EdgeInsets.all(Dimens.px16),
          pagingController: _pagingMyBusinessController,
          builderDelegate: PagedChildBuilderDelegate<Customer>(
            itemBuilder: (_, itemCus, index) {
              return BusinessWidget(
                customer: itemCus,
              );
            },
            newPageProgressIndicatorBuilder: (context) =>
                const AppShimmerCustomer(),
            firstPageProgressIndicatorBuilder: (_) =>
                const AppShimmerCustomer(),
            noItemsFoundIndicatorBuilder: (_) => const AppEmptyWidget(
              title: "Belum ada pelanggan",
            ),
          ),
          separatorBuilder: (_, index) => const SizedBox()),
    );
  }
}

// class BusinessInBranch extends ConsumerStatefulWidget {
//   const BusinessInBranch({super.key});

//   @override
//   ConsumerState<BusinessInBranch> createState() => _BusinessApplyState();
// }

// class _BusinessApplyState extends ConsumerState<BusinessInBranch> {
//   final PagingController<int, Apply> _pagingBusinessApllyController =
//       PagingController(firstPageKey: 1);
//   @override
//   void initState() {
//     super.initState();
//     _pagingBusinessApllyController.addPageRequestListener((pageKey) {
//       _fetchCustomer(pageKey);
//     });
//   }

//   Future<void> _fetchCustomer(int pageKey) async {
//     try {
//       final api = ref.read(apiProvider);
//       final emp = ref.watch(employee);
//       logger.info(emp);
//       final res = await api.apply.find(userId: emp.id);
//       if (res.items.isNotEmpty) {
//         _pagingBusinessApllyController.appendLastPage(res.items);
//       } else {
//         _pagingBusinessApllyController.appendPage(res.items, pageKey + 1);
//       }
//     } catch (error) {
//       _pagingBusinessApllyController.error = error;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       color: theme.primaryColor,
//       onRefresh: () async {
//         _pagingBusinessApllyController.refresh();
//       },
//       child: PagedListView.separated(
//           padding: const EdgeInsets.all(Dimens.px16),
//           pagingController: _pagingBusinessApllyController,
//           builderDelegate: PagedChildBuilderDelegate<Apply>(
//             itemBuilder: (_, itemCus, index) {
//               return BusinessWidget(
//                 customer: itemCus,
//               );
//             },
//             newPageProgressIndicatorBuilder: (context) =>
//                 const AppShimmerCustomer(),
//             firstPageProgressIndicatorBuilder: (_) =>
//                 const AppShimmerCustomer(),
//             noItemsFoundIndicatorBuilder: (_) => const AppEmptyWidget(
//               title: "Belum ada riwayat hari ini",
//             ),
//           ),
//           separatorBuilder: (_, index) => const SizedBox()),
//     );
//   }
// }

// class BusinessListPage extends ConsumerStatefulWidget {
//   const BusinessListPage({super.key});

//   @override
//   ConsumerState<BusinessListPage> createState() => _BusinessListPageState();
// }

// class _BusinessListPageState extends ConsumerState<BusinessListPage>
//     with SingleTickerProviderStateMixin {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pelanggan'),
//       ),
//       body: NotificationListener(
//           onNotification: (notification) {
//             if (notification is ScrollUpdateNotification) {
//               if (notification.metrics.extentAfter == 0.0) {
//                 setState(
//                   () {
//                     _currentIndex = 1;
//                   },
//                 );
//               }
//               if (notification.metrics.extentBefore == 0.0) {
//                 setState(
//                   () {
//                     _currentIndex = 0;
//                   },
//                 );
//               }
//             }
//             return true;
//           },
//           child: const MyBusiness()),
//       floatingActionButton: _currentIndex == 0
//           ? FloatingActionButton(
//               onPressed: () =>
//                   Navigator.pushNamed(context, AppRoutes.businessCreate),
//               child: const Icon(Icons.add),
//             )
//           : null,
//     );
//   }
// }