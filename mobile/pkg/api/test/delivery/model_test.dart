// import 'dart:convert';

// import 'package:api/common.dart';
// import 'package:api/delivery/model.dart';
// import 'package:api/order/model.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../json_reader.dart';

// final tDelivery = Deliver(
//   courier: const Courier(id: 'string', imageUrl: 'string', name: 'string', phone: 'string', type: 0, url: 'string'),
//   deliveryQty: const [
//     DeliveryQty(
//       productId: 'string',
//       productQtyBroken: 0,
//       productQtyDeliver: 0,
//       warehouseAddress: Address(
//         lngLat: 'string',
//         name: 'string',
//       ),
//       warehouseId: 'string',
//       warehousePhone: 'string',
//       warehousePicName: 'string',
//     ),
//   ],
//   id: 'string',
//   note: 'string',
//   price: 0,
//   status: 0,
//   deliverAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
// );

// final tComplete = CompleteDelivery(note: 'string', products: {'id': 0, 'id2': 0, 'id3': 0});

// const tOrderProduct = OrderProduct(
//   additionalDisocunt: 0,
//   brandId: 'string',
//   brandName: 'string',
//   categoryId: 'string',
//   categoryName: 'string',
//   description: 'string',
//   discount: 0,
//   id: 'string',
//   imageUrl: 'string',
//   name: 'string',
//   point: 0.0,
//   price: 0,
//   qtyPurchase: 0,
//   qtyRecive: 0,
//   size: 'string',
// );

// final jDelivery = readJson('delivery/delivery.json');
// final jComplete = readJson('delivery/delivery_complete.json');
// final jOrderProduct = readJson('delivery/delivery_product.json');

// void main() {
//   group('Delivery model', () {
//     test('fromMap', () {
//       final result = Deliver.fromMap(jsonDecode(jDelivery));
//       expect(result, equals(tDelivery));
//     });

//     test('complete toMap', () {
//       final result = tComplete.toMap();
//       expect(result, equals(jsonDecode(jComplete)));
//     });

//     test('order product fromMap', () {
//       final result = OrderProduct.fromMap(jsonDecode(jOrderProduct)['data'][0]);
//       expect(result, equals(tOrderProduct));
//     });
//   });
// }
