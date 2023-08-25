// import 'dart:convert';

// import 'package:api/invoice/model.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../json_reader.dart';

// final tInvoice = Invoice(
//   amount: 0,
//   expiredAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   paidAt: DateTime.parse("2022-12-28T14:32:08.633Z").toLocal(),
//   id: 'string',
//   message: 'string',
//   paymentChannel: 'string',
//   paymentDestination: 'string',
//   paymentMethod: 'string',
//   status: 0,
// );

// final tCreate = CreateInvoice(orderId: 'string', amount: 0);

// final jInvoice = readJson('invoice/invoice.json');
// final jCreateInvoice = readJson('invoice/invoice_create.json');

// void main() {
//   group('Invoice model', () {
//     test('fromMap', () {
//       final result = Invoice.fromMap(jsonDecode(jInvoice));
//       expect(result, equals(tInvoice));
//     });

//     test('reqInvoice toMap', () {
//       final result = tCreate.toMap();
//       expect(result, equals(jsonDecode(jCreateInvoice)));
//     });
//   });
// }
