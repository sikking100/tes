import 'package:api/api.dart';
import 'package:common/view/text_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:common/common.dart';

final orderApprovalsProvider = FutureProvider.family.autoDispose<List<OrderApply>, int>((ref, arg) async {
  return ref.read(apiProvider).orderApply.find(arg);
});

class PageApprovalOrder extends StatelessWidget {
  const PageApprovalOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Overlimit / Overdue'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Menunggu Persetujuan'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ViewWaitApprove(), ViewHistory()],
        ),
      ),
    );
  }
}

class ViewHistory extends ConsumerWidget {
  const ViewHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(orderApprovalsProvider(1));
    return RefreshIndicator.adaptive(
      child: history.when(
        data: (data) {
          if (data.isEmpty) {
            return ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.2,
                  alignment: Alignment.center,
                  child: const Text('Belum ada data'),
                )
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return WidgetOrderApplyItem(
                item: item,
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 0),
          );
        },
        error: (error, stackTrace) => WidgetError(
          error: error.toString(),
          onPressed: () => ref.invalidate(orderApprovalsProvider(1)),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      onRefresh: () async => ref.invalidate(orderApprovalsProvider(1)),
    );
  }
}

class WidgetOrderApplyItem extends StatelessWidget {
  const WidgetOrderApplyItem({
    super.key,
    required this.item,
  });

  final OrderApply item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.location_city),
      title: TextCopy(text: 'ID Approval : ${item.id}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overlimit:'),
              Text(item.overlimit.currency()),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overdue:'),
              Text(item.overdue.currency()),
            ],
          ),
          const SizedBox(height: 4),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: const [
          //     Text('Additional Discount'),
          //     Text('item.additionalDiscount.currency()'),
          //   ],
          // ),
        ],
      ),
      onTap: () => Navigator.pushNamed(context, Routes.approvalOrderDetail, arguments: item),
    );
  }
}

class ViewWaitApprove extends ConsumerWidget {
  const ViewWaitApprove({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitApprove = ref.watch(orderApprovalsProvider(0));
    return RefreshIndicator.adaptive(
      child: waitApprove.when(
        data: (data) {
          if (data.isEmpty) {
            return ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.2,
                  alignment: Alignment.center,
                  child: const Text('Belum ada data'),
                )
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return WidgetOrderApplyItem(
                item: item,
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 0),
          );
        },
        error: (error, stackTrace) => WidgetError(
          error: error.toString(),
          onPressed: () => ref.invalidate(orderApprovalsProvider(0)),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      onRefresh: () async => ref.invalidate(orderApprovalsProvider(0)),
    );
  }
}

// class PageApprovalOrder extends ConsumerStatefulWidget {
//   const PageApprovalOrder({super.key});

//   @override
//   ConsumerState<PageApprovalOrder> createState() => _PageApprovalOrderState();
// }

// class _PageApprovalOrderState extends ConsumerState<PageApprovalOrder> {
//   late Api _api;
//   final PagingController<int, OrderApply> _waitingController = PagingController(
//     firstPageKey: 1,
//   );
//   final PagingController<int, OrderApply> _approveController = PagingController(
//     firstPageKey: 1,
//   );

//   bool isLoading1 = false;
//   bool isLoading2 = false;

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void _getOrderApplyWaiting(int pageKey) async {
//     try {
//       final res = await _api.orderApply.find(0);
//       _waitingController.appendLastPage(res);
//     } catch (e) {
//       log(e.toString());
//       _waitingController.error = e;
//     }
//   }

//   void _getOrderApplyApprove(int pageKey) async {
//     try {
//       final res = await _api.orderApply.find(1);
//       _approveController.appendLastPage(res);
//     } catch (e) {
//       log(e.toString());
//       _approveController.error = e;
//     }
//   }

//   @override
//   void initState() {
//     _api = ref.read(apiProvider);
//     _waitingController.addPageRequestListener(
//       (pageKey) => _getOrderApplyWaiting(pageKey),
//     );
//     _approveController.addPageRequestListener(
//       (pageKey) => _getOrderApplyApprove(pageKey),
//     );
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: 
//       Scaffold(
//         appBar: AppBar(
//           title: const Text('Overlimit / Overdue'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Menunggu Persetujuan'),
//               Tab(text: 'Riwayat'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             RefreshIndicator.adaptive(
//               child: PagedListView<int, OrderApply>.separated(
//                 pagingController: _waitingController,
//                 padding: const EdgeInsets.all(16),
//                 builderDelegate: PagedChildBuilderDelegate<OrderApply>(
//                   noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
//                   itemBuilder: (context, item, index) => ListTile(
//                     horizontalTitleGap: 0,
//                     contentPadding: EdgeInsets.zero,
//                     leading: const Icon(Icons.location_city),
//                     title: Text(item.id),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Over Limit:'),
//                             Text('item.overLimit.currency()'),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Over Due:'),
//                             Text('item.overDue.currency()'),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Additional Discount'),
//                             Text('item.additionalDiscount.currency()'),
//                           ],
//                         ),
//                       ],
//                     ),
//                     onTap: () => Navigator.pushNamed(context, Routes.approvalOrderDetail, arguments: item),
//                   ),
//                 ),
//                 separatorBuilder: (context, index) => const Divider(height: 0),
//               ),
//               onRefresh: () async => _waitingController.refresh(),
//             ),
//             RefreshIndicator.adaptive(
//               child: PagedListView<int, OrderApply>.separated(
//                 pagingController: _approveController,
//                 padding: const EdgeInsets.all(16),
//                 builderDelegate: PagedChildBuilderDelegate<OrderApply>(
//                   noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Belum ada data')),
//                   itemBuilder: (context, item, index) => ListTile(
//                     horizontalTitleGap: 0,
//                     contentPadding: EdgeInsets.zero,
//                     leading: const Icon(Icons.location_city),
//                     title: Text(item.id),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Over Limit:'),
//                             Text('item.overLimit.currency()'),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Over Due:'),
//                             Text('item.overDue.currency()'),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Additional Discount'),
//                             Text('item.additionalDiscount.currency()'),
//                           ],
//                         ),
//                       ],
//                     ),
//                     onTap: () => Navigator.pushNamed(context, Routes.approvalOrderDetail, arguments: item),
//                   ),
//                 ),
//                 separatorBuilder: (context, index) => const Divider(height: 0),
//               ),
//               onRefresh: () async => _approveController.refresh(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
