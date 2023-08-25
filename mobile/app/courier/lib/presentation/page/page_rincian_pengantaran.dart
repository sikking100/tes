import 'package:api/api.dart' hide logger;
import 'package:api/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:common/common.dart';
import 'package:courier/common/constant.dart' hide mPrimaryColor, PaymentMethod;
import 'package:courier/common/widget.dart';

import 'package:courier/function/function.dart';
import 'package:courier/main.dart';
import 'package:courier/main_controller.dart';
import 'package:courier/presentation/page/home/view_dimuat.dart';
import 'package:courier/presentation/page/home/view_selesai.dart';
import 'package:courier/presentation/page/home/view_proses.dart';
import 'package:courier/presentation/page/page_home.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final antarStateProvider =
    StateNotifierProvider.autoDispose.family<AntarState, AsyncValue<OrderDetail>, String>((ref, args) => AntarState(false, ref, args));

class AntarState extends StateNotifier<AsyncValue<OrderDetail>> {
  AntarState(bool state, this.ref, this.idDelivery) : super(const AsyncValue.loading()) {
    textEditingController = TextEditingController();
    init(idDelivery);
  }

  final String idDelivery;

  String? note;

  void changeNote(String value) => note = value;

  void init(String id) async {
    if (mounted) {
      state = await AsyncValue.guard(() async {
        final deliveries = await ref.read(apiProvider).delivery.byId(id);
        final order = await ref.read(apiProvider).order.byId(deliveries.orderId);
        final invoices = await ref.read(apiProvider).invoice.byOrder(deliveries.orderId);
        return OrderDetail(order, [deliveries], invoices);
      });
    }
  }

  final AutoDisposeRef ref;
  late final TextEditingController textEditingController;

  Future<void> mengantar({
    required String deliveryId,
    required double desLat,
    required double desLng,
  }) async {
    try {
      ref.read(loadingStateProvider.notifier).update((state) => true);
      await ref.read(apiProvider).delivery.deliver(deliveryId);
      final currenPosition = await ref.read(locationStreamProvider.future);
      await FirebaseFirestore.instance.collection('tracking').doc(deliveryId).set(
        {
          "deliveryId": deliveryId,
          "expiredAt": DateTime.now().add(const Duration(days: 2)).toUtc().millisecondsSinceEpoch,
          "overviewPolyline": "",
          "courier": {
            "lat": currenPosition.latitude ?? 0.1,
            "lng": currenPosition.longitude ?? 0.1,
            "heading": currenPosition.heading ?? 0.1,
          },
          "customer": {
            "lat": desLat,
            "lng": desLng,
          }
        },
      );
      ref.read(loadingStateProvider.notifier).update((state) => false);
      return;
    } catch (e) {
      logger.info(e);
      ref.read(loadingStateProvider.notifier).update((state) => false);

      rethrow;
    }
  }

  Future selesai({required List<DeliveryProduct> products, bool? isSelesai = false, bool? isRestock, required String defaultNote}) async {
    try {
      ref.read(loadingStateProvider.notifier).update((state) => true);

      final courier = ref.read(userStateProvider);

      List<DeliveryProduct> list = [];

      if (isSelesai == true) {
        for (var i = 0; i < products.length; i++) {
          list.add(products[i].copyWith(status: 9, reciveQty: products[i].deliveryQty));
        }
      }

      if (isRestock == true) {
        for (var i = 0; i < products.length; i++) {
          list.add(products[i].copyWith(status: products[i].brokenQty > 0 ? 8 : 9));
        }
      }

      final req =
          Complete(courierId: courier.id, product: list, status: isRestock == true ? 8 : 9, note: note ?? (defaultNote.isEmpty ? '-' : defaultNote));

      await ref.read(apiProvider).delivery.complete(id: idDelivery, req: req);
      ref.read(loadingStateProvider.notifier).update((state) => false);

      return;
    } catch (e) {
      ref.read(loadingStateProvider.notifier).update((state) => false);

      rethrow;
    }
  }

  @override
  void dispose() {
    // textEditingController.dispose();
    super.dispose();
  }
}

class PageRincianPengantaran extends ConsumerWidget {
  final Delivery delivery;

  const PageRincianPengantaran({
    Key? key,
    required this.delivery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final antarState = ref.watch(antarStateProvider(delivery.id));

    final loading = ref.watch(loadingStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Pengantaran'),
      ),
      body: antarState.when(
        data: (data) {
          final order = data.order;
          final invoice = data.invoice;
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: mPadding.copyWith(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(order.customer.imageUrl),
                        radius: 27,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customer.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              paymentMethodString(invoice.paymentMethod),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: mPrimaryColor),
                            ),
                            if (invoice.paymentMethod == PaymentMethod.cod) Text('Nominal pembayaran : ${invoice.price}')
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          launchs(order.customer.phone, true);
                        },
                        child: const Icon(Icons.phone),
                      )
                    ],
                  ),
                ),
                delivery.status == 9
                    ? Container()
                    : delivery.status == 6
                        ? ElevatedButton(
                            onPressed: loading
                                ? null
                                : () => ref
                                        .read(antarStateProvider(delivery.id).notifier)
                                        .mengantar(
                                          deliveryId: delivery.id,
                                          desLat: order.customer.lat,
                                          desLng: order.customer.lng,
                                        )
                                        .then((value) => ref.refresh(antarStateProvider(delivery.id)))
                                        .then((value) => ref.read(dimuatStateNotifier).refresh())
                                        .then((value) => Navigator.pop(context, {'isAntar': true}))
                                        .catchError(
                                      (e) {
                                        Alerts.dialog(context, content: e.toString());
                                        return e;
                                      },
                                    ),
                            child: loading ? const BtnLoading() : const Text('Antar'),
                          )
                        : ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              if (delivery.status == 7)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Routes.pengantaran, arguments: {'delivery': delivery});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(110, 36),
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Rute'),
                                ),
                              if (delivery.status == 7)
                                ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            onTap: () => ref
                                                .read(antarStateProvider(delivery.id).notifier)
                                                .selesai(
                                                  defaultNote: order.customer.note,
                                                  products: delivery.product,
                                                  isSelesai: true,
                                                )
                                                .then((value) => Navigator.pop(context))
                                                .then((value) => ref.read(prosesStateNotifier).refresh())
                                                .then((value) => Navigator.pop(context))
                                                .catchError((e) {
                                              myAlert(context, errorText: e.toString());
                                            }),
                                            title: const Text('Pengantaran Selesai'),
                                          ),
                                          ListTile(
                                            onTap: () => Navigator.popAndPushNamed(
                                              context,
                                              Routes.selisihBarang,
                                              arguments: {
                                                'id': delivery.id,
                                                'status': delivery.status,
                                                'products': delivery.product,
                                                'order': order,
                                                'defaultNote': delivery.note,
                                              },
                                            ),
                                            title: const Text('Input Selisih'),
                                          ),
                                          ListTile(
                                            onTap: () async {
                                              try {
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Peringatan'),
                                                    content: Column(
                                                      children: [
                                                        const Text('Anda yakin ingin membatalkan pengantaran?'),
                                                        const SizedBox(height: 10),
                                                        TextField(
                                                          onChanged: ref.read(antarStateProvider(delivery.id).notifier).changeNote,
                                                          minLines: 3,
                                                          maxLines: 10,
                                                          decoration: const InputDecoration(hintText: 'Masukkan alasan pembatalan'),
                                                        )
                                                      ],
                                                    ),
                                                    actions: [
                                                      OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          fixedSize: const Size.fromWidth(100),
                                                          side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          'Tidak',
                                                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(fixedSize: const Size.fromWidth(100)),
                                                        onPressed: () {
                                                          ref
                                                              .read(antarStateProvider(delivery.id).notifier)
                                                              .selesai(
                                                                defaultNote: order.customer.note,
                                                                products: [
                                                                  for (var p in delivery.product) p.copyWith(status: 8, brokenQty: p.deliveryQty)
                                                                ],
                                                                isRestock: true,
                                                              )
                                                              .then((value) => Navigator.pop(context))
                                                              .then((value) => Navigator.pop(context))
                                                              .then((value) => ref.invalidate(restokeProvider))
                                                              .then((value) => ref.read(prosesStateNotifier).refresh())
                                                              .then((value) => Navigator.pop(context))
                                                              .catchError((error, stackTrace) {
                                                            myAlert(context, errorText: error.toString());
                                                            return Future.value();
                                                          });
                                                        },
                                                        child: const Text('Ya'),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                return;
                                              } catch (e) {
                                                myAlert(context, errorText: e.toString());
                                                return;
                                              }
                                            },
                                            title: const Text('Pengantaran Batal'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(110, 36),
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Aksi'),
                                ),
                            ],
                          ),
                const Divider(),
                Flexible(
                  flex: 3,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: mPadding,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID Pengantaran',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 5),
                              TextCopy(text: delivery.id),
                              const SizedBox(height: 20),
                              Text(
                                'ID Pesanan',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 5),
                              TextCopy(text: order.id),
                              const SizedBox(height: 20),
                              Text(
                                'Jadwal Pengantaran',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 5),
                              Text(delivery.deliveryAt.parseFull),
                              const SizedBox(height: 20),
                              Text(
                                'Alamat Pengantaran',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 5),
                              Text(delivery.customer.addressName),
                              const SizedBox(height: 20),
                              Text(
                                'Catatan',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 5),
                              Text(order.customer.note),
                              const SizedBox(height: 20),
                              Text(
                                'Daftar Pesanan',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, index) {
                              final product = delivery.product.where((element) => element.deliveryQty > 0).toList()[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text('0${index + 1}'),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, Routes.photoview, arguments: {'img': product.imageUrl}),
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        child: Container(
                                          height: 58,
                                          width: 58,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Image.network(product.imageUrl),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.category),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${product.name}, ${product.size}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text('${product.deliveryQty} pcs'),
                                          if (delivery.status == 6 && (product.brokenQty) > 0)
                                            Text(
                                              'Selish, ${product.brokenQty} pcs',
                                              style: const TextStyle(color: Colors.red),
                                            )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            childCount: delivery.product.where((element) => element.deliveryQty > 0).length,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
