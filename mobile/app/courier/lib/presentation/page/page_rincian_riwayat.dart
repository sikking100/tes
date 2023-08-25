import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:courier/common/widget.dart';
import 'package:courier/main.dart';
import 'package:courier/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderFutureProvider = FutureProvider.autoDispose.family<OrderDetail, String>((ref, args) async {
  final deliveries = await ref.read(apiProvider).delivery.byId(args);
  final order = await ref.read(apiProvider).order.byId(deliveries.orderId);
  final invoices = await ref.read(apiProvider).invoice.byOrder(deliveries.orderId);
  return OrderDetail(order, [deliveries], invoices);
});

class PageRincianRiwayat extends ConsumerWidget {
  final String id;
  const PageRincianRiwayat({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderDetail = ref.watch(orderFutureProvider(id));
    bool isBatal(List<DeliveryProduct> products) {
      return products.map((e) => e.brokenQty).reduce((value, element) => value + element) ==
          products.map((e) => e.deliveryQty).reduce((value, element) => value + element);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengantaran'),
      ),
      body: orderDetail.when(
        data: (data) {
          final order = data.order;
          final delivery = data.deliveries.first;
          final invoice = data.invoice;
          return ListView(
            padding: const EdgeInsets.all(Dimens.px16),
            children: [
              Row(
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
                        if (invoice.paymentMethod == PaymentMethod.cod)
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              Text(order.totalPrice.toInt().currency()),
                            ],
                          )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'ID Pesanan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              TextCopy(text: id),
              const SizedBox(height: 20),
              Text(
                'Jadwal Pengantaran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              Text(delivery.deliveryAt.fullDate),
              const SizedBox(height: 20),
              Text(
                'Alamat Pengantaran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              Text(order.customer.name),
              const SizedBox(height: 20),
              Text(
                'Catatan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              Text(order.customer.note),
              const SizedBox(height: 10),
              for (var d in data.deliveries)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  textColor: Colors.red,
                  backgroundColor: Colors.grey.shade100,
                  title: Text(d.id),
                  subtitle: Text(StatusString.delivery(d.status, isBatal(d.product))),
                  children: [
                    for (var product in d.product.where((element) => element.deliveryQty > 0))
                      Padding(
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
                                  if (delivery.status == 6 && product.brokenQty > 0)
                                    Text(
                                      'Selish, ${product.brokenQty} pcs',
                                      style: const TextStyle(color: Colors.red),
                                    )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                )
            ],
          );
        },
        error: (error, stackTrace) => WidgetError(
          error: error.toString(),
          onPressed: () => ref.read(orderFutureProvider(id)),
        ),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
