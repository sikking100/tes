// import 'dart:convert';

// import 'package:api/maps/repo.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart';
// import 'package:mockito/mockito.dart';

// import '../api_test.dart';
// import '../api_test.mocks.dart';
// import 'model_test.dart';

// void main() {
//   late MockClient client;
//   late MapsRepo repo;

//   setUp(() {
//     client = MockClient();
//     repo = MapsRepoImpl(client);
//   });

//   group('Maps Repo', () {
//     group('finds', () {
//       test(test200('Place'), () async {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/autocomplete/json', {'input': 'string', 'key': searchKey})))
//             .thenAnswer((_) async => Response(jPlace, 200));

//         final result = await repo.finds('string');

//         expect(result, equals([tPlace]));
//       });

//       test(testNot200String('ZERO_RESULTS'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/autocomplete/json', {'input': 'string', 'key': searchKey})))
//             .thenAnswer((_) async => Response(jsonEncode({"predictions": [], "status": "ZERO_RESULTS"}), 200));

//         final result = repo.finds('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Tidak ada data. ')));
//       });
//     });

//     group('find', () {
//       test(test200('PlaceDetail'), () async {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jPlaceDetail, 200));

//         final result = await repo.find('string');

//         expect(result, equals(tPlaceDetail));
//       });

//       test(testNot200String('ZERO_RESULTS'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "ZERO_RESULTS"}), 200));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Tidak ada data. ')));
//       });

//       test(testNot200String('INVALID_REQUEST'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "INVALID_REQUEST"}), 200));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Input tidak valid, pastikan semua inputan sudah benar. ')));
//       });

//       test(testNot200String('OVER_QUERY_LIMIT'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "OVER_QUERY_LIMIT"}), 200));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Sistem sedang sibuk, silakan coba beberapa saat lagi. ')));
//       });

//       test(testNot200String('REQUEST_DENIED'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "REQUEST_DENIED"}), 200));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Permintaan ditolak. ')));
//       });
//       test(testNot200String('UNKNOWN_ERROR'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "UNKNOWN_ERROR"}), 200));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Terjadi kesalahan, silakan coba beberapa saat lagi. ')));
//       });

//       test(testNot200String('default'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
//           'place_id': 'string',
//           'fields': 'formatted_address,name,geometry',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "default"}), 200));

//         final result = repo.find('string');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });

//     group('direcation', () {
//       test(test200('List Of Direction'), () async {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jDirection, 200));

//         final result = await repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(result, equals([tDirection]));
//       });

//       test(testNot200String('ZERO_RESULTS'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "ZERO_RESULTS"}), 200));

//         final result = repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Tidak ada data. ')));
//       });

//       test(testNot200String('INVALID_REQUEST'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "INVALID_REQUEST"}), 200));

//         final result = repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Input tidak valid, pastikan semua inputan sudah benar. ')));
//       });

//       test(testNot200String('OVER_QUERY_LIMIT'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "OVER_QUERY_LIMIT"}), 200));

//         final result = repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Sistem sedang sibuk, silakan coba beberapa saat lagi. ')));
//       });

//       test(testNot200String('REQUEST_DENIED'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "REQUEST_DENIED"}), 200));

//         final result = repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Permintaan ditolak. ')));
//       });
//       test(testNot200String('UNKNOWN_ERROR'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "UNKNOWN_ERROR"}), 200));

//         final result = repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(() => result, throwsA(isA<String>()));
//         expect(() => result, throwsA(equals('Terjadi kesalahan, silakan coba beberapa saat lagi. ')));
//       });

//       test(testNot200String('default'), () {
//         when(client.get(Uri.https('maps.googleapis.com', 'maps/api/directions/json', {
//           'destination': '0.0,0.0',
//           'origin': '0.0,0.0',
//           'language': 'id',
//           'alternatives': 'true',
//           'avoid': '',
//           'key': searchKey
//         }))).thenAnswer((_) async => Response(jsonEncode({"html_attributions": [], "result": {}, "status": "default"}), 200));

//         final result = repo.directions(oriLatLng: '0.0,0.0', desLatLng: '0.0,0.0');

//         expect(() => result, throwsA(isA<String>()));
//       });
//     });
//   });
// }
