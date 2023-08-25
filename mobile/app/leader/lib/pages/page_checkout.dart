import 'dart:io';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/common.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/argument.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leader/pages/page_order.dart';
import 'package:leader/pages/page_orders.dart';
import 'package:leader/routes.dart';
import 'package:leader/storage.dart';
import 'package:leader/widget.dart';
import 'package:file_picker/file_picker.dart';

final radioStateProvider = StateProvider.autoDispose<int>((ref) {
  return 3;
});

final dateStateProvider = StateProvider.autoDispose<DateTime?>((ref) {
  return null;
});

final checkoutStateProvider = StateNotifierProvider.autoDispose<CheckoutState, bool>((ref) => CheckoutState(false, ref));

final pickedLocation = StateProvider.autoDispose<BusinessAddress?>((ref) {
  final b = ref.watch(customerStateProvider);
  return b.business?.address.first;
});
final mapController = Provider.autoDispose.family<GoogleMapController, GoogleMapController>((_, arg) => arg);

final fileStateProvider = StateProvider.autoDispose<File?>((ref) {
  return;
});

class CheckoutState extends StateNotifier<bool> {
  CheckoutState(super.state, this.ref) {
    note = TextEditingController();
    cart = ref.watch(cartStateNotifier);
    customer = ref.watch(customerStateProvider);
    employee = ref.watch(employeeStateProvider);
  }
  final AutoDisposeRef ref;
  late final TextEditingController note;
  late final List<Product> cart;
  late final Customer customer;
  late final Employee employee;
  String error = '';

  Future<void> checkout(BuildContext context) async {
    ref.read(loadingStateProvider.notifier).update((state) => true);
    final cartNot = ref.read(cartStateNotifier.notifier);
    try {
      final date = ref.watch(dateStateProvider);
      if (date == null) throw 'Anda belum memilih tanggal pengantaran';
      final paymentMethod = ref.watch(radioStateProvider);
      if (paymentMethod > 2) throw 'Anda belum memilih metode pembayaran';

      final totalPrice = cartNot.totalProduct();

      if (totalPrice < 50000) throw 'Belanjaan Anda masih kurang dari ${50000.currency()}.  Belanja lagi yuk!';

      final business = customer.business;

      if (business == null) throw 'Tidak ada bisnis yang dipilih';

      List<UserApprover> approver = [];

      if (paymentMethod != 2) {
        approver.addAll(
          await ref.read(apiProvider).employee.approver(
                regionId: customer.business?.location.regionId ?? employee.location?.id ?? '-',
                branchId: customer.business?.location.branchId ?? employee.location?.id ?? '-',
                team: employee.team,
              ),
        );
      }

      final cus = await ref.read(apiProvider).customer.byId(customer.id);

      final lastMonth = await ref.read(apiProvider).order.lastMonth(customer.id);
      final perMonth = await ref.read(apiProvider).order.perMonth(customer.id);

      final image = ref.watch(fileStateProvider);
      String refs = '-';
      if (image != null) {
        refs = Storages.instance.path(ref: 'private/order/${customer.id}/', file: image);
        Storages.instance.uploadPhoto(ref: refs, file: image);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File PO sedang diupload')));
        await for (var i in Storages.instance.taskEvents) {
          if (i.state == Storages.instance.success) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File PO sukses diupload')));
            break;
          }
          if (i.state == Storages.instance.error) {
            throw 'Gagal diupload';
          }
        }
      }

      final create = CreateOrder(
        orderCreator: OrderCreator(
          id: employee.id,
          email: employee.email,
          imageUrl: employee.imageUrl,
          name: employee.name,
          phone: employee.phone,
          roles: employee.roles,
        ),
        branchId: cus.business?.location.branchId ?? '-',
        branchName: cus.business?.location.branchName ?? '-',
        customer: OrderCustomer(
          id: cus.id,
          name: cus.name,
          note: note.text.isEmpty ? '-' : note.text,
          email: cus.email,
          phone: cus.phone,
          imageUrl: cus.imageUrl,
          picName: cus.business?.pic.name ?? cus.name,
          picPhone: cus.business?.pic.phone ?? cus.phone,
          addressName: cus.business?.address.first.name ?? '',
          addressLngLat: cus.business?.address.first.lngLat ?? [0.0, 0.0],
        ),
        deliveryAt: date,
        deliveryType: 0,
        deliveryPrice: 0,
        paymentMethod: paymentMethod,
        priceId: cus.business?.priceList.id ?? cart.first.price.first.id,
        priceName: cus.business?.priceList.name ?? cart.first.price.first.name,
        regionId: cus.business?.location.regionId ?? '-',
        regionName: cus.business?.location.regionName ?? '-',
        code: '-',
        poFilePath: refs,
        creditLimit: cus.business?.credit.limit ?? 0,
        creditUsed: cus.business?.credit.used ?? 0,
        transactionLastMonth: lastMonth,
        transactionPerMonth: perMonth,
        productPrice: cartNot.totalProduct(),
        totalPrice: cartNot.totalProduct(),
        termInvoice: paymentMethod == PaymentMethod.trf ? 1 : cus.business?.credit.termInvoice ?? 1,
        userApprover: approver,
        product:
            // product,
            List<OrderProduct>.from(
          cart.toSet().map(
                (e) => OrderProduct(
                  brandId: e.brand.id,
                  brandName: e.brand.name,
                  categoryId: e.category.id,
                  categoryName: e.category.name,
                  description: e.description,
                  discount: cartNot.discount(e.productId).discount + cartNot.additional((ref.read(doubleProvider)[e.productId] ?? 0), e.productId),
                  id: e.productId,
                  imageUrl: e.imageUrl,
                  name: e.name,
                  point: e.point,
                  unitPrice: e.kPrice(cus.business?.priceList.id).price,
                  salesId: e.salesId,
                  salesName: e.salesName,
                  qty: cart.where((element) => element.productId == e.productId).length,
                  size: e.size,
                  tax: 0,
                  totalPrice: ((e.kPrice(cus.business?.priceList.id).price -
                          ref.read(cartStateNotifier.notifier).discount(e.productId).discount -
                          cartNot.additional((ref.read(doubleProvider)[e.productId] ?? 0), e.productId)) *
                      cart.where((element) => element.productId == e.productId).length),
                ),
              ),
        ),
      );
      (create.toJson());
      final result = await ref.read(apiProvider).order.create(create);
      if (paymentMethod == PaymentMethod.trf) {
        final invoice = await ref.read(apiProvider).invoice.create(result.invoiceId);
        final inv = await ref.read(apiProvider).invoice.byId(invoice.id);
        if (context.mounted) {
          await Navigator.pushNamed(context, Routes.webView, arguments: {'title': 'Transaksi', 'url': inv.url}).whenComplete(() {
            ref.invalidate(orderProvider(result.id));
          });
        }
      }
      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ref.invalidate(customerStateProvider);
      }
      ref.invalidate(cartStateNotifier);
      ref.invalidate(doubleProvider);
      return;
    } catch (e) {
      Alerts.dialog(context, content: '$e');
      return;
    } finally {
      ref.read(loadingStateProvider.notifier).update((state) => false);
      ref.invalidate(orderPendingProvider);
    }
  }
}

const String pageCheckout = '/checkout';

class PageCheckout extends ConsumerWidget {
  const PageCheckout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(radioStateProvider);
    final date = ref.watch(dateStateProvider);
    final cartNotifier = ref.watch(cartStateNotifier.notifier);
    final loading = ref.watch(checkoutStateProvider);
    final error = ref.watch(checkoutStateProvider.notifier).error;
    final pickedLoc = ref.watch(pickedLocation);
    final customer = ref.watch(customerStateProvider);
    final loadingButton = ref.watch(loadingStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: error.isNotEmpty
          ? Center(
              child: Text(error.toString()),
            )
          : loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(Dimens.px16),
                        children: [
                          const WidgetCheckoutTextTitle(title: 'Alamat Pengantaran Anda'),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.pushNamed(context, Routes.businessListAddress,
                                  arguments: ArgBusinessListAddress(customer.business?.address ?? [], isCheckout: true)) as BusinessAddress?;

                              if (result == null) return;
                              ref.read(pickedLocation.notifier).update((state) => result);
                            },
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${customer.name}\n',
                                  ),
                                  TextSpan(text: pickedLoc?.name)
                                ],
                              ),
                            ),
                          ),
                          if (customer.business == null)
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 15),
                                  const WidgetCheckoutTextTitle(title: 'Ubah Alamat Pengantaran'),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 150,
                                    child: MapWidget(ref: ref),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          const WidgetCheckoutTextTitle(title: 'Jadwal Pengantaran'),
                          const SizedBox(height: 10),
                          WidgetCheckoutJadwalPengantaran(
                            onTanggalTap: () async {
                              ref.watch(dateStateProvider.notifier).state = await showDatePicker(
                                context: context,
                                initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                                firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                                lastDate: DateTime(
                                    DateTime.now().year + (DateTime.now().month == 12 && DateTime.now().day == 30 ? 1 : 0), DateTime.now().month + 1),
                                keyboardType: TextInputType.datetime,
                                builder: (_, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                        colorScheme: Theme.of(context).brightness == Brightness.dark
                                            ? schemeDark
                                            : scheme.copyWith(primary: scheme.secondary, onPrimary: scheme.onSecondary)),
                                    child: child ?? Container(),
                                  );
                                },
                              );
                            },
                            tanggal: date,
                          ),
                          const SizedBox(height: 15),
                          const WidgetCheckoutTextTitle(title: 'Unggah PO'),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              try {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                                  allowMultiple: false,
                                );
                                if (result != null) {
                                  ref.read(fileStateProvider.notifier).update((state) => File(result.paths.first ?? ''));
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File PO sudah dipilih')));
                                }
                                return;
                              } catch (e) {
                                Alerts.dialog(context, content: '$e');
                                return;
                              }
                            },
                            child: Consumer(
                              builder: (context, ref, child) {
                                final image = ref.watch(fileStateProvider);
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).colorScheme.onBackground),
                                  ),
                                  child: Icon(image != null ? Icons.done : Icons.upload),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          const WidgetCheckoutTextTitle(title: 'Tambahkan Catatan'),
                          WidgetCheckoutCatatanPengantaran(textEditingController: ref.read(checkoutStateProvider.notifier).note),
                          const SizedBox(height: 15),
                          const WidgetCheckoutTextTitle(title: 'Rincian Pembayaran'),
                          const SizedBox(height: 10),
                          WidgetCheckoutRincianPembayaran(
                            title: 'Total Pembayaran',
                            value: (cartNotifier.totalProduct()).currency(),
                          ),
                          const Divider(height: 20),
                          const WidgetCheckoutTextTitle(title: 'Opsi Pembayaran'),
                          WidgetCheckoutOpsiPembayaran(
                            groupValue: res,
                            value: PaymentMethod.trf,
                            onChanged: (value) => ref.read(radioStateProvider.notifier).update((state) => value ?? 0),
                            title: 'TRANSFER (bayar sekarang)',
                          ),
                          if (customer.business != null)
                            WidgetCheckoutOpsiPembayaran(
                              groupValue: res,
                              value: PaymentMethod.cod,
                              onChanged: (value) => ref.read(radioStateProvider.notifier).update((state) => value ?? 1),
                              title: 'COD (bayar saat pesanan diantarkan)',
                            ),
                          Consumer(
                            builder: (context, ref, child) {
                              final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
                              if (totalPrice <= 500000) return Container();
                              return Column(
                                children: [
                                  if (customer.business != null && customer.business!.credit.limit > 0)
                                    WidgetCheckoutOpsiPembayaran(
                                      groupValue: res,
                                      value: PaymentMethod.top,
                                      onChanged: (value) => ref.read(radioStateProvider.notifier).update((state) => value ?? 2),
                                      title: 'TOP (bayar nanti saat jatuh tempo)',
                                    ),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    SafeArea(
                      child: WidgetCheckoutProsesButton(
                        isLoading: loadingButton,
                        onTap: () => ref.read(checkoutStateProvider.notifier).checkout(context),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key? key,
    required this.ref,
  }) : super(key: key);

  final WidgetRef ref;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _controller;
  @override
  Widget build(BuildContext context) {
    final pickedLoc = widget.ref.watch(pickedLocation);
    final customer = widget.ref.watch(customerStateProvider);
    final business = customer.business;
    if (business == null) {
      return const Center(
        child: Text('Tidak ada bisnis yang terpilih'),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final result = await Navigator.pushNamed(context, Routes.map,
            arguments: ArgMap(
              action: (v) => widget.ref.read(pickedLocation.notifier).update((state) => v),
            )) as BusinessAddress?;
        if (result == null) return;
        widget.ref.read(pickedLocation.notifier).update((state) => result);
        _controller.moveCamera(
          CameraUpdate.newLatLng(
            LatLng(
              result.lat,
              result.lng,
            ),
          ),
        );
      },
      child: IgnorePointer(
        ignoring: true,
        child: GoogleMap(
          onMapCreated: (controller) => _controller = controller,
          initialCameraPosition: CameraPosition(
            target: LatLng(pickedLoc?.lat ?? business.address.first.lat, pickedLoc?.lng ?? business.address.first.lng),
            zoom: 14.0,
          ),
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          markers: {
            Marker(
              markerId: const MarkerId('value'),
              position: LatLng(pickedLoc?.lat ?? business.address.first.lat, pickedLoc?.lng ?? business.address.first.lng),
              icon: BitmapDescriptor.defaultMarker,
            )
          },
        ),
      ),
    );
  }
}
