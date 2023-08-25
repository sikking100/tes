import 'dart:convert';

import 'package:api/maps/model.dart';
import 'package:http/http.dart';

const searchKey = 'AIzaSyB2dYC4zp81VaeR3uJ5-6ZZVFpkEeWMV-o';

class MapsResponse {
  final dynamic data;
  final String status;
  final String errorMessage;

  MapsResponse({required this.data, required this.status, required this.errorMessage});

  @override
  String toString() {
    switch (status) {
      case 'ZERO_RESULTS':
        return 'Tidak ada data. $errorMessage';
      case 'INVALID_REQUEST':
        return 'Input tidak valid, pastikan semua inputan sudah benar. $errorMessage';
      case 'OVER_QUERY_LIMIT':
        return 'Sistem sedang sibuk, silakan coba beberapa saat lagi. $errorMessage';
      case 'REQUEST_DENIED':
        return 'Permintaan ditolak. $errorMessage';
      case 'UNKNOWN_ERROR':
        return 'Terjadi kesalahan, silakan coba beberapa saat lagi. $errorMessage';
      default:
        return 'Terjadi kesalahan. $errorMessage';
    }
  }
}

abstract class MapsRepo {
  Future<List<Place>> finds(String name);
  Future<PlaceDetail> find(String id);
  Future<List<Direction>> directions({required String oriLatLng, required String desLatLng, bool? avoidTolls = false});
}

class MapsRepoImpl implements MapsRepo {
  final Client client;

  MapsRepoImpl(this.client);

  @override
  Future<PlaceDetail> find(String id) async {
    final response = await client.get(
      Uri.https(
        'maps.googleapis.com',
        'maps/api/place/details/json',
        {'place_id': id, 'fields': 'formatted_address,name,geometry', 'key': searchKey},
      ),
    );
    final decode = jsonDecode(response.body);
    final result = MapsResponse(data: decode['result'], status: decode['status'], errorMessage: decode['error_message'] ?? '');
    if (result.status == 'OK') return PlaceDetail.fromMap(result.data);
    throw result.toString();
  }

  @override
  Future<List<Place>> finds(String name) async {
    final response = await client.get(
      Uri.https(
        'maps.googleapis.com',
        'maps/api/place/autocomplete/json',
        {'input': name, 'key': searchKey},
      ),
    );
    final decode = jsonDecode(response.body);
    final result = MapsResponse(data: decode['predictions'], status: decode['status'], errorMessage: decode['error_message'] ?? '');
    if (result.status == 'OK') return List.from(result.data).map((e) => Place.fromMap(e)).toList();
    throw result.toString();
  }

  @override
  Future<List<Direction>> directions({required String oriLatLng, required String desLatLng, bool? avoidTolls = false}) async {
    final avoid = avoidTolls == true ? 'tolls' : '';
    final response = await client.get(
      Uri.https(
        'maps.googleapis.com',
        'maps/api/directions/json',
        {
          'destination': desLatLng,
          'origin': oriLatLng,
          'language': 'id',
          'alternatives': 'true',
          'avoid': avoid,
          'key': searchKey,
        },
      ),
    );
    final decode = jsonDecode(response.body);
    final result = MapsResponse(data: decode['routes'], status: decode['status'], errorMessage: decode['error_message'] ?? '');
    if (result.status == 'OK') return List<Direction>.from(result.data.map((e) => Direction.fromMap(e)));
    throw result.toString();
  }
}
