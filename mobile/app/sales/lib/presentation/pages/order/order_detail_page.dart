import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';

import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_copy_widget.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';
import 'package:sales/storage.dart';

final getImagePOFirebase = FutureProvider.autoDispose
    .family<String, String>((_, arg) => Storage.instance.getImageUrl(arg));

final orderStateNotifierProvider =
    FutureProvider.autoDispose.family<OrderDetail, String>((ref, arg) async {
  final api = ref.read(apiProvider);
  final order = await api.order.byId(arg);
  final invoice = await api.invoice.byOrder(arg);
  final delivery = await api.delivery.byOrder(arg);
  return OrderDetail(order, delivery, invoice);
});

class OrderDetail {
  final Order order;
  final List<Delivery> deliveries;
  final List<Invoice> invoices;

  Invoice get invoice =>
      invoices.firstWhere((element) => element.id == order.invoiceId);

  Delivery get delivery =>
      deliveries.firstWhere((element) => element.id == order.deliveryId);

  OrderDetail(this.order, this.deliveries, this.invoices);
}

final loadingOrderDetailProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

class OrderDetailPage extends ConsumerWidget {
  final String id;
  const OrderDetailPage({Key? key, required this.id}) : super(key: key);

  int price(int price, int qty, int disc) {
    final res = price * qty;
    final resd = disc * qty;
    return res - resd;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderStateNotifierProvider(id));

    final theme = Theme.of(context);
    final green = theme.textTheme.bodyMedium?.copyWith(
      color: mOrderHistoryTitleColor,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: RefreshIndicator(
          color: theme.primaryColor,
          notificationPredicate: (notification) {
            return notification.metrics.axis == Axis.vertical;
          },
          onRefresh: () async {},
          child: order.when(
            data: (data) {
              final filePo =
                  ref.watch(getImagePOFirebase(data.order.poFilePath));
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverPadding(
                      padding: const EdgeInsets.all(Dimens.px16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(data.order.id, style: green),
                                const SizedBox(
                                  width: 4,
                                ),
                                Copy(text: data.order.id),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(data.order.customer.name, style: green),
                                const SizedBox(
                                  width: 4,
                                ),
                                SizedBox(
                                  height: Dimens.px16,
                                  width: Dimens.px14,
                                  child: IconButton(
                                    splashRadius: 24,
                                    padding: EdgeInsets.zero,
                                    iconSize: Dimens.px14,
                                    color: mArrowIconColor,
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () async {
                                      await ref
                                          .read(apiProvider)
                                          .customer
                                          .byId(data.order.customer.id)
                                          .then(
                                        (value) {
                                          ref
                                              .read(customerStateProvider
                                                  .notifier)
                                              .update((state) => value);
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.businessDetail,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(data.delivery.deliveryAt.fullDate,
                                style: green),
                            const SizedBox(height: 4),
                            Text(
                                paymentMethodString(data.invoice.paymentMethod),
                                style: green),
                            Column(
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                    'Jatuh tempo: ${data.invoice.createdAt!.subtract(const Duration(days: 1)).date}',
                                    style: green),
                              ],
                            ),
                            filePo.when(
                              data: (po) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 22,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (po.contains("pdf")) {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.pdfsycn,
                                              arguments: {'pdfsync': po},
                                            );
                                          } else {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.photo,
                                              arguments: {'photo': po},
                                            );
                                          }
                                        },
                                        child: const Text('Lihat PO'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              error: (error, stackTrace) => const SizedBox(),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 700,
                                child: Table(
                                  columnWidths: const {
                                    0: IntrinsicColumnWidth(),
                                    1: IntrinsicColumnWidth(),
                                    2: IntrinsicColumnWidth(),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(),
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: Dimens.px8,
                                          ),
                                          child: Text(
                                            "Nama Produk",
                                            textAlign: TextAlign.start,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimens.px8,
                                              horizontal: Dimens.px30),
                                          child: Text(
                                            "Harga",
                                            textAlign: TextAlign.start,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimens.px8,
                                              horizontal: Dimens.px30),
                                          child: Text(
                                            "Jumlah",
                                            textAlign: TextAlign.start,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimens.px8),
                                          child: Text(
                                            "Total",
                                            textAlign: TextAlign.end,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimens.px8),
                                          child: Text(
                                            "Diskon",
                                            textAlign: TextAlign.end,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimens.px8),
                                          child: Text(
                                            "SubTotal",
                                            textAlign: TextAlign.end,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (var v in data.order.product)
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(),
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimens.px8),
                                            child: Text(
                                              '${v.name}, ${v.size}',
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimens.px8),
                                            child: Text(
                                              v.unitPrice.toInt().currency(),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimens.px8),
                                            child: Text(
                                              v.qty.toString(),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimens.px8),
                                            child: Text(
                                              (v.unitPrice * v.qty)
                                                  .toInt()
                                                  .currency(),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimens.px8),
                                            child: Text(
                                              (v.discount * v.qty)
                                                  .toInt()
                                                  .currency(),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimens.px8),
                                            child: Text(
                                              v.totalPrice.toInt().currency(),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (data.order.deliveryPrice > 0)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ongkos Kirim'),
                                  Text(data.order.deliveryPrice.currency()),
                                ],
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (data.invoice.paymentMethod ==
                                              PaymentMethod.trf ||
                                          data.order.status == 2)
                                      ? 'Total Bayar'
                                      : 'Total Tagihan',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                Text(
                                  (data.order.productPrice +
                                          data.order.deliveryPrice)
                                      .toInt()
                                      .currency(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                            )
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimens.px16),
                      child: TabBar(
                        tabs: [Tab(text: 'Invoice'), Tab(text: 'Pengantaran')],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          InvoiceView(
                            order: data.order,
                            delivery: data.deliveries,
                            invoice: data.invoices,
                          ),
                          DeliveryView(
                              order: data.order, delivery: data.deliveries),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) => Center(
              child: Text('$error'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ),
      ),
    );
  }

  Widget text(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: Dimens.px16),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class InvoiceView extends ConsumerWidget {
  final Order order;
  final List<Invoice> invoice;
  final List<Delivery> delivery;
  const InvoiceView(
      {super.key,
      required this.order,
      required this.invoice,
      required this.delivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const paid = 0;
    final theme = Theme.of(context);

    if (order.status == 6) {
      return const SizedBox();
    }
    if (invoice.first.status == 1 &&
        invoice.first.paymentMethod == PaymentMethod.trf) {
      return Center(
        child: Consumer(
          builder: (context, ref, child) => ElevatedButton(
            onPressed: () async {
              try {
                ref
                    .watch(loadingOrderDetailProvider.notifier)
                    .update((state) => true);
                await ref
                    .read(apiProvider)
                    .invoice
                    .create(order.invoiceId)
                    .then(
                  (value) {
                    Future.delayed(
                      const Duration(seconds: 5),
                      () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.webview,
                          arguments: {
                            'url': value.url,
                            'title': 'Transaksi',
                          },
                        );
                        ref
                            .watch(loadingOrderDetailProvider.notifier)
                            .update((state) => false);
                      },
                    );
                  },
                );
              } catch (e) {
                AppScaffoldMessanger.showSnackBar(
                    context: context, message: e.toString());
              }
            },
            child: ref.watch(loadingOrderDetailProvider) == false
                ? const Text('Bayar Sekarang')
                : const SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.px16),
      separatorBuilder: (context, index) => const SizedBox(
        height: Dimens.px16,
      ),
      itemCount: invoice.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(Dimens.px16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(StatusString.invoice(invoice.first.status),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(invoice.first.id),
                        const SizedBox(
                          width: 4,
                        ),
                        Copy(text: invoice.first.id),
                      ],
                    ),
                  ],
                ),
                if (invoice.length > 1 && invoice.first.status != 1)
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Terbayar'),
                          Text(invoice.first.paid.toInt().currency()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     const Text('Sisa'),
                      //     Text((order.price +
                      //             order.additionalDiscount +
                      //             (order.delivery.items.isEmpty
                      //                 ? 0
                      //                 : order.delivery.items.first.price) -
                      //             order.invoice.pay)
                      //         .currency()),
                      //   ],
                      // ),
                    ],
                  ),
                // Column(
                //   children: [
                //     const SizedBox(height: 4),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(invoice.first.status == Status.intPending
                //             ? 'Jumlah Tagihan'
                //             : 'Jumlah Pembayaran'),
                //         Text((price +
                //                 additionalDiscount +
                //                 (delivery.isEmpty
                //                     ? 0
                //                     : delivery.))
                //             .currency()),
                //       ],
                //     ),
                //   ],
                // ),
                if (invoice.first.status == 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* Start Hitung Mundur Wakut Pembayaran
                      const SizedBox(height: Dimens.px16),
                      CountdownTimer(
                        endTime:
                            invoice.first.createdAt!.millisecondsSinceEpoch,
                        widgetBuilder: (_, time) {
                          if (time == null) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Batas Waktu Pembayaran',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${time.days ?? ''}${time.days != null ? ' Hari : ' : ''}${time.hours ?? ''}${time.hours != null ? ' Jam : ' : ''}${time.min ?? ''}${time.min != null ? ' Menit : ' : ''}${time.sec ?? ''}${time.sec != null ? ' Detik' : ''}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: mPrimaryColor),
                              ),
                              const SizedBox(height: Dimens.px12),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final dataInv = invoice[index];
                                    if (dataInv.status == 1) {
                                      ref
                                          .read(loadingOrderDetailProvider
                                              .notifier)
                                          .update((state) => true);
                                      await Navigator.pushNamed(
                                        context,
                                        AppRoutes.webview,
                                        arguments: {
                                          'url': dataInv.url,
                                          'title': 'Invoice',
                                        },
                                      );
                                      ref
                                          .read(loadingOrderDetailProvider
                                              .notifier)
                                          .update((state) => false);
                                      return;
                                    }
                                    if (invoice.length == 1) {
                                      ref
                                          .read(loadingOrderDetailProvider
                                              .notifier)
                                          .update((state) => true);

                                      ref
                                          .read(apiProvider)
                                          .invoice
                                          .create(order.id)
                                          .then(
                                            (value) => Navigator.pushNamed(
                                                context, AppRoutes.webview,
                                                arguments: {
                                                  'url': invoice
                                                      .firstWhere((element) =>
                                                          element.id ==
                                                          invoice[index].id)
                                                      .url,
                                                  'title': 'Invoice',
                                                }),
                                          )
                                          .then((value) => ref
                                              .read(loadingOrderDetailProvider
                                                  .notifier)
                                              .update((state) => false));

                                      return;
                                    }
                                    await showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final textEditingController =
                                                TextEditingController();
                                            final loading = ref.watch(
                                                loadingOrderDetailProvider);

                                            return Column(
                                              children: [
                                                TextField(
                                                  controller:
                                                      textEditingController,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                    CurrencyInputFormatter(),
                                                  ],
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Masukkan nominal bayar',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: loading
                                                      ? null
                                                      : () async {
                                                          try {
                                                            ref
                                                                .read(loadingOrderDetailProvider
                                                                    .notifier)
                                                                .update(
                                                                    (state) =>
                                                                        true);
                                                            if (textEditingController
                                                                    .text
                                                                    .isEmpty ||
                                                                textEditingController
                                                                        .text ==
                                                                    '0') {
                                                              return;
                                                            }
                                                            final input = int.parse(
                                                                textEditingController
                                                                    .text
                                                                    .split('.')
                                                                    .join());
                                                            logger.info(input);
                                                            if (input > paid) {
                                                              throw 'Nominal bayar tidak boleh melebihi sisa tagihan';
                                                            }
                                                            final result =
                                                                paid - input;
                                                            if (input < 50000) {
                                                              throw 'Nominal bayar tidak boleh kurang dari Rp50.000';
                                                            }
                                                            if (result > 1 &&
                                                                result <
                                                                    50000) {
                                                              throw 'Sisa tagihan tidak boleh kurang dari Rp50.000';
                                                            }

                                                            ref
                                                                .read(
                                                                    apiProvider)
                                                                .invoice
                                                                .create(
                                                                    order.id)
                                                                .then(
                                                                  (value) =>
                                                                      Navigator
                                                                          .popAndPushNamed(
                                                                    context,
                                                                    AppRoutes
                                                                        .webview,
                                                                    arguments: {
                                                                      'url': invoice
                                                                          .firstWhere(
                                                                            (element) =>
                                                                                element.id ==
                                                                                invoice[index].id,
                                                                          )
                                                                          .url,
                                                                      'title':
                                                                          'Invoice',
                                                                    },
                                                                  ),
                                                                );
                                                            return;
                                                          } catch (e) {
                                                            AppActionDialog.show(
                                                                context:
                                                                    context,
                                                                title: "Oops!",
                                                                content: e
                                                                    .toString(),
                                                                isAction:
                                                                    false);
                                                            return;
                                                          } finally {
                                                            ref
                                                                .read(loadingOrderDetailProvider
                                                                    .notifier)
                                                                .update(
                                                                    (state) =>
                                                                        false);
                                                          }
                                                        },
                                                  child: loading
                                                      ? const FittedBox(
                                                          child:
                                                              CircularProgressIndicator
                                                                  .adaptive())
                                                      : const Text(
                                                          'Bayar Sekarang'),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                    return;
                                  } catch (e) {
                                    AppActionDialog.show(
                                        context: context,
                                        title: "Oops!",
                                        content: e.toString(),
                                        isAction: false);
                                    return;
                                  }
                                },
                                child: const Text('Bayar Sekarang'),
                              ),
                            ],
                          );
                        },
                      ),
                      //* End Hitung Mundur Wakut Pembayaran
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DeliveryView extends StatelessWidget {
  final Order order;
  final List<Delivery> delivery;
  const DeliveryView({super.key, required this.order, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.px16),
      separatorBuilder: (context, index) => const SizedBox(
        height: Dimens.px16,
      ),
      itemCount: delivery.length,
      itemBuilder: (context, index) {
        final dataDel = delivery[index];
        // final broken = delivery[index]
        //     .product
        //     .map((e) => e.brokenQty)
        //     .reduce((value, element) => value + element);
        final pending = delivery[index]
            .product
            .map((e) => e.deliveryQty)
            .reduce((value, element) => value + element);

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(Dimens.px16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StatusString.delivery(dataDel.status),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(dataDel.id),
                          const SizedBox(
                            width: 4,
                          ),
                          Copy(text: dataDel.id),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: IconButton(
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(Dimens.px30),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return Container(
                            height:
                                MediaQuery.of(context).size.height * 89 / 100,
                            padding: const EdgeInsets.all(Dimens.px16),
                            child: Column(
                              children: [
                                Text(
                                  'Daftar Pengantaran',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: Dimens.px16),
                                Expanded(
                                  child: ListView.separated(
                                    itemBuilder: (_, i) {
                                      List<DeliveryProduct> listProduct = [];
                                      listProduct = delivery[index].product;
                                      listProduct.sort(
                                          (a, b) => a.name.compareTo(b.name));
                                      final antar = dataDel.status == 6
                                          ? listProduct[i].deliveryQty
                                          : listProduct[i].brokenQty;

                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text('${i + 1}'),
                                              const SizedBox(
                                                  width: Dimens.px10),
                                              Material(
                                                color: theme.highlightColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimens.px12),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      Dimens.px10),
                                                  child: AppImagePrimary(
                                                    isOnTap: true,
                                                    imageUrl:
                                                        listProduct[i].imageUrl,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: Dimens.px10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${listProduct[i].name.firstLetter}, ${listProduct[i].size}',
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        '${dataDel.status == 6 ? 'Diterima' : 'Diantar'} $antar pcs'),
                                                    if (pending > 0)
                                                      Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            'Pending $pending pcs',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider()
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(),
                                    itemCount: delivery[index].product.length,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
