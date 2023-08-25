// import 'package:api/api.dart';
// import 'package:api/common.dart';
// import 'package:firebase_auth/firebase_auth.dart' as f;
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:http/http.dart';
// import 'package:mockito/mockito.dart';

// @GenerateMocks([Client])
// final Map<String, dynamic> jsonError = {'message': 'message', 'data': null};

// String test200(String name) => 'should return $name when the result code is 200';
// String testNot200(int code) => 'should throw string error when the result code is $code';
// String testNot200String(String code) => 'should throw string error when the result code is $code';

// class MockUser extends Mock implements f.User {
//   @override
//   Future<String> getIdToken([bool forceRefresh = false]) {
//     return Future.value(
//         'eyJhbGciOiJSUzI1NiIsImtpZCI6ImY1NWU0ZDkxOGE0ODY0YWQxMzUxMDViYmRjMDEwYWY5Njc5YzM0MTMiLCJ0eXAiOiJKV1QifQ.eyJicmFuY2hJZCI6W10sInBob25lIjoiKzYyODUyMTM5Nzg0NjgiLCJyZWdpb25JZCI6W10sInJvbGVzIjowLCJ0ZWFtIjowLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZGFpcnktZm9vZC1kZXZlbG9wbWVudCIsImF1ZCI6ImRhaXJ5LWZvb2QtZGV2ZWxvcG1lbnQiLCJhdXRoX3RpbWUiOjE2NzM4NjI0MDIsInVzZXJfaWQiOiJDMTUwOTAxMTY2OTI1NjA0NjQ5MjEiLCJzdWIiOiJDMTUwOTAxMTY2OTI1NjA0NjQ5MjEiLCJpYXQiOjE2NzM4OTEwNzAsImV4cCI6MTY3Mzg5NDY3MCwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6e30sInNpZ25faW5fcHJvdmlkZXIiOiJjdXN0b20ifX0.Mow7_v3S8atCtI6BGwPjhmvmY2mCYJFwZxc8sWo_yWvORwG_CE62gZ7G9rHKYmU6-rM0MPr-QhjShNmkgzsfDADBcAdgDb354cvGDmLJ0z-_MLHTNtub6GfTf2cQ3hoyhkaUdhKLl7Z9ETQdeUh1-1JGAQF6ivI8XJzBEfeyOf8L94H_G9ieg5rbihMupBT-AOVBToYxegfOPAUzT0M_besVriV6bRpUawU_0Wb6xuTiO6bob1fMPxqBvH3MjFuXGuuAKV4nalWjyzu5sTpTX_0M6sabWRR61clrn1P1CPgr39ezT3E2Nwj6OleJb6-UECNeJzD7st4sTAiazd71mQ');
//   }
// }

// class MockAuth extends Mock implements f.FirebaseAuth {
//   @override
//   f.User? get currentUser => MockUser();
// }

// void main() {
//   test('Api', () {
//     final Api api = Api(MockAuth());
//     expect(api.activity, isA<ActivityRepo>());
//     expect(api.banner, isA<BannerRepo>());
//     expect(api.branch, isA<BranchRepo>());
//     expect(api.brand, isA<BrandRepo>());
//     expect(api.category, isA<CategoryRepo>());
//     expect(api.delivery, isA<DeliveryRepo>());
//     expect(api.invoice, isA<InvoiceRepo>());
//     expect(api.order, isA<OrderRepo>());
//     expect(api.price, isA<PriceRepo>());
//     expect(api.product, isA<ProductRepo>());
//     expect(api.recipe, isA<RecipeRepo>());
//     expect(api.region, isA<RegionRepo>());
//     expect(api.report, isA<ReportRepo>());
//   });

//   test('tes category price by branc', () async {
//     final auth = MockAuth();
//     final client = Client();
//     final repo = OrderRepoImpl(client, auth);

//     final result = await repo.all(qtype: Type.qCreateorPending, qvalue: 'SALES001');
//     print(result);
//   });
// }
