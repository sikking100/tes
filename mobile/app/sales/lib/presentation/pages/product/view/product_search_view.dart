import 'package:api/common.dart';
import 'package:api/product/model.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/product/product_page.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';

final productSearchListNotifierProvider =
    StateNotifierProvider.autoDispose<ProductListNotifier, Paging<Product>>(
        (ref) {
  return ProductListNotifier(ref);
});

class ProductListNotifier extends StateNotifier<Paging<Product>> {
  ProductListNotifier(this.ref) : super(const Paging<Product>(null, []));
  final AutoDisposeRef ref;
  String error = '';
  bool isLoading = false;
  TextEditingController textController = TextEditingController();

  void searchProduuct() async {
    try {
      final cus = ref.watch(customerStateProvider);
      await ref
          .read(apiProvider)
          .product
          .find(
              query: cus.business!.location.branchId,
              sort: 1,
              search: textController.text)
          .then((value) => state = value);
    } catch (e) {
      rethrow;
    }
  }
}

class ProductSearchView {
  static void showCustomerSearch(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final stateWatch = ref.watch(productSearchListNotifierProvider);
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(Dimens.px30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: Dimens.px20),
                    Text('Pencarian', style: theme.textTheme.titleLarge),
                    const SizedBox(height: Dimens.px20),
                    _buildFormSearch(context),
                    Expanded(
                      child: AlignedGridView.count(
                        padding: const EdgeInsets.all(Dimens.px16),
                        itemBuilder: (context, index) {
                          return ProductCart(
                            price: stateWatch.items[index],
                          );
                        },
                        itemCount: stateWatch.items.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: Dimens.px6,
                        crossAxisSpacing: Dimens.px6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFormSearch(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, child) {
        final stateWatch = ref.read(productSearchListNotifierProvider.notifier);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.px16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.search,
                      controller: stateWatch.textController,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length > 2) stateWatch.searchProduuct();
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari produk',
                        filled: true,
                        fillColor: theme.highlightColor,
                        prefixIcon: const Icon(Icons.grid_view_outlined),
                        suffixIcon: const Icon(Icons.search_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Dimens.px30,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(
                          Dimens.px16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
