import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/routes.dart';

final catalogStateNotifierProvider = StateNotifierProvider.autoDispose<CatalogNotifier, PagingController<int, Product>>((ref) {
  return CatalogNotifier(ref);
});

class CatalogNotifier extends StateNotifier<PagingController<int, Product>> {
  CatalogNotifier(this.ref) : super(PagingController(firstPageKey: 1)) {
    state.addPageRequestListener((pageKey) => fetch(pageKey));
  }

  final AutoDisposeRef ref;

  fetch(int pageKey) async {
    try {
      final result = await ref.read(apiProvider).product.find(query: '');
      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, pageKey + 1);
      }
      return;
    } catch (e) {
      state.error = e.toString();
      return;
    }
  }
}

class PageCatalogs extends ConsumerWidget {
  const PageCatalogs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = ref.watch(catalogStateNotifierProvider);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: const [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.search_rounded),
          // ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // SliverPadding(
          //   padding: const EdgeInsets.symmetric(vertical: 16),
          //   sliver: SliverToBoxAdapter(
          //     child: SizedBox(
          //       height: size.height * 0.12,
          //       child: PagedListView.separated(
          //         pagingController: _pagingBrandController,
          //         shrinkWrap: true,
          //         padding: const EdgeInsets.symmetric(horizontal: 16),
          //         scrollDirection: Axis.horizontal,
          //         builderDelegate: PagedChildBuilderDelegate<Brand>(
          //           itemBuilder: (_, brand, index) => SizedBox(
          //             width: size.height * 0.12,
          //             child: Card(
          //               clipBehavior: Clip.hardEdge,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               elevation: 1.5,
          //               shadowColor: theme.highlightColor,
          //               child: InkWell(
          //                 onTap: () {},
          //                 child: Container(
          //                   padding: const EdgeInsets.all(10),
          //                   color: theme.highlightColor.withOpacity(0.3),
          //                   child: LeaderImage(imageUrl: brand.imageUrl),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //         separatorBuilder: (context, index) {
          //           return const SizedBox(width: 8);
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          SliverPadding(
            padding: const EdgeInsets.all(Dimens.px16),
            sliver: PagedSliverGrid(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<Product>(
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text('Belum ada data'),
                ),
                itemBuilder: (_, product, index) => GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.catalog, arguments: product),
                  child: Card(
                    child: Column(
                      children: [
                        Flexible(
                          flex: 3,
                          child: Container(
                            // height: 120,
                            width: size.width,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: theme.highlightColor.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                            child: FittedBox(
                              child: Hero(
                                tag: product.id,
                                child: Image.network(
                                  product.imageUrl,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(Dimens.px16).copyWith(bottom: 5),
                            child: Column(
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.size,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  product.brand.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  product.category.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.57,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
