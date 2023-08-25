import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:common/function/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/config/app_pages.dart';
import 'package:sales/presentation/pages/cart/provider/cart_provider.dart';
import 'package:sales/presentation/pages/order/provider/order_checkout_provider.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';
import 'package:sales/presentation/widgets/app_alert_dialog.dart';
import 'package:sales/presentation/widgets/app_button_widget.dart';
import 'package:sales/presentation/widgets/app_empty_widget.dart';
import 'package:sales/presentation/widgets/app_image_widget.dart';
import 'package:sales/presentation/widgets/app_scaffold_messenger.dart';
import 'package:common/common.dart';

class CartPage extends ConsumerWidget {
  const CartPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateRead = ref.read(createOrderStateProvider.notifier);
    final stateOrderWatch = ref.watch(createOrderStateProvider);
    final stateWatch = ref.watch(cartStateNotifier);
    final uniqueList = stateWatch.toSet().toList();
    uniqueList.sort(((a, b) => a.id.compareTo(b.id)));
    final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: uniqueList.isEmpty
          ? const AppEmptyWidget(title: "Keranjang kosong")
          : ListView.separated(
              padding: const EdgeInsets.all(Dimens.px16),
              itemCount: uniqueList.length,
              itemBuilder: (context, index) {
                return pesanan(context, uniqueList[index], ref, index);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: Dimens.px12);
              },
            ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Material(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(Dimens.px30),
                    ),
                    child: InkWell(
                      onTap: () async {
                        try {
                          if (totalPrice == 0) {
                            throw 'Pilih produk terlebih dahulu.';
                          }
                          if (totalPrice < 50000) {
                            throw 'Belanjaan Anda masih kurang dari ${50000.currency()}. Belanja lagi yuk!';
                          }
                          stateRead.setState(
                            stateOrderWatch.copyWith(
                                // deliveryAddress: Address(
                                //     name: cusWatch.business!.address.first.name,
                                //     lngLat:
                                //         cusWatch.business!.address.first.lngLat),
                                ),
                          );
                          Navigator.pushNamed(context, AppRoutes.orderCheckout);
                        } catch (e) {
                          AppScaffoldMessanger.showSnackBar(context: context, message: e.toString());
                          return;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 46,
                          vertical: Dimens.px16,
                        ),
                        child: Text(
                          'Checkout',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.px16, vertical: Dimens.px6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Sub total', style: theme.textTheme.titleMedium),
                          Text(
                            totalPrice.currency(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pesanan(
    BuildContext context,
    Product price,
    WidgetRef ref,
    int index,
  ) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Consumer(
      builder: (context, ref, child) {
        final stateWatch = ref.watch(cartStateNotifier);
        final statereadNotifier = ref.watch(cartStateNotifier.notifier);
        final uniqueList = stateWatch.toSet().toList();
        final adds = ref.watch(doubleProvider);
        final product = uniqueList[index];
        final customer = ref.watch(customerStateProvider);
        final pprice = product.kPrice(customer.business?.priceList.id).price;
        int qty = stateWatch.where((element) => element.id == price.id).toList().length;
        return ListTile(
          onTap: () => showModalBottomSheet(
            context: context,
            builder: (context) => Consumer(
              builder: (context, ref, child) {
                final add = ref.watch(doubleProvider);
                return Padding(
                  padding: const EdgeInsets.all(Dimens.px16).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 35,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(15)),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => ref.read(doubleProvider.notifier).update((state) {
                              if (state[product.productId] == 0) return state;
                              final result = (state[product.productId] ?? 0) - 0.25;
                              return {
                                ...state,
                                product.productId: result,
                              };
                            }),
                            child: const Icon(
                              Icons.remove_circle,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(add[product.productId] ?? 0.0).toStringAsFixed(2)} %',
                            style: const TextStyle(fontSize: 25),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => ref.read(doubleProvider.notifier).update((state) {
                              if (state[product.productId] == 5) {
                                return state;
                              }
                              final result = (state[product.productId] ?? 0) + 0.25;
                              return {
                                ...state,
                                product.productId: result,
                              };
                            }),
                            child: const Icon(
                              Icons.add_circle_outlined,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ),
          contentPadding: EdgeInsets.zero,
          leading: Material(
            color: theme.highlightColor,
            borderRadius: BorderRadius.circular(Dimens.px16),
            child: Padding(
              padding: const EdgeInsets.all(Dimens.px10),
              child: AppImagePrimary(
                width: size.width * 0.1,
                height: size.width * 0.1,
                imageUrl: price.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Text(
            price.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price.size, maxLines: 1),
              statereadNotifier.discount(product.productId).discount > 0 || (adds[product.productId] != null && adds[product.productId] != 0.0)
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${pprice.currency()}\n',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.black,
                              decorationThickness: Theme.of(context).brightness == Brightness.dark ? 3 : 1.5,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: (pprice -
                                    statereadNotifier.discount(product.productId).discount -
                                    statereadNotifier.additional((adds[product.productId] ?? 0), product.productId))
                                .currency(),
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(pprice.currency()),
            ],
          ),
          trailing: ButtonPlusMin(
            onPlus: () {
              statereadNotifier.add(price);
            },
            onMin: () {
              if (qty <= 1) {
                AppActionDialog.show(
                  context: context,
                  isAction: true,
                  title: "Konfirmasi",
                  content: "Apakah Anda yakin ingin menghapus item ini dari keranjang?",
                  onPressNo: () {
                    Navigator.pop(context);
                  },
                  onPressYes: () {
                    statereadNotifier.remove(price.id);
                    Navigator.pop(context);
                  },
                );
              } else {
                statereadNotifier.remove(price.id);
              }
            },
            onTap: () {
              showBottomSheetUpdateQty(
                context,
                price: price,
                ref: ref,
              );
            },
            text: qty.toString(),
          ),
        );
      },
    );
  }
}

Future<void> showBottomSheetUpdateQty(
  BuildContext context, {
  required Product price,
  required WidgetRef ref,
}) async {
  final stateWatch = ref.watch(cartStateNotifier);
  int initialValue = stateWatch.where((element) => element.id == price.id).toList().length;
  final controller = TextEditingController(text: initialValue.toString());
  final theme = Theme.of(context);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Dimens.px30),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.px12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Dimens.px10),
              Text('Ubah Kuantitas', style: theme.textTheme.titleLarge),
              Expanded(
                child: TextFormField(
                  maxLength: 3,
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Kuantitas',
                    hintText: 'Masukkan kuantitas',
                  ),
                  onFieldSubmitted: (value) {
                    if (formKey.currentState!.validate()) {
                      ref.read(cartStateNotifier.notifier).clear(price.productId);
                      for (int i = 0; i < int.parse(value); i++) {
                        ref.read(cartStateNotifier.notifier).add(price);
                      }
                      Navigator.pop(context);
                    }
                  },
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Kuantitas tidak boleh kosong';
                    }
                    if (int.parse(value) > 999) {
                      return 'Kuantitas maksimal 999';
                    }
                    if (int.parse(value) == 0) {
                      return 'Kuantitas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
