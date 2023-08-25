import 'package:api/common.dart';
import 'package:common/constant/constant.dart';
import 'package:customer/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:api/api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final labelStateProvider = StateProvider.autoDispose<String>((ref) {
  return 'Semua';
});

final getCategoryRecipe = FutureProvider.autoDispose<List<String>>((ref) async {
  final api = ref.watch(apiProvider);
  try {
    final result = await api.recipe.categories();
    result.insert(0, 'Semua');
    return result;
  } catch (e) {
    throw e.toString();
  }
});

final getRecipeBySearch = FutureProvider.autoDispose<List<Recipe>>(((ref) async {
  final api = ref.watch(apiProvider);
  final search = ref.watch(searchStringState);
  try {
    final result = await api.recipe.search(search);
    return result;
  } catch (e) {
    throw e.toString();
  }
}));

final searchBoolState = StateProvider.autoDispose<bool>((_) => false);
final searchStringState = StateProvider.autoDispose<String>((_) => '');
final resepScrollController = Provider.autoDispose<ScrollController>((_) => ScrollController());

final recipeStateNotifierProvider = StateNotifierProvider.autoDispose<RecipeNotifier, PagingController<int, Recipe>>((ref) {
  return RecipeNotifier(ref);
});

class RecipeNotifier extends StateNotifier<PagingController<int, Recipe>> {
  RecipeNotifier(this.ref) : super(PagingController(firstPageKey: 1)) {
    error = '';
    label = 'Semua';
    ref.listen(labelStateProvider, (previous, next) => label = next);
    state.addPageRequestListener((pageKey) => request(pageKey));
  }

  final AutoDisposeRef ref;
  late String error;
  late String label;

  void request(int pageKey) async {
    try {
      Paging<Recipe> result;
      if (label == 'Semua') {
        result = await ref.read(apiProvider).recipe.finds(num: pageKey);
      } else {
        result = await ref.read(apiProvider).recipe.finds(category: label, num: pageKey);
      }
      if (result.next == null) {
        state.appendLastPage(result.items);
      } else {
        state.appendPage(result.items, result.next);
      }
      return;
    } catch (e) {
      state.error = e.toString();
      return;
    }
  }
}

class ViewHomeRecipe extends ConsumerWidget {
  const ViewHomeRecipe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getListCat = ref.watch(getCategoryRecipe);
    final cat = ref.watch(labelStateProvider);
    final searchState = ref.watch(searchBoolState);
    final searchString = ref.watch(searchStringState);
    final scroll = ref.watch(resepScrollController);
    final paging = ref.watch(recipeStateNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: AnimatedContainer(
          duration: const Duration(seconds: 10),
          curve: Curves.linear,
          child: !searchState
              ? const Text('Resep')
              : TextField(
                  onChanged: (value) {
                    if (value.length > 3) {
                      ref.read(searchStringState.notifier).update((state) => state = value);
                      return;
                    } else {
                      ref.read(searchStringState.notifier).update((state) => state = '');
                      return;
                    }
                  },
                ),
        ),
        actions: [
          searchState
              ? IconButton(
                  onPressed: () {
                    ref.invalidate(searchStringState);
                    ref.read(searchBoolState.notifier).update((state) => state = false);
                  },
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () => ref.read(searchBoolState.notifier).update((state) => state = true),
                  icon: const Icon(
                    Icons.search_outlined,
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          getListCat.when(
            data: (data) {
              final datas = data.toSet().toList();
              return SizedBox(
                height: MediaQuery.of(context).size.height * 12 / 100,
                child: ListView.separated(
                  controller: scroll,
                  padding: const EdgeInsets.all(Dimens.px16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => ChoiceChip(
                    label: Container(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 30 / 100),
                      height: MediaQuery.of(context).size.height * 4.5 / 100,
                      child: Center(
                        child: Text(
                          datas[index],
                        ),
                      ),
                    ),
                    selected: cat == datas[index],
                    disabledColor: Colors.grey.shade100,
                    onSelected: searchState
                        ? null
                        : (v) async {
                            ref.read(labelStateProvider.notifier).update((state) => state = datas[index]);
                            scroll.position.animateTo(
                              (scroll.position.viewportDimension + scroll.position.maxScrollExtent) * index / datas.length,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                            // ref.invalidate(recipeStateNotifierProvider);
                            paging.refresh();
                          },
                  ),
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemCount: datas.length,
                ),
              );
            },
            error: (e, s) => SizedBox(
              height: MediaQuery.of(context).size.height * 10 / 100,
              child: Center(
                child: Text(e.toString()),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
          ),
          if (searchString.isNotEmpty)
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final resepBySearch = ref.watch(getRecipeBySearch);
                  return resepBySearch.when(
                    data: (data) {
                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
                                child: Text(
                                  data[index].title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(data[index].imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 250,
                              ),
                              Container(
                                padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 10, bottom: 0),
                                child: Text(data[index].description),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                          height: 40,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : null,
                        ),
                        itemCount: data.length,
                      );
                    },
                    error: (e, _) => Center(child: Text(e.toString())),
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                  );
                },
              ),
            )
          else
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: () => Future.sync(() => paging.refresh()),
                child: PagedListView<int, Recipe>.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  pagingController: paging,
                  builderDelegate: PagedChildBuilderDelegate<Recipe>(
                    noItemsFoundIndicatorBuilder: (context) => const Center(
                      child: Text('Belum ada data'),
                    ),
                    itemBuilder: (context, item, index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 0),
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 250,
                        ),
                        Container(
                          padding: const EdgeInsets.all(Dimens.px16).copyWith(top: 10, bottom: 0),
                          child: Text(item.description),
                        )
                      ],
                    ),
                  ),
                  separatorBuilder: (context, index) => Divider(
                    height: 40,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
