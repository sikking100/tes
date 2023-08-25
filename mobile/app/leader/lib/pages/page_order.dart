import 'dart:async';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/view/text_copy.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:leader/argument.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:leader/storage.dart';

final loadingAgainProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

final orderProvider = FutureProvider.autoDispose.family<OrderDetail, String>((ref, arg) async {
  final api = ref.read(apiProvider);
  final order = await api.order.byId(arg);
  final deliveries = await api.delivery.byOrder(order.id);
  final invoices = await api.invoice.byOrder(order.id);
  return OrderDetail(order, deliveries, invoices);
});

class TimerArgs extends Equatable {
  final DateTime dateTime;

  const TimerArgs(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

final timerStateNotifierProvider = StateNotifierProvider.autoDispose.family<TimerStateNotifier, String, TimerArgs>((ref, args) {
  return TimerStateNotifier(ref, args);
});

class TimerStateNotifier extends StateNotifier<String> {
  TimerStateNotifier(AutoDisposeRef ref, TimerArgs args) : super('') {
    final diff = args.dateTime.difference(DateTime.now());
    int jam = diff.inHours;
    int menit = diff.inMinutes.remainder(60);
    int detik = diff.inSeconds.remainder(60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (jam == 0 && menit == 0 && detik == 0) {
        timer.cancel();
        state = state;
      } else {
        if (detik > 0) {
          detik -= 1;
        } else if (menit > 0) {
          menit -= 1;
          detik = 59;
        } else if (jam > 0) {
          jam -= 1;
          menit = 59;
          detik = 59;
        }
      }
      state = '$jam jam : $menit menit : $detik detik';
      return;
    });
  }
  late final Timer _timer;
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

final businessDetailProvider = FutureProvider.autoDispose.family<Customer, String>((ref, id) async {
  return ref.read(apiProvider).customer.byId(id);
});

class PageOrder extends HookConsumerWidget {
  final String arg;
  const PageOrder({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingStateProvider);
    Future<void> orderAgain(Order order) async {
      try {
        ref.read(loadingStateProvider.notifier).update((state) => true);
        final result = await ref.read(apiProvider).customer.byId(order.customer.id);
        ref.read(customerStateProvider.notifier).update((state) => result);
        await Future.delayed(const Duration(seconds: 1));
        for (var p in order.product) {
          if (!ref.read(cartStateNotifier).map((e) => e.productId).contains(p.id)) {
            final product = await ref.read(apiProvider).product.byId("${order.branchId}-${p.id}");
            for (var i = 0; i < p.qty; i++) {
              ref.read(cartStateNotifier.notifier).add(product);
            }
          }
        }
        return;
      } catch (e) {
        rethrow;
      } finally {
        ref.read(loadingStateProvider.notifier).update((state) => false);
      }
    }

    final orderById = ref.watch(orderProvider(arg));
    final node = ref.watch(keyboardProvider(context));

    return DefaultTabController(
      length: 2,
      child: RefreshIndicator.adaptive(
        notificationPredicate: (notification) {
          return notification.depth == 2;
        },
        onRefresh: () async {
          ref.invalidate(orderProvider);
          return;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Detail Pesanan'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(Dimens.px16),
            child: orderById.when(
              data: (data) {
                final ongkir = data.order.deliveryPrice;
                final delivery = data.deliveries.firstWhere((element) => element.id == data.order.deliveryId);
                final invoice = data.invoices.firstWhere((element) => element.id == data.order.invoiceId);
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCopy(text: data.order.id),
                          Text(
                            data.order.customer.name,
                            style: const TextStyle(color: mOrderHistoryTitleColor),
                          ),
                          Text(
                            delivery.deliveryAt.fullDate,
                            style: const TextStyle(color: mOrderHistoryTitleColor),
                          ),
                          Text(
                            paymentMethodString(0),
                            style: const TextStyle(color: mOrderHistoryTitleColor),
                          ),
                          if (data.order.status == 3)
                            const Text(
                              'Pesanan Dibatalkan',
                              style: TextStyle(color: Colors.red),
                            ),
                          if (invoice.paymentMethod == PaymentMethod.top)
                            if (DateTime.now().isAfter(DateTime(2022, 12, 1)))
                              const Text(
                                'Tanggal jatuh tempo lewat',
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              Text(
                                'Jatuh tempo : ${invoice.term?.date}',
                                style: const TextStyle(color: mOrderHistoryTitleColor),
                              )
                          else
                            Container(),
                          const SizedBox(height: 10),
                          Consumer(
                            builder: (context, ref, child) {
                              final customer = ref.watch(businessDetailProvider(data.order.customer.id));
                              return customer.when(
                                data: (data) => ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, Routes.businessDetail, arguments: ArgBusinessDetail(customer: data)),
                                  child: const Text('Detail Business'),
                                ),
                                error: (error, stackTrace) => Container(),
                                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                              );
                            },
                          ),
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
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFF000000)),
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
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFF000000),
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
                          if (0 > 0 || ongkir > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Belanja'),
                                Text(data.order.totalBuy.currency()),
                              ],
                            ),
                          // if (0 > 0)
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text('Rate Khusus'),
                          //       Text(0.currency()),
                          //     ],
                          //   ),
                          if (ongkir > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ongkos Kirim'),
                                Text(ongkir.currency()),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (invoice.paymentMethod == PaymentMethod.trf || data.order.status == 2) ? 'Total Bayar' : 'Total Tagihan',
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
                          const SizedBox(height: 10),
                          if (data.order.poFilePath == '-')
                            ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () => orderAgain(data.order).then((value) => Navigator.pop(context)).then(
                                        (value) => Navigator.pushNamed(context, Routes.cart),
                                      ),
                              child: loading
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator.adaptive(),
                                    )
                                  : const Text('Order Lagi'),
                            )
                          else
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: loading
                                      ? null
                                      : () => orderAgain(data.order).then((value) => Navigator.pop(context)).then(
                                            (value) => Navigator.pushNamed(context, Routes.cart),
                                          ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator.adaptive(),
                                        )
                                      : const Text('Order Lagi'),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (data.order.poFilePath.split('.').last == 'pdf') {
                                        final result = await Storages.instance.getImageUrl(data.order.poFilePath);
                                        // if (await canLaunchUrl(Uri.parse(result))) {
                                        //   await launchUrl(Uri.parse(result), mode: LaunchMode.externalApplication);
                                        // }
                                        if (context.mounted) {
                                          Navigator.pushNamed(context, Routes.pdf, arguments: ArgPdf('PO ${data.order.id}', result));
                                        }
                                        return;
                                      } else {
                                        final imageName = data.order.poFilePath;
                                        Navigator.pushNamed(
                                          context,
                                          Routes.photo,
                                          arguments: ArgPhotoView(imageName, true),
                                        );
                                        return;
                                      }
                                      // (result);
                                      // // if (context.mounted) {
                                      // //   Navigator.pushNamed(context, Routes.webview, arguments: {'title': 'PO', 'url': result});
                                      // // }
                                      // if (await canLaunchUrl(Uri.parse(result))) {
                                      //   await launchUrl(Uri.parse(result), mode: LaunchMode.externalApplication);
                                      // }
                                    },
                                    child: const Text('Lihat PO'))
                              ],
                            ),
                          // ElevatedButton(
                          //   onPressed: loading
                          //       ? null
                          //       : () => orderAgain(data.order)
                          //           .then((value) => Navigator.pop(context))
                          //           .then((value) => Navigator.pushReplacementNamed(context, Routes.cart)),
                          //   child: loading
                          //       ? const SizedBox(
                          //           height: 15,
                          //           width: 15,
                          //           child: CircularProgressIndicator.adaptive(),
                          //         )
                          //       : const Text('Order Lagi'),
                          // ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: TabBar(
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        onTap: (value) => ref.invalidate(orderProvider(arg)),
                        tabs: const [Tab(text: 'Invoice'), Tab(text: 'Pengantaran')],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      data.order.status == 3
                          ? Container()
                          : (invoice.paymentMethod == PaymentMethod.trf && data.invoices.isEmpty)
                              ? Center(
                                  child: ElevatedButton(
                                    onPressed: () => ref.read(apiProvider).invoice.create(data.order.id).then((value) {
                                      Navigator.pushNamed(context, Routes.webView, arguments: {'title': 'Transaksi', 'url': value.url});
                                      return;
                                    }).catchError((e) {
                                      Alerts.dialog(context, content: '$e');
                                      return;
                                    }),
                                    child: const Text('Bayar Sekarang'),
                                  ),
                                )
                              : ListView.separated(
                                  itemBuilder: (context, index) {
                                    return WidgetOrderInvoice(
                                      invoice: const Invoice(),
                                      paymentMethod: 0,
                                      totalPaidOff: 0,
                                      totalPrice: data.order.totalPrice.toInt(),
                                      isList: false,
                                      widgetTimer: Consumer(
                                        builder: (context, ref, child) {
                                          final timer = ref.watch(
                                            timerStateNotifierProvider(TimerArgs(data.invoice.paymentMethod == 1
                                                ? data.invoice.paidAt!.add(const Duration(days: 1))
                                                : data.invoice.term!)),
                                          );
                                          return Text(
                                            timer,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          );
                                        },
                                      ),
                                      bayarSekarang: () async {
                                        try {
                                          final dataInv = data.invoice;

                                          if (dataInv.status == 2) {
                                            ref.read(loadingAgainProvider.notifier).update((state) => true);
                                            final result = await ref.read(apiProvider).invoice.create(dataInv.id);
                                            final inv = await ref.read(apiProvider).invoice.byId(result.id);

                                            if (context.mounted) {
                                              await Navigator.pushNamed(context, Routes.webView, arguments: {'title': 'Transaksi', 'url': inv.url});
                                            }

                                            ref.invalidate(orderProvider(arg));
                                            ref.read(loadingAgainProvider.notifier).update((state) => false);
                                            return;
                                          }
                                          await showModalBottomSheet(
                                            context: context,
                                            builder: (context) => Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Consumer(builder: (context, ref, child) {
                                                final textEditingController = useTextEditingController();
                                                final loading = ref.watch(loadingStateProvider);
                                                return Column(
                                                  children: [
                                                    TextField(
                                                      controller: textEditingController,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                        CurrencyInputFormatter(),
                                                      ],
                                                      decoration: const InputDecoration(
                                                        labelText: 'Masukkan nominal bayar',
                                                      ),
                                                      focusNode: node,
                                                      keyboardType: TextInputType.number,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    ElevatedButton(
                                                      onPressed: loading
                                                          ? null
                                                          : () async {
                                                              try {
                                                                ref.read(loadingStateProvider.notifier).update((state) => true);
                                                                if (textEditingController.text.isEmpty || textEditingController.text == '0') {
                                                                  return;
                                                                }
                                                                final input = int.parse(textEditingController.text.split('.').join());
                                                                final paid = data.invoice.paid;

                                                                if (input > paid) {
                                                                  throw 'Nominal bayar tidak boleh melebihi sisa tagihan';
                                                                }
                                                                final result = paid - input;
                                                                if (input < 50000) {
                                                                  throw 'Nominal bayar tidak boleh kurang dari Rp50.000';
                                                                }
                                                                if (result > 1 && result < 50000) {
                                                                  throw 'Sisa tagihan tidak boleh kurang dari Rp50.000';
                                                                }
                                                                final req = data.order.id;
                                                                final res = await ref.read(apiProvider).invoice.create(req);
                                                                final inv = await ref.read(apiProvider).invoice.byId(res.id);
                                                                if (context.mounted) {
                                                                  await Navigator.popAndPushNamed(
                                                                    context,
                                                                    Routes.webView,
                                                                    arguments: {'title': 'Transaksi', 'url': inv.url},
                                                                  );
                                                                  ref.invalidate(orderProvider(arg));
                                                                }
                                                                return;
                                                              } catch (e) {
                                                                Alerts.dialog(context, content: e.toString());
                                                                return;
                                                              } finally {
                                                                ref.read(loadingStateProvider.notifier).update((state) => false);
                                                              }
                                                            },
                                                      child: loading
                                                          ? const FittedBox(child: CircularProgressIndicator.adaptive())
                                                          : const Text('Bayar Sekarang'),
                                                    )
                                                  ],
                                                );
                                              }),
                                            ),
                                          );
                                          return;
                                        } catch (e) {
                                          Alerts.dialog(context, content: e.toString());
                                          return;
                                        }
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                  itemCount: 0,
                                ),
                      data.order.status == 3
                          ? Container()
                          : ListView.separated(
                              itemBuilder: (context, index) => WidgetOrderDelivery(
                                orderProducts: data.order.product,
                                delivery: data.deliveries[index],
                                index: index,
                                detailImageRoute: '',
                                tracking: '',
                                gojekTracking: Routes.webView,
                              ),
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemCount: data.deliveries.length,
                            )
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
      ),
    );
  }
}
