import 'package:api/api.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/view/text_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/function.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:leader/pages/page_approval_order.dart';
import 'package:leader/routes.dart';

final orderApproverNotifierProvider = StateNotifierProvider.autoDispose<OrderApproveNotifier, bool>((ref) {
  return OrderApproveNotifier(ref);
});

final orderProvider = FutureProvider.autoDispose.family<OrderDetail, String>((ref, arg) async {
  final api = ref.read(apiProvider);
  final order = await api.order.byId(arg);
  final deliveries = await api.delivery.byOrder(order.id);
  final invoices = await api.invoice.byOrder(order.id);
  return OrderDetail(order, deliveries, invoices);
});

final transactionProvider = FutureProvider.autoDispose.family<Map<String, double>, String>((ref, arg) async {
  final api = ref.read(apiProvider);
  final lastMonth = await api.order.lastMonth(arg);
  final perMonth = await api.order.perMonth(arg);
  return {'last': lastMonth, 'per': perMonth};
});

class OrderApproveNotifier extends StateNotifier<bool> {
  OrderApproveNotifier(this.ref) : super(false) {
    _api = ref.read(apiProvider);
    note = TextEditingController();
  }
  late Api _api;
  final AutoDisposeRef ref;

  late TextEditingController note;

  Future action({required bool isAccept, required String orderId, required List<UserApprover> approver}) async {
    final emp = ref.read(employeeStateProvider);

    try {
      final req = Approval(
        userId: emp.id,
        note: note.text,
        userApprover: approver,
      );
      if (isAccept) {
        state = true;
        await _api.orderApply.approve(id: orderId, req: req);
      } else {
        ref.read(loadingStateProvider.notifier).update((state) => true);
        await _api.orderApply.reject(id: orderId, req: req);
      }
      return;
    } catch (e) {
      rethrow;
    } finally {
      if (isAccept) {
        state = false;
      } else {
        ref.read(loadingStateProvider.notifier).update((state) => false);
      }
    }
  }
}

class PageOrderApprovalDetail extends ConsumerWidget {
  static const String orderApprovalDetail = '/order-approval-detail';
  final OrderApply orderApply;
  const PageOrderApprovalDetail({super.key, required this.orderApply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = ref.watch(employeeStateProvider);
    final transaction = ref.watch(transactionProvider(orderApply.customerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlimit / Overdue Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.location_city),
              title: TextCopy(text: 'ID Approval : ${orderApply.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status"),
                      Text(StatusString.orderApply(orderApply.status)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Overlimit:'),
                      Text(orderApply.overlimit.currency()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Overdue:'),
                      Text(orderApply.overdue.currency()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  transaction.when(
                    data: (data) => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Transaksi Bulan Lalu"),
                            Text(data['last']!.currency()),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Transaksi Rata - Rata"),
                            Text(data['per']!.currency()),
                          ],
                        ),
                      ],
                    ),
                    error: (error, stackTrace) => Text('$error'),
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: const [
                  //     Text('Additional Discount'),
                  //     Text('orderApply.additionalDiscount.currency()'),
                  //   ],
                  // ),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - (MediaQuery.of(context).size.height * 10 / 100),
                      child: Column(
                        children: [
                          const SizedBox(height: Dimens.px16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            height: 5,
                            width: 50,
                          ),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final res = ref.watch(orderProvider(orderApply.id));
                                return res.when(
                                  data: (data) => Padding(
                                    padding: const EdgeInsets.all(Dimens.px16),
                                    child: CustomScrollView(
                                      slivers: [
                                        SliverToBoxAdapter(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextCopy(text: data.order.id),
                                              Text(
                                                data.delivery?.deliveryAt.fullDate ?? ' ',
                                                style: const TextStyle(color: mOrderHistoryTitleColor),
                                              ),
                                              Text(
                                                paymentMethodString(data.invoice.paymentMethod),
                                                style: const TextStyle(color: mOrderHistoryTitleColor),
                                              ),
                                              if (data.order.status == 3)
                                                const Text(
                                                  'Pesanan Dibatalkan',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              if (data.invoice.paymentMethod == 1)
                                                if (DateTime.now().isAfter(data.invoice.term ?? DateTime(2022, 12, 1)))
                                                  const Text(
                                                    'Tanggal jatuh tempo lewat',
                                                    style: TextStyle(color: Colors.red),
                                                  )
                                                else
                                                  Text(
                                                    'Jatuh tempo : ${data.order.createdAt?.subtract(const Duration(days: 1)).date}',
                                                    style: const TextStyle(color: mOrderHistoryTitleColor),
                                                  )
                                              else
                                                Container(),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                        SliverToBoxAdapter(
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width,
                                            child: Scrollbar(
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Table(
                                                  columnWidths: const {
                                                    0: IntrinsicColumnWidth(),
                                                    1: IntrinsicColumnWidth(),
                                                    2: IntrinsicColumnWidth(),
                                                    3: IntrinsicColumnWidth(),
                                                    4: IntrinsicColumnWidth(),
                                                    5: IntrinsicColumnWidth(),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color: Theme.of(context).brightness == Brightness.dark
                                                                  ? Colors.white24
                                                                  : const Color(0xFF000000)),
                                                        ),
                                                      ),
                                                      children: const [
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10),
                                                          child: Text(
                                                            'Nama',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10),
                                                          child: Text(
                                                            'Harga (Rp)',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.all(10),
                                                          child: Text(
                                                            'Jml',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10),
                                                          child: Text(
                                                            'Total (Rp)',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10),
                                                          child: Text(
                                                            'Diskon (Rp)',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10),
                                                          child: Text(
                                                            'Sub (Rp)',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    for (var v in data.order.product)
                                                      TableRow(
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color: Theme.of(context).brightness == Brightness.dark
                                                                  ? Colors.white24
                                                                  : const Color(0xFF000000),
                                                            ),
                                                          ),
                                                        ),
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                            child: Text(
                                                              '${v.name}, ${v.size} ',
                                                              // style: TextStyle(color: v.discount > 0 ? Colors.red : null),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(10),
                                                            child: Text(
                                                              v.unitPrice.currencyWithoutRp(),
                                                              textAlign: TextAlign.right,

                                                              // style: TextStyle(color: v.discount > 0 ? Colors.red : null),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(10),
                                                            child: Text(
                                                              v.qty.toString(),
                                                              textAlign: TextAlign.right,

                                                              // style: TextStyle(color: v.discount > 0 ? Colors.red : null),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(10),
                                                            child: Text(
                                                              (v.unitPrice * v.qty).currencyWithoutRp(),
                                                              textAlign: TextAlign.right,
                                                              // style: TextStyle(color: v.discount > 0 ? Colors.red : null),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.all(10),
                                                            child: Text(
                                                              (v.discount * v.qty).currencyWithoutRp(),
                                                              textAlign: TextAlign.right,
                                                              // style: TextStyle(color: v.discount > 0 ? Colors.red : null),
                                                            ),
                                                          ),
                                                          Container(
                                                            constraints: const BoxConstraints(minWidth: 100),
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                            child: Text(
                                                              (v.totalPrice).currencyWithoutRp(),
                                                              textAlign: TextAlign.right,
                                                              // style: TextStyle(color: v.discount > 0 ? Colors.red : null),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SliverToBoxAdapter(
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              if (data.deliveries.isNotEmpty && data.deliveries.first.price > 0)
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text('Total Belanja'),
                                                        Text(data.order.totalPrice.toInt().currency()),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text('Ongkos Kirim'),
                                                        Text(data.order.deliveryPrice.currency()),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    (data.invoice.paymentMethod == 2 || data.order.status == 2) ? 'Total Bayar' : 'Total Tagihan',
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                    ),
                                                  ),
                                                  Text(
                                                    (data.order.totalPrice).currency(),
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  error: (error, stackTrace) => Center(
                                    child: Text('$error'),
                                  ),
                                  loading: () => const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Lihat Detail Order'),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final load = ref.watch(loadingStateProvider);
                    return OutlinedButton(
                      onPressed: load
                          ? null
                          : () async {
                              ref.read(loadingStateProvider.notifier).update((state) => true);
                              final res = await ref.read(apiProvider).customer.byId(orderApply.customerId);
                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.businessDetail,
                                  arguments: ArgBusinessDetail(
                                    customer: res,
                                  ),
                                );
                              }
                              ref.read(loadingStateProvider.notifier).update((state) => false);
                              return;
                            },
                      child: load ? const BtnLoading() : child,
                    );
                  },
                  child: const Text('Lihat Detail Bisnis'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Approver",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // for (var approver in orderApply.user)
            for (int i = 0; i < orderApply.user.length; i++)
              Column(
                children: [
                  ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(orderApply.user[i].imageUrl),
                        radius: 100,
                      ),
                    ),
                    title: Text(orderApply.user[i].name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(roleString(orderApply.user[i].roles)),
                        Text(
                          orderApply.user[i].status == 1
                              ? i == 0
                                  ? orderApply.user[i].updatedAt!.toTimeago
                                  : orderApply.user[i - 1].updatedAt!.toTimeago
                              : orderApply.user[i].updatedAt!.toDDMMMMYYYYHH,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          "note: ${orderApply.user[i].note.isEmpty ? '-' : orderApply.user[i].note}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      color: orderApply.user[i].status == 0
                          ? Colors.orange
                          : orderApply.user[i].status == 2
                              ? Colors.green
                              : orderApply.user[i].status == 3
                                  ? Colors.red
                                  : Colors.grey,
                      orderApply.user[i].status == 0
                          ? Icons.pending
                          : orderApply.user[i].status == 2
                              ? Icons.check_circle
                              : orderApply.user[i].status == 3
                                  ? Icons.cancel
                                  : Icons.refresh,
                    ),
                  ),
                  const Divider(),
                ],
              )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: orderApply.isNotMe(emp.id)
            ? null
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(Dimens.px16).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final loading = ref.watch(orderApproverNotifierProvider);
                                final notifier = ref.watch(orderApproverNotifierProvider.notifier);
                                final loadingReject = ref.watch(loadingStateProvider);
                                return Form(
                                  autovalidateMode: AutovalidateMode.always,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: notifier.note,
                                        decoration: const InputDecoration(labelText: 'Masukkan catatan'),
                                        minLines: 3,
                                        maxLines: 5,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Catatan tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      ButtonBar(
                                        alignment: MainAxisAlignment.center,
                                        children: [
                                          OutlinedButton(
                                            onPressed: loadingReject
                                                ? null
                                                : () {
                                                    notifier
                                                        .action(isAccept: false, orderId: orderApply.id, approver: orderApply.userApprover)
                                                        .then(
                                                          (value) => Navigator.pop(context),
                                                        )
                                                        .then(
                                                          (value) => Navigator.pop(context),
                                                        )
                                                        .catchError((e) => Alerts.dialog(context, content: e.toString()));
                                                  },
                                            child: loadingReject ? const BtnLoading() : const Text('Tolak'),
                                          ),
                                          ElevatedButton(
                                            onPressed: loading
                                                ? null
                                                : () {
                                                    notifier
                                                        .action(isAccept: true, orderId: orderApply.id, approver: orderApply.userApprover)
                                                        .then(
                                                          (value) => Navigator.pop(context),
                                                        )
                                                        .then(
                                                          (value) => Navigator.pop(context),
                                                        )
                                                        .then((value) => ref.invalidate(orderApprovalsProvider(0)))
                                                        .catchError((e) => Alerts.dialog(context, content: e.toString()));
                                                  },
                                            child: loading ? const BtnLoading() : const Text('Terima'),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        child: const Text("Aksi"),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
