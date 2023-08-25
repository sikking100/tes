import 'package:api/api.dart';
import 'package:api/price_list/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader/main_controller.dart';
import 'package:leader/pages/page_home.dart';

final doubleProvider = StateProvider<Map<String, double>>((ref) {
  return {};
});

// final cartStateNotifierProvider = StateNotifierProvider<CartsNotifier, List<OrderProduct>>((_) {
//   return CartsNotifier();
// });

// class CartsNotifier extends StateNotifier<List<OrderProduct>> {
//   CartsNotifier() : super([]);

//   void add(Price p, {int? qty}) {
//     if (state.map((e) => e.id).contains(p.product.id)) {
//       ('di atas');

//       state = [
//         for (var pro in state)
//           if (pro.id == p.product.id) pro.copyWith(qty: qty ?? pro.qty + 1) else pro
//       ];
//     } else {
//       ('di bawah');
//       state = [...state, p.toOrderProduct(1, 0)];
//     }
//     (state);
//     return;
//   }

//   void rem(String id) {
//     if (state.firstWhere((element) => element.id == id).qty > 1) {
//       state = [
//         for (var pro in state)
//           if (pro.id == id) pro.copyWith(qty: pro.qty - 1) else pro
//       ];
//     } else {
//       final index = state.indexWhere((element) => element.id == id);
//       if (index > -1) {
//         // if (ref.read(doubleProvider).containsKey(id)) {
//         //   ref.read(doubleProvider.notifier).state.remove(id);
//         // }
//         state.removeAt(index);
//         state = [...state];
//       }
//     }
//   }
// }

final cartStateNotifier = StateNotifierProvider<Cart, List<Product>>(
  (ref) => Cart(ref),
);

class Cart extends StateNotifier<List<Product>> {
  Cart(this.ref) : super([]) {
    customer = ref.watch(customerStateProvider);
    employee = ref.watch(employeeStateProvider);
  }

  final Ref ref;
  late Customer customer;
  late Employee employee;

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

  double additional(double dis, String id) {
    final total = state.firstWhere((element) => element.productId == id);
    final result = total.price.first.price * dis / 100;
    return result;
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
      double add = additional((ref.read(doubleProvider)[e.productId] ?? 0), e.productId);
      double disc = discount(e.productId).discount;
      final price = e.kPrice(customer.business?.priceList.id).price;
      return price - disc - add;
    }).reduce((value, element) => value + element);
    return result;
  }

  int min(String id) {
    if (state.where((element) => element.id == id).isEmpty) return 0;
    final price = state.firstWhere((e) => e.id == id);
    final uniqueLength = state.where((element) => element.id == id).toList().length;

    final discount = price.price.first;
    int d = 0;
    if (discount.discount.isEmpty) {
      return d;
    }
    for (var dis in discount.discount) {
      final max = dis.max;
      if (max == null && uniqueLength >= dis.min) {
        d = dis.min;
        break;
      }
      if (max != null && uniqueLength >= dis.min && uniqueLength <= max) {
        d = dis.min;
        break;
      }
    }
    return d;
  }
}
