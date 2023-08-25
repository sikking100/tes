// import 'dart:convert';

// import 'package:api/common.dart';
// import 'package:api/customer/model.dart';
// import 'package:api/order/model.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../delivery/model_test.dart';
// import '../invoice/model_test.dart';
// import '../json_reader.dart';

// const tOrderUser = OrderUser(
//   email: 'string',
//   id: 'string',
//   imageUrl: 'string',
//   name: 'string',
//   phone: 'string',
//   salesFood: OrderSales(
//     email: 'string',
//     id: 'string',
//     imageUrl: 'string',
//     name: 'string',
//     phone: 'string',
//   ),
//   salesRetail: OrderSales(
//     email: 'string',
//     id: 'string',
//     imageUrl: 'string',
//     name: 'string',
//     phone: 'string',
//   ),
// );

// final tOrder = Order(
//   id: "string",
//   approval: OrderApproval(
//     isAdditionalDiscount: true,
//     isOverDue: true,
//     isOverLimit: true,
//     user: [
//       OrderApprovalUser(
//         email: 'string',
//         id: 'string',
//         imageUrl: 'string',
//         name: 'string',
//         note: 'string',
//         phone: 'string',
//         roles: 0,
//         status: 0,
//         updatedAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//       ),
//     ],
//   ),
//   business: tOrderUser,
//   categoryPrice: const OrderCategoryPrice(
//     id: 'string',
//     branchId: 'string',
//     branchName: 'string',
//     name: 'string',
//     regionId: 'string',
//     regionName: 'string',
//     team: 1,
//   ),
//   createdBy: tOrderUser,
//   customer: tOrderUser,
//   deliver: [tDelivery],
//   deliverAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   deliveryAddress: const Address(lngLat: 'string', name: 'string'),
//   deliveryPrice: 0,
//   deliveryStatus: 0,
//   invoice: [tInvoice],
//   invoiceExpiredAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   invoiceStatus: 0,
//   paid: 0,
//   paymentMethod: 0,
//   price: 0,
//   product: const [tOrderProduct],
//   status: 0,
//   createdAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   updatedAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
// );

// final tpOrder = Paging<Order>(
//     const Item(
//       query: 'string',
//       type: 0,
//     ),
//     const Item(
//       query: 'string',
//       type: 0,
//     ),
//     [tOrder]);

// final tCreateOrder = CreateOrder(
//   approval: OrderApproval(
//     isAdditionalDiscount: true,
//     isOverDue: true,
//     isOverLimit: true,
//     user: [
//       OrderApprovalUser(
//         email: 'string',
//         id: 'string',
//         imageUrl: 'string',
//         name: 'string',
//         note: 'string',
//         phone: 'string',
//         roles: 0,
//         status: 0,
//         updatedAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//       ),
//     ],
//   ),
//   business: tOrderUser,
//   categoryPrice: const OrderCategoryPrice(
//     id: 'string',
//     branchId: 'string',
//     branchName: 'string',
//     name: 'string',
//     regionId: 'string',
//     regionName: 'string',
//     team: 1,
//   ),
//   createdBy: tOrderUser,
//   customer: tOrderUser,
//   deliverAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   deliveryPrice: 0,
//   invoiceExpiredAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   paymentMethod: 0,
//   price: 0,
//   product: const [tOrderProduct],
// );

// const tPerformance = Performance(
//   categoryId: 'string',
//   categoryName: 'string',
//   qty: 0,
// );

// const tApproval = CreateApproval();

// final jOrder = readJson('order/order.json');
// final jpOrder = readJson('order/orderPaging.json');
// final jReqCreate = readJson('order/reqCreate.json');
// final jPerformance = readJson('order/performance.json');
// final jApprovalCreate = readJson('order/approval_create.json');

// void main() {
//   group('Order model', () {
//     test('fromMap', () {
//       final result = Order.fromMap(jsonDecode(jOrder)["data"]);
//       expect(result, equals(tOrder));
//     });

//     test('create toMap', () {
//       final result = tCreateOrder.toMap();
//       expect(result, equals(jsonDecode(jReqCreate)));
//     });

//     test('performance fromMap', () {
//       final result = Performance.fromMap((jsonDecode(jPerformance)['data'] as List).first);
//       expect(result, equals(tPerformance));
//     });

//     test('approval toMap', () {
//       final result = tApproval.toMap();
//       expect(result, equals(jsonDecode(jApprovalCreate)));
//     });

//     test('order create copywith', () {
//       final result = tCreateOrder.copyWith();
//       expect(result, equals(tCreateOrder));
//     });

//     test('orderApproval copyWIth', () {
//       final result = tCreateOrder.approval.copyWith();
//       expect(result, equals(tCreateOrder.approval));
//     });

//     test('orderApprovalUser copyWIth', () {
//       final result = tCreateOrder.approval.user.first.copyWith();
//       expect(result, equals(tCreateOrder.approval.user.first));
//     });

//     test('orderUser copyWIth', () {
//       final result = tCreateOrder.customer?.copyWith();
//       expect(result, equals(tCreateOrder.customer));
//     });

//     test('orderSales copyWIth', () {
//       final result = tCreateOrder.customer?.salesFood?.copyWith();
//       expect(result, equals(tCreateOrder.customer?.salesFood));
//     });

//     test('orderCategoryPrice copyWIth', () {
//       final result = tCreateOrder.categoryPrice.copyWith();
//       expect(result, equals(tCreateOrder.categoryPrice));
//     });

//     test('orderProduct copyWIth', () {
//       final result = tCreateOrder.product.first.copyWith();
//       expect(result, equals(tCreateOrder.product.first));
//     });
//   });
// }
