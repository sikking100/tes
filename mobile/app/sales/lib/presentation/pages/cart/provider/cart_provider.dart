import 'package:api/price_list/model.dart';
import 'package:api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';

final cartStateNotifier = StateNotifierProvider<Cart, List<Product>>((_) => Cart(_));

final isLoadingCartProvider = StateProvider.autoDispose<bool>((_) {
  return false;
});

class Cart extends StateNotifier<List<Product>> {
  Cart(this.ref) : super([]) {
    customer = ref.watch(customerStateProvider);
  }
  final Ref ref;
  late Customer customer;
  void add(Product p) {
    if (state.length >= 999) return;
    state = [...state, p];
    return;
  }

  void clear(String id) {
    final index = state.indexWhere((element) => element.productId == id);
    if (index > -1) {
      state.removeWhere((element) => element.productId == id);
      state = [...state];
    }
  }

  void remove(String id) {
    final index = state.indexWhere((element) => element.id == id);
    if (index > -1) {
      state.removeAt(index);
      state = [...state];
    }
  }

  Discount discount(String id) {
    if (state.where((element) => element.productId == id).isEmpty) {
      return const Discount();
    }
    final product = state.firstWhere((e) => e.productId == id);
    final uniqueLength = state.where((element) => element.productId == id).toList().length;
    final priceList = product.kPrice(customer.business?.priceList.id);
    Discount d = const Discount();
    if (priceList.discount.isEmpty) {
      return const Discount();
    }

    priceList.discount.sort((a, b) => a.min.compareTo(b.min));

    for (var dis in priceList.discount) {
      final max = dis.max;
      if (max == null && uniqueLength >= dis.min) {
        d = dis;
        break;
      }
      if (max != null && uniqueLength >= dis.min && uniqueLength <= max) {
        d = dis;
        break;
      }
    }
    return d;
  }

  double totalProduct() {
    if (state.isEmpty) return 0;
    final result = state.map((e) {
      double disc = discount(e.productId).discount;
      if (e.additionalDiscount != 0) {
        return e.kPrice(customer.business?.priceList.id).price - e.additionalDiscount - disc;
      }
      return e.kPrice(customer.business?.priceList.id).price - disc;
    }).reduce((value, element) => value + element);
    return result;
  }

  double additional(double dis, String id) {
    final total = state.firstWhere((element) => element.productId == id);
    final result = total.price.first.price * dis / 100;
    return result;
  }
}
