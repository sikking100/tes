import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/view/text_copy.dart';
import 'package:flutter/material.dart';
import 'package:api/api.dart';

class WidgetOrder extends StatelessWidget {
  final String id;
  final DateTime deliveryTime;
  // final int paymentMethod;

  ///customer or business name
  final String customerName;
  final int orderStatus;

  // final DateTime invExpiredAt;

  final int productPrice;
  final int deliveryFee;

  final void Function()? onOrderAgain;
  final bool? orderAgainLoad;

  final String routeOrderDetail;
  // final int invoiceStatus;
  final String cancelNote;

  final int totalProduk;

  final int totalPesanan;

  const WidgetOrder({
    super.key,
    required this.id,
    required this.deliveryTime,
    // required this.paymentMethod,
    required this.customerName,
    required this.orderStatus,
    // required this.invExpiredAt,
    required this.productPrice,
    required this.deliveryFee,
    this.onOrderAgain,
    this.orderAgainLoad,
    required this.routeOrderDetail,
    // required this.invoiceStatus,
    required this.cancelNote,
    required this.totalProduk,
    required this.totalPesanan,
  });

  ///widget yang dipakai di list order history dan pending
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCopy(text: id),
        customerName.isEmpty
            ? Container()
            : Text(
                customerName,
                style: const TextStyle(color: mOrderHistoryTitleColor, height: 1.5),
              ),
        Text(
          deliveryTime.fullDate,
          style: const TextStyle(color: mOrderHistoryTitleColor, height: 1.5),
        ),

        // const SizedBox(height: 2),
        // Text(
        //   paymentMethodString(paymentMethod),
        //   style: const TextStyle(color: mOrderHistoryTitleColor),
        // ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$totalProduk produk',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Total Pesanan:${totalPesanan.currency()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (orderStatus == 6)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesanan Dibatalkan',
                style: TextStyle(color: Colors.red),
              ),
              const Text(
                'Catatan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(cancelNote),
            ],
          ),
        // if (paymentMethod == PaymentMethod.top)
        //   if (orderStatus == 1)
        //     const Text(
        //       'Menunggu Persetujuan',
        //       style: TextStyle(color: Colors.red),
        //     )
        //   else if (DateTime.now().isAfter(invExpiredAt))
        //     const Text(
        //       'Tanggal jatuh tempo lewat',
        //       style: TextStyle(color: Colors.red),
        //     )
        //   else
        //     Text(
        //       'Jatuh tempo : ${invExpiredAt.subtract(const Duration(days: 1)).date}',
        //       style: const TextStyle(color: mOrderHistoryTitleColor),
        //     )
        // else if (paymentMethod == PaymentMethod.trf && (invoiceStatus >= 1 && invoiceStatus <= 0))
        //   const Text('Menunggu Pembayaran', style: TextStyle(color: Colors.red)),
        // const SizedBox(height: 5),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       paymentMethod != PaymentMethod.trf ? 'Total Tagihan' : 'Total Pembayaran',
        //       style: const TextStyle(fontWeight: FontWeight.bold),
        //     ),
        //     Text(
        //       (productPrice).currency(),
        //       style: const TextStyle(fontWeight: FontWeight.bold),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 10),
        onOrderAgain == null
            ? Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: () => Navigator.pushNamed(context, routeOrderDetail, arguments: id),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text('Detail Pesanan'),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: orderAgainLoad == true ? null : onOrderAgain,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: orderAgainLoad == true
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : const Text('Order Lagi'),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () => Navigator.pushNamed(context, routeOrderDetail, arguments: id),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Text('Detail Pesanan'),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class WidgetOrderDetailTop extends StatelessWidget {
  final String id;
  final DateTime deliveryTime;
  final int paymentMethod;
  final String status;
  final DateTime invExpiredAt;

  const WidgetOrderDetailTop({
    super.key,
    required this.id,
    required this.deliveryTime,
    required this.paymentMethod,
    required this.status,
    required this.invExpiredAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCopy(text: id),
        Text(
          deliveryTime.fullDate,
          style: const TextStyle(color: mOrderHistoryTitleColor),
        ),
        Text(
          paymentMethodString(paymentMethod),
          style: const TextStyle(color: mOrderHistoryTitleColor),
        ),
        if (status == 'CANCEL')
          const Text(
            'Pesanan Dibatalkan',
            style: TextStyle(color: Colors.red),
          ),
        if (status != 'CANCEL' && paymentMethod == 'TOP')
          if (DateTime.now().isAfter(DateTime(invExpiredAt.year, invExpiredAt.month, invExpiredAt.day)))
            const Text(
              'Tanggal jatuh tempo lewat',
              style: TextStyle(color: Colors.red),
            )
          else
            Text(
              'Jatuh tempo : ${invExpiredAt.subtract(const Duration(days: 1)).date}',
              style: const TextStyle(color: mOrderHistoryTitleColor),
            )
        else
          Container(),
        const SizedBox(height: 10),
      ],
    );
  }
}

class WidgetOrderDetailListProduct extends StatelessWidget {
  final List<OrderProduct> productItems;
  const WidgetOrderDetailListProduct({super.key, required this.productItems});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFF000000)),
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
                padding: EdgeInsets.all(10),
                child: Text(
                  'Jml',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Sub (Rp)',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          for (var v in productItems)
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFF000000)),
                ),
              ),
              children: [
                Container(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('${v.name}, ${v.size}')),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(v.qty.toString()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text((v.qty * v.unitPrice).toInt().currencyWithoutRp(), textAlign: TextAlign.right),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class WidgetOrderDetailBottom extends StatelessWidget {
  final int productPrice;
  final int deliveryFee;
  final String paymentMethod;
  final String status;
  final void Function()? orderAgain;

  const WidgetOrderDetailBottom({
    super.key,
    required this.productPrice,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.status,
    this.orderAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (deliveryFee > 0)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Belanja'),
                  Text(productPrice.currency()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ongkos Kirim'),
                  Text(deliveryFee.currency()),
                ],
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (paymentMethod == 'TRA' || status == 'Status.complete') ? 'Total Bayar' : 'Total Tagihan',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              (productPrice + deliveryFee).currency(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        orderAgain == null
            ? Container()
            : ElevatedButton(
                onPressed: orderAgain,
                child: const Text('Order Lagi'),
              ),
      ],
    );
  }
}

class WidgetOrderInvoice extends StatelessWidget {
  final Invoice invoice;
  final int paymentMethod;
  final int totalPaidOff;

  ///the sum of total invoice
  final int totalPrice;

  ///isi dengan nilai invoice.length > 1
  final bool isList;

  ///count down widget for transfer transaction time out
  final Widget widgetTimer;

  final void Function() bayarSekarang;

  final bool isUrl;

  final bool isLoading;
  const WidgetOrderInvoice({
    super.key,
    required this.invoice,
    required this.paymentMethod,
    required this.totalPaidOff,
    required this.totalPrice,
    required this.isList,
    required this.widgetTimer,
    required this.bayarSekarang,
    this.isUrl = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(StatusString.invoice(invoice.status, paymentMethod), style: const TextStyle(fontWeight: FontWeight.bold)),
            if (invoice.status == 3) TextCopy(text: invoice.id.toString(), isColor: false),
            if (invoice.status != 3) Text(invoice.paidAt?.fullDate ?? ''),
            if (invoice.status == 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jumlah Pembayaran'),
                  Text((invoice.price).toInt().currency()),
                ],
              ),
            if (isList && invoice.status != 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Terbayar'),
                  Text(totalPaidOff.currency()),
                ],
              ),
            if (isList && invoice.status != 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sisa'),
                  Text((totalPrice - totalPaidOff).currency()),
                ],
              ),
            if ((!isList && invoice.status == 1) || invoice.status == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(invoice.status == 0 ? 'Jumlah Tagihan' : 'Jumlah Pembayaran'),
                  Text((invoice.price).toInt().currency()),
                ],
              ),
            if (invoice.status == 2 && isUrl)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (invoice.status == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text('Batas Waktu Pembayaran'),
                        widgetTimer,
                      ],
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: bayarSekarang,
                    child: isLoading ? const BtnLoading() : const Text('Bayar Sekarang'),
                  ),
                ],
              ),
            if ((invoice.status > 0 && invoice.status < 3) && !isUrl && paymentMethod != 0)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: bayarSekarang,
                child: isLoading ? const BtnLoading() : const Text('Bayar Sekarang'),
              ),
          ],
        ),
      ),
    );
  }
}

class WidgetOrderDelivery extends StatelessWidget {
  final List<OrderProduct> orderProducts;
  final Delivery delivery;
  final String? detailImageRoute;
  final String? tracking;
  final String? gojekTracking;
  final int index;
  const WidgetOrderDelivery(
      {super.key,
      required this.orderProducts,
      required this.delivery,
      this.detailImageRoute,
      this.tracking,
      required this.index,
      this.gojekTracking});

  @override
  Widget build(BuildContext context) {
    final isBatal = delivery.product.map((e) => e.brokenQty).reduce((value, element) => value + element) ==
        delivery.product.map((e) => e.deliveryQty).reduce((value, element) => value + element);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final widget = Container(
              height: MediaQuery.of(context).size.height * 89 / 100,
              padding: const EdgeInsets.all(Dimens.px16),
              child: Column(
                children: [
                  const Text('Daftar Pengantaran'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(delivery.product.length, (i) {
                          final products = delivery.product;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('0${i + 1}'),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, detailImageRoute ?? '', arguments: products[i].imageUrl),
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
                                    child: Image.network(products[i].imageUrl),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      products[i].category,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${products[i].name.firstLetter}, ${products[i].size}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    if (delivery.status >= 8 && delivery.status <= 9)
                                      Column(
                                        children: [
                                          Text('Diterima ${products[i].reciveQty} pcs'),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    if (delivery.status == 6 || delivery.status == 7)
                                      Text('${delivery.status == 6 ? 'Dimuat' : 'Diantar'} ${products[i].deliveryQty} pcs'),
                                    if (delivery.status == 8) Text('Dikembalikan ${products[i].brokenQty} pcs'),
                                    if (delivery.status >= 1 && delivery.status <= 5)
                                      Text(
                                        'Pending ${products[i].purcaseQty} pcs',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  )
                ],
              ),
            );
            if (delivery.status != 7) {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return widget;
                },
              );
              return;
            }
            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Lihat Produk'),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return widget;
                          },
                        );
                      },
                    ),
                    tracking == null || (delivery.courierType == 1 && delivery.url.isEmpty)
                        ? Container()
                        : ListTile(
                            title: const Text('Lihat Rute'),
                            onTap: () {
                              logger.info(delivery.url.isNotEmpty);
                              delivery.url.isNotEmpty
                                  ? Navigator.pushNamed(context, gojekTracking ?? '', arguments: {'title': 'Rute Pengantaran', 'url': delivery.url})
                                  : Navigator.pushNamed(
                                      context,
                                      tracking.toString(),
                                      arguments: delivery,
                                    );
                              return;
                            },
                          )
                  ],
                ),
              ),
            );
            return;
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(StatusString.delivery(delivery.status, isBatal), style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextCopy(text: delivery.id, isColor: false),
                    Text(delivery.deliveryAt.fullDate),
                  ],
                ),
              ),
              const Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}
