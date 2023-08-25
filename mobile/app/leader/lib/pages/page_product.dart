import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/common.dart';
import 'package:leader/argument.dart';
import 'package:leader/cart_provider.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';
import 'package:leader/widget.dart';

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, args) async {
  return ref.read(apiProvider).product.byId(args);
});

class PageProduct extends ConsumerWidget {
  final ArgProductDetail arg;
  const PageProduct({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(productDetailProvider(arg.id));
    final cart = ref.watch(cartStateNotifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Produk'),
        actions: const [CartWidget()],
      ),
      body: res.when(
        data: (data) {
          final product = data;
          return WidgetDetailProduct(
            photoView: () {},
            bannerImage: Image.network(product.imageUrl),
            brandImage: Image.network(product.brand.imageUrl),
            name: product.name,
            size: product.size,
            textPrice: TextPrice(product: product),
            category: product.category.name,
            description: product.description,
            plusMinusButton: SizedBox(
              width: MediaQuery.of(context).size.width - 220,
              child: WidgetPlusMinusButton(
                isCenter: true,
                add: () => ref.read(cartStateNotifier.notifier).add(data),
                remove: () => ref.read(cartStateNotifier.notifier).remove(data.productId),
                qtys: cart.where((element) => element.id == data.id).toList().length,
                qty: TextCount(product: data),
              ),
            ),
            checkout: () async {
              try {
                if (cart.isEmpty) return;
                final totalPrice = ref.watch(cartStateNotifier.notifier).totalProduct();
                if (totalPrice < 50000) {
                  throw 'Belanjaan Anda masih kurang dari ${50000.currency()}.  Belanja lagi yuk!';
                }
                Navigator.pushNamed(context, Routes.checkout);
                return;
              } catch (e) {
                Alerts.dialog(context, content: e.toString());
                return;
              }
            },
            subtotal: ref.watch(cartStateNotifier.notifier).totalProduct().floor().currency(),
          );
        },
        error: (error, stackTrace) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
