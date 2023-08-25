import 'package:api/api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/main_controller.dart';
import 'package:sales/presentation/pages/product/provider/product_provider.dart';

class ModelBusinessDetail extends Equatable {
  final Apply? apply;
  final Customer customer;

  const ModelBusinessDetail({this.apply, required this.customer});

  ModelBusinessDetail copyWith({Apply? apply, Customer? customer}) =>
      ModelBusinessDetail(
          apply: apply ?? this.apply, customer: customer ?? this.customer);

  @override
  List<Object?> get props => [apply, customer];
}

final businessDetailProvider = StateNotifierProvider.autoDispose<
    BusinessDetailState,
    AsyncValue<ModelBusinessDetail>>((ref) => BusinessDetailState(ref));

class BusinessDetailState
    extends StateNotifier<AsyncValue<ModelBusinessDetail>> {
  BusinessDetailState(this.ref) : super(const AsyncValue.loading()) {
    final customer = ref.watch(customerStateProvider);
    init(customer);
  }

  final AutoDisposeRef ref;

  init(Customer customer) async {
    state = await AsyncValue.guard(() async {
      if (customer.business != null) {
        final res = await ref.read(apiProvider).customer.byId(customer.id);
        customer = res;
        return ModelBusinessDetail(apply: null, customer: res);
      }
      final result = await ref.read(apiProvider).apply.byId(customer.id);
      if (result.id.isEmpty) {
        return ModelBusinessDetail(apply: null, customer: customer);
      }
      return ModelBusinessDetail(apply: result, customer: customer);
    });
  }
}
