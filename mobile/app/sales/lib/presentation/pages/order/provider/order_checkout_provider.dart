import 'dart:io';

import 'package:api/api.dart';
import 'package:api/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/storage.dart';

final radioStateProvider = StateProvider.autoDispose<int>((ref) {
  if (ref.watch(customerStateProvider).business == null) return 1;
  return 3;
});

final createOrderStateProvider =
    StateNotifierProvider.autoDispose<CreateOrderState, CreateOrder>((ref) {
  return CreateOrderState(ref);
});

final doubleProvider = StateProvider<Map<String, double>>((ref) {
  return {};
});
final intProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});
final isLoadingCOProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

final imageParamPOProvider =
    StateNotifierProvider<ImageParamPOStateNotifier, ImageParamPO>((ref) {
  return ImageParamPOStateNotifier();
});

class ImageParamPO extends Equatable {
  final File imagePO;

  ImageParamPO({
    File? imagePO,
  }) : imagePO = imagePO ?? File('');

  @override
  List<Object> get props => [imagePO];

  ImageParamPO copyWith({
    File? imagePO,
  }) {
    return ImageParamPO(
      imagePO: imagePO ?? this.imagePO,
    );
  }
}

class ImageParamPOStateNotifier extends StateNotifier<ImageParamPO> {
  ImageParamPOStateNotifier() : super(ImageParamPO());

  setImagePO(File file) {
    state = state.copyWith(imagePO: file);
  }
}

class CreateOrderState extends StateNotifier<CreateOrder> {
  CreateOrderState(this.ref) : super(CreateOrder()) {
    cart = ref.watch(cartStateNotifier);
    customer = ref.watch(customerStateProvider);
  }
  final AutoDisposeRef ref;
  final businessOfficeAddress = TextEditingController();
  final controllerDate = TextEditingController(text: 'Pilih tanggal');
  final controllerPO = TextEditingController(text: 'Unggah PO');
  final controllerNote = TextEditingController();

  late final List<Product> cart;
  late final Customer customer;

  Future<Order> createOrder() async {
    final image = ref.watch(imageParamPOProvider);
    final cartNot = ref.read(cartStateNotifier.notifier);
    final paymentMethod = ref.watch(radioStateProvider);
    final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
    final lastMonth = await ref.read(apiProvider).order.lastMonth(customer.id);
    final perMonth = await ref.read(apiProvider).order.perMonth(customer.id);
    final emp = ref.watch(employee);
    String filePo = "-";
    filePo = Storage()
        .path(ref: 'private/order/${customer.id}/', file: image.imagePO);
    List<UserApprover> users = [];
    if (paymentMethod != PaymentMethod.trf &&
        ((totalPrice + customer.business!.credit.used >
            customer.business!.credit.limit))) {
      await ref
          .read(apiProvider)
          .employee
          .approver(
            team: emp.team,
            regionId:
                customer.business?.location.regionId ?? emp.location?.id ?? '-',
            branchId:
                customer.business?.location.branchId ?? emp.location?.id ?? '-',
          )
          .then(
            (value) => users.addAll(
              value.map(
                (e) => UserApprover(
                  email: e.email,
                  fcmToken: e.fcmToken.isEmpty ? '-' : e.fcmToken,
                  id: e.id,
                  imageUrl: e.imageUrl,
                  name: e.name,
                  note: '-',
                  phone: e.phone,
                  roles: e.roles,
                  status: 0,
                  updatedAt: e.updatedAt,
                ),
              ),
            ),
          );
    }
    setState(
      state.copyWith(
        userApprover: users,
        code: "-",
        creditLimit: customer.business?.credit.limit ?? 0,
        creditUsed: customer.business?.credit.used ?? 0,
        deliveryType: 0,
        deliveryPrice: 0,
        transactionLastMonth: lastMonth,
        transactionPerMonth: perMonth,
        productPrice: cartNot.totalProduct(),
        totalPrice: cartNot.totalProduct(),
        termInvoice: paymentMethod == PaymentMethod.trf
            ? 1
            : customer.business?.credit.termInvoice ?? 1,
        branchId: customer.business!.location.branchId,
        branchName: customer.business!.location.branchName,
        orderCreator: state.orderCreator.copyWith(
          roles: emp.roles,
          id: emp.id,
          name: emp.name,
          email: emp.email,
          imageUrl: emp.imageUrl,
          phone: emp.phone,
        ),
        customer: state.customer.copyWith(
          picName: customer.business!.pic.name,
          picPhone: customer.business!.pic.phone,
          id: customer.id,
          name: customer.name,
          email: customer.email,
          imageUrl: customer.imageUrl,
          note: controllerNote.text,
          phone: customer.phone,
        ),
        paymentMethod: paymentMethod,
        poFilePath: filePo,
        regionId: customer.business!.location.regionId,
        regionName: customer.business!.location.regionName,
        priceId: customer.business!.priceList.id,
        priceName: customer.business!.priceList.name,
        product: List<OrderProduct>.from(
          cart.toSet().map(
                (e) => OrderProduct(
                  team: emp.team,
                  brandId: e.brand.id,
                  brandName: e.brand.name,
                  categoryId: e.category.id,
                  categoryName: e.category.name,
                  description: e.description,
                  discount: ref
                          .read(cartStateNotifier.notifier)
                          .discount(e.productId)
                          .discount
                          .toDouble() +
                      e.additionalDiscount,
                  id: e.productId,
                  imageUrl: e.imageUrl,
                  name: e.name,
                  point: e.point,
                  unitPrice: e
                      .kPrice(customer.business?.priceList.id)
                      .price
                      .toDouble(),
                  qty: cart.where((element) => element.id == e.id).length,
                  salesId: emp.id,
                  salesName: emp.name,
                  size: e.size,
                  tax: 0,
                  totalPrice: ((e
                              .kPrice(customer.business?.priceList.id)
                              .price -
                          ref
                              .read(cartStateNotifier.notifier)
                              .discount(e.productId)
                              .discount) *
                      cart
                          .where((element) => element.productId == e.productId)
                          .length),
                ),
              ),
        ),
      ),
    );
    try {
      ref.read(isLoadingCOProvider.notifier).update((state) => true);
      logger.info(state.toJson());
      Order result = const Order();
      await ref.read(apiProvider).order.create(state).then((order) async {
        if (image.imagePO.path.isNotEmpty || image.imagePO == File("")) {
          await Storage().uploadPhoto(
            ref: filePo,
            file: image.imagePO,
          );
        }
        result = order;
      });
      ref.read(isLoadingCOProvider.notifier).update((state) => false);
      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  setState(CreateOrder createOrder) {
    state = createOrder;
  }
}
