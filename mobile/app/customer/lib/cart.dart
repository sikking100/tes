import 'package:api/api.dart';
import 'package:api/price_list/model.dart';
import 'package:customer/pages/home.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final cartStateNotifier = StateNotifierProvider<Cart, List<Product>>((ref) => Cart(ref));

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
    final index = state.indexWhere((element) => element.productId == id);
    if (index > -1) {
      state.removeAt(index);
      state = [...state];
    }
  }

  Discount discount(String id) {
    if (state.where((element) => element.productId == id).isEmpty) return const Discount();
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
    // if (state.isEmpty) return 0;
    // int total = 0;
    // for (var product in state.toSet()) {
    //   final uniqueLength = state.where((element) => element.productId == product.productId).length;
    //   final priceList = product.kPrice(customer.business?.priceList.id);
    //   priceList.discount.sort((a, b) => a.min.compareTo(b.min));
    //   Discount theDiscount;
    //   if (uniqueLength > (priceList.discount.last.max ?? 0)) {
    //     theDiscount = priceList.discount.last;
    //   } else {
    //     theDiscount = discount(product.productId);
    //   }
    //   final max = theDiscount.max ?? 0;
    //   final discountPrice = priceList.price - theDiscount.discount;
    //   if (uniqueLength > max) {
    //     final productDiscount = max * discountPrice;
    //     final productNotDiscount = (uniqueLength - max) * priceList.price;
    //     total += productDiscount + productNotDiscount;
    //   } else {
    //     total += discountPrice * uniqueLength;
    //   }
    // }
    // return total;
    if (state.isEmpty) return 0;
    final result = state.map((e) {
      double disc = discount(e.productId).discount;
      return e.kPrice(customer.business?.priceList.id).price - disc;
    }).reduce((value, element) => value + element);
    return result;
  }
}
