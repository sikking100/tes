import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:common/widget/alert.dart';
import 'package:customer/argument.dart';
import 'package:customer/cart.dart';
import 'package:customer/main_controller.dart';
import 'package:customer/pages/home.dart';
import 'package:customer/pages/order_detail.dart';
import 'package:customer/routes.dart';
import 'package:customer/view_home/beranda.dart';
import 'package:customer/view_home/kelola.dart';
import 'package:customer/widget.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final radioStateProvider = StateProvider.autoDispose<int>((ref) {
  if (ref.watch(customerStateProvider).business == null) return 2;
  return 3;
});

final dateStateProvider = StateProvider.autoDispose<DateTime?>((ref) {
  return null;
});

final alamatFuture = FutureProvider.autoDispose<String>((ref) async {
  final location = await ref.watch(locationProvider.future);
  final result = await GeocodingPlatform.instance.placemarkFromCoordinates(location.latitude ?? 0.0, location.longitude ?? 0.0);
  final alamat =
      '${result.first.street}, ${result.first.subLocality}, ${result.first.locality}, ${result.first.subAdministrativeArea}, ${result.first.administrativeArea}, ${result.first.postalCode}, ${result.first.country}';
  return alamat;
});

final checkoutStateProvider = StateNotifierProvider.autoDispose<CheckoutState, bool>((ref) => CheckoutState(false, ref));

final pickedLocation = StateProvider.autoDispose<BusinessAddress?>((ref) {
  final b = ref.watch(customerStateProvider);
  return b.business?.address.first;
});
final mapController = Provider.autoDispose.family<GoogleMapController, GoogleMapController>((_, arg) => arg);

class CheckoutState extends StateNotifier<bool> {
  CheckoutState(super.state, this.ref) {
    note = TextEditingController();
    branch = ref.watch(branchProvider);
    cart = ref.watch(cartStateNotifier);
    customer = ref.watch(customerStateProvider);
    if (customer.business == null) {
      cekOngkir();
    }
  }
  final AutoDisposeRef ref;
  late final TextEditingController note;
  late final Branch branch;
  late final List<Product> cart;
  late final Customer customer;

  double ongkir = 0;
  String error = '';

  void cekOngkir() async {
    state = true;
    try {
      final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
      if (totalPrice <= 500000) {
        final defLoc = await ref.watch(locationProvider.future);
        final pickedLoc = ref.watch(pickedLocation);

        final branch = ref.watch(branchProvider);

        final warehouse = branch.warehouse.firstWhere((element) => element.isDefault);

        final result = await ref.read(apiProvider).delivery.gosendPrice(
              oriLat: warehouse.address.lat,
              oriLng: warehouse.address.lng,
              desLat: pickedLoc?.lat ?? defLoc.latitude ?? 0.0,
              desLng: pickedLoc?.lng ?? defLoc.longitude ?? 0.0,
            );
        ongkir = result;
      } else {
        ongkir = 0;
      }
      return;
    } catch (e) {
      error = e.toString();
      return;
    } finally {
      state = false;
    }
  }

  int get team {
    //1 food
    //2 retail
    // if (!cart.map((e) => e.category.team).contains(1)) return 2;
    // if (!cart.map((e) => e.category.team).contains(2)) return 1;
    if (cart.where((element) => element.category.team == 1).isEmpty) return 2;
    if (cart.where((element) => element.category.team == 2).isEmpty) return 1;
    final food = cart.where((element) => element.category.team == 1).toList();
    final retail = cart.where((element) => element.category.team == 2).toList();
    final foodPrice = food
        .map((e) => e.kPrice(customer.business?.priceList.id).price - ref.read(cartStateNotifier.notifier).discount(e.productId).discount)
        .reduce((value, element) => value + element);

    final retailPrice = retail
        .map((e) => e.kPrice(customer.business?.priceList.id).price - ref.read(cartStateNotifier.notifier).discount(e.productId).discount)
        .reduce((value, element) => value + element);

    if (foodPrice > retailPrice) return 1;
    if (retailPrice > foodPrice) return 2;
    if (food.length > retail.length) return 1;
    return 2;
  }

  Future<void> checkout(BuildContext context) async {
    ref.read(loadingProvider.notifier).update((state) => true);
    try {
      final date = ref.watch(dateStateProvider);
      if (date == null) throw 'Anda belum memilih tanggal pengantaran';
      final paymentMethod = ref.watch(radioStateProvider);
      if (paymentMethod > 2) throw 'Anda belum memilih metode pembayaran';
      final defLoc = await ref.watch(locationProvider.future);
      final pickedLoc = ref.watch(pickedLocation);
      final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
      if (totalPrice < 50000) throw 'Belanjaan Anda masih kurang dari ${50000.currency()}.  Belanja lagi yuk!';

      final lastMonth = await ref.read(apiProvider).order.lastMonth(customer.id);
      final perMonth = await ref.read(apiProvider).order.perMonth(customer.id);

      List<UserApprover> approver = [];

      if (paymentMethod != 2) {
        final appr = await ref.read(apiProvider).employee.approver(
              regionId: customer.business?.location.regionId ?? branch.region?.id ?? '',
              branchId: customer.business?.location.branchId ?? branch.id,
              team: team,
            );
        approver.addAll(appr);
      }

      final cus = await ref.read(apiProvider).customer.byId(customer.id);

      // final List<OrderProduct> product = [];

      // for (var p in cart.toSet()) {
      //   final uniqueLength = cart.where((element) => element.productId == p.productId).length;
      //   final priceList = p.kPrice(customer.business?.priceList.id);
      //   priceList.discount.sort((a, b) => a.min.compareTo(b.min));
      //   if (uniqueLength > (priceList.discount.last.max ?? 0)) {
      //     final max = priceList.discount.last.max ?? 0;
      //     product.add(
      //       OrderProduct(
      //         brandId: p.brand.id,
      //         brandName: p.brand.name,
      //         categoryId: p.category.id,
      //         categoryName: p.category.name,
      //         description: p.description,
      //         discount: 0,
      //         id: p.productId,
      //         imageUrl: p.imageUrl,
      //         name: p.name,
      //         point: p.point,
      //         unitPrice: priceList.price,
      //         salesId: '-',
      //         salesName: '-',
      //         qty: cart.where((element) => element.id == p.id).length - max,
      //         size: p.size,
      //         tax: 0,
      //         totalPrice: (priceList.price * ((cart.where((element) => element.id == p.id).length) - max)),
      //       ),
      //     );
      //     product.add(
      //       OrderProduct(
      //         brandId: p.brand.id,
      //         brandName: p.brand.name,
      //         categoryId: p.category.id,
      //         categoryName: p.category.name,
      //         description: p.description,
      //         discount: priceList.discount.last.discount,
      //         id: p.productId,
      //         imageUrl: p.imageUrl,
      //         name: p.name,
      //         point: p.point,
      //         unitPrice: priceList.price,
      //         salesId: '-',
      //         salesName: '-',
      //         qty: max,
      //         size: p.size,
      //         tax: 0,
      //         totalPrice: ((priceList.price - priceList.discount.last.discount) * max),
      //       ),
      //     );
      //   } else {
      //     product.add(OrderProduct(
      //       brandId: p.brand.id,
      //       brandName: p.brand.name,
      //       categoryId: p.category.id,
      //       categoryName: p.category.name,
      //       description: p.description,
      //       discount: ref.read(cartStateNotifier.notifier).discount(p.productId).discount,
      //       id: p.productId,
      //       imageUrl: p.imageUrl,
      //       name: p.name,
      //       point: p.point,
      //       unitPrice: p.kPrice(customer.business?.priceList.id).price,
      //       salesId: '-',
      //       salesName: '-',
      //       qty: cart.where((element) => element.id == p.id).length,
      //       size: p.size,
      //       tax: 0,
      //       totalPrice: (p.kPrice(customer.business?.priceList.id).price * cart.where((element) => element.id == p.id).length),
      //     ));
      //   }
      // }

      // final List<OrderProduct> product = [];

      // for (var p in cart.toSet()) {
      //   final uniqueLength = cart.where((element) => element.productId == p.productId).length;
      //   final priceList = p.kPrice(customer.business?.priceList.id);
      //   priceList.discount.sort((a, b) => a.min.compareTo(b.min));
      //   if (uniqueLength > (priceList.discount.last.max ?? 0)) {
      //     final max = priceList.discount.last.max ?? 0;
      //     product.add(
      //       OrderProduct(
      //         brandId: p.brand.id,
      //         brandName: p.brand.name,
      //         categoryId: p.category.id,
      //         categoryName: p.category.name,
      //         description: p.description,
      //         discount: 0,
      //         id: p.productId,
      //         imageUrl: p.imageUrl,
      //         name: p.name,
      //         point: p.point,
      //         unitPrice: priceList.price,
      //         salesId: '-',
      //         salesName: '-',
      //         qty: cart.where((element) => element.id == p.id).length - max,
      //         size: p.size,
      //         tax: 0,
      //         totalPrice: (priceList.price * ((cart.where((element) => element.id == p.id).length) - max)),
      //       ),
      //     );
      //     product.add(
      //       OrderProduct(
      //         brandId: p.brand.id,
      //         brandName: p.brand.name,
      //         categoryId: p.category.id,
      //         categoryName: p.category.name,
      //         description: p.description,
      //         discount: priceList.discount.last.discount,
      //         id: p.productId,
      //         imageUrl: p.imageUrl,
      //         name: p.name,
      //         point: p.point,
      //         unitPrice: priceList.price,
      //         salesId: '-',
      //         salesName: '-',
      //         qty: max,
      //         size: p.size,
      //         tax: 0,
      //         totalPrice: ((priceList.price - priceList.discount.last.discount) * max),
      //       ),
      //     );
      //   } else {
      //     product.add(OrderProduct(
      //       brandId: p.brand.id,
      //       brandName: p.brand.name,
      //       categoryId: p.category.id,
      //       categoryName: p.category.name,
      //       description: p.description,
      //       discount: ref.read(cartStateNotifier.notifier).discount(p.productId).discount,
      //       id: p.productId,
      //       imageUrl: p.imageUrl,
      //       name: p.name,
      //       point: p.point,
      //       unitPrice: p.kPrice(customer.business?.priceList.id).price,
      //       salesId: '-',
      //       salesName: '-',
      //       qty: cart.where((element) => element.id == p.id).length,
      //       size: p.size,
      //       tax: 0,
      //       totalPrice: (p.kPrice(customer.business?.priceList.id).price * cart.where((element) => element.id == p.id).length),
      //     ));
      //   }
      // }

      final create = CreateOrder(
        orderCreator: OrderCreator(
          id: cus.id,
          email: cus.email,
          imageUrl: cus.imageUrl,
          name: cus.name,
          phone: cus.phone,
          roles: 0,
        ),
        branchId: cus.business?.location.branchId ?? branch.id,
        branchName: cus.business?.location.branchName ?? branch.name,
        customer: OrderCustomer(
          id: cus.id,
          name: cus.name,
          note: note.text.isEmpty ? '-' : note.text,
          email: cus.email,
          phone: cus.phone,
          imageUrl: cus.imageUrl,
          picName: cus.business?.pic.name ?? cus.name,
          picPhone: cus.business?.pic.phone ?? cus.phone,
          addressName: pickedLoc?.name ?? cus.business?.address.first.name ?? ref.read(alamatFuture).value ?? '',
          addressLngLat: pickedLoc?.lngLat ?? cus.business?.address.first.lngLat ?? [defLoc.longitude ?? 0.0, defLoc.latitude ?? 0.0],
        ),
        deliveryAt: date,
        deliveryType: ongkir == 0 ? 0 : 1,
        deliveryPrice: ongkir,
        paymentMethod: paymentMethod,
        priceId: cus.business?.priceList.id ?? cart.first.price.first.id,
        priceName: cus.business?.priceList.name ?? cart.first.price.first.name,
        regionId: cus.business?.location.regionId ?? branch.region?.id ?? '-',
        regionName: cus.business?.location.regionName ?? branch.region?.name ?? '-',
        code: '-',
        poFilePath: '-',
        creditLimit: cus.business?.credit.limit ?? 0,
        creditUsed: cus.business?.credit.used ?? 0,
        transactionLastMonth: lastMonth,
        transactionPerMonth: perMonth,
        productPrice: ref.read(cartStateNotifier.notifier).totalProduct(),
        totalPrice: (ref.read(cartStateNotifier.notifier).totalProduct() + ongkir),
        termInvoice: paymentMethod == PaymentMethod.trf ? 1 : cus.business?.credit.termInvoice ?? 1,
        userApprover: approver,
        product:
            // product,
            List<OrderProduct>.from(
          cart.toSet().map(
                (e) => OrderProduct(
                  team: e.category.team,
                  brandId: e.brand.id,
                  brandName: e.brand.name,
                  categoryId: e.category.id,
                  categoryName: e.category.name,
                  description: 'e.description',
                  discount: ref.read(cartStateNotifier.notifier).discount(e.productId).discount,
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
                  totalPrice: ((e.kPrice(cus.business?.priceList.id).price - ref.read(cartStateNotifier.notifier).discount(e.productId).discount) *
                      cart.where((element) => element.productId == e.productId).length),
                ),
              ),
        ),
      );

      final result = await ref.read(apiProvider).order.create(create);

      if (ref.read(radioStateProvider) == PaymentMethod.trf) {
        final invoice = await ref.read(apiProvider).invoice.create(result.invoiceId);
        final inv = await ref.read(apiProvider).invoice.byId(invoice.id);
        if (context.mounted) {
          await Navigator.pushNamed(context, Routes.webview, arguments: {'title': 'Transaksi', 'url': inv.url}).whenComplete(() {
            ref.invalidate(orderProvider(result.id));
            return;
          });
        }
      }
      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushNamed(context, Routes.orderDetail, arguments: result.id);
      }
      ref.invalidate(cartStateNotifier);
      return;
    } catch (e) {
      await Alerts.dialog(context, content: '$e');
      return;
    } finally {
      ref.read(loadingProvider.notifier).update((state) => false);
      ref.invalidate(orderPendingProvider);
    }
  }
}

class PageCheckout extends ConsumerWidget {
  const PageCheckout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(radioStateProvider);
    final date = ref.watch(dateStateProvider);
    final alamat = ref.watch(alamatFuture);
    final cartNotifier = ref.watch(cartStateNotifier.notifier);
    final loading = ref.watch(checkoutStateProvider);
    final error = ref.watch(checkoutStateProvider.notifier).error;
    final pickedLoc = ref.watch(pickedLocation);
    final customer = ref.watch(customerStateProvider);
    final ongkir = ref.watch(checkoutStateProvider.notifier).ongkir;
    final loadingButton = ref.watch(loadingProvider);
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
                          if (customer.business == null)
                            if (pickedLoc == null)
                              alamat.when(
                                data: (data) => Text(
                                  data,
                                ),
                                error: (e, _) => Text(
                                  e.toString(),
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              )
                            else
                              Text(pickedLoc.name)
                          else
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.pushNamed(context, Routes.businessAddress,
                                    arguments: ArgBusinessListAddress(customer.business?.address ?? [], isCheckout: true)) as BusinessAddress?;

                                if (result == null) return;
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(customer.name),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                  Text(pickedLoc?.name ?? ''),
                                ],
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
                                  DateTime.now().year + (DateTime.now().month == 12 && DateTime.now().day == 30 ? 1 : 0),
                                  DateTime.now().month + 1,
                                  DateTime.now().day + 1,
                                ),
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
                          const WidgetCheckoutTextTitle(title: 'Tambahkan Catatan'),
                          WidgetCheckoutCatatanPengantaran(textEditingController: ref.read(checkoutStateProvider.notifier).note),
                          const SizedBox(height: 15),
                          const WidgetCheckoutTextTitle(title: 'Rincian Pembayaran'),
                          if (customer.business == null && ongkir > 0)
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                WidgetCheckoutRincianPembayaran(title: 'Total Belanja', value: cartNotifier.totalProduct().currency()),
                                const SizedBox(height: 10),
                                WidgetCheckoutRincianPembayaran(title: 'Ongkir', value: ongkir.currency()),
                              ],
                            ),
                          const SizedBox(height: 10),
                          WidgetCheckoutRincianPembayaran(
                            title: 'Total Pembayaran',
                            value: (cartNotifier.totalProduct() + ongkir).currency(),
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
                    )),
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
    final loc = widget.ref.watch(locationProvider);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final result = await Navigator.pushNamed(context, Routes.mapPick) as BusinessAddress?;
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
            target: pickedLoc == null
                ? loc.when(
                    data: (data) => LatLng(data.latitude ?? 0.0, data.longitude ?? 0.0),
                    error: (error, stackTrace) => const LatLng(0.0, 0.0),
                    loading: () => const LatLng(0.0, 0.0),
                  )
                : LatLng(pickedLoc.lat, pickedLoc.lng),
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
              position: pickedLoc == null
                  ? loc.when(
                      data: (data) => LatLng(data.latitude ?? 0.0, data.longitude ?? 0.0),
                      error: (error, stackTrace) => const LatLng(0.0, 0.0),
                      loading: () => const LatLng(0.0, 0.0),
                    )
                  : LatLng(pickedLoc.lat, pickedLoc.lng),
              icon: BitmapDescriptor.defaultMarker,
            )
          },
        ),
      ),
    );
  }
}
