import 'dart:developer';

import 'package:api/maps/model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sales/main_controller.dart';

final latLngProvider =
    StateNotifierProvider.autoDispose<MapsNotifier, LatLng?>((ref) {
  return MapsNotifier(ref);
});

class MapsNotifier extends StateNotifier<LatLng?> {
  MapsNotifier(ref) : super(null) {
    getLatLng();
  }
  Future<void> getLatLng() async {
    try {
      final Location location = Location();
      final locationResult = await location.getLocation();
      final latLng =
          LatLng(locationResult.latitude!, locationResult.longitude!);
      state = latLng;
      return;
    } on PlatformException catch (e) {
      log(e.message.toString());
      throw e.message.toString();
    }
  }
}

final placeProvider =
    StateNotifierProvider.autoDispose<PlaceNotifier, List<Place?>>((ref) {
  return PlaceNotifier(ref);
});

class PlaceNotifier extends StateNotifier<List<Place?>> {
  PlaceNotifier(this.ref) : super([]);

  late AutoDisposeRef ref;

  Future<void> searchPlace(String name) async {
    if (name.length > 3) {
      try {
        final api = ref.watch(apiProvider);
        final res = await api.maps.finds(name);
        state = res;
        return;
      } catch (e) {
        state = [const Place("id", "Oops! alamat tidak ditemukan")];
        return;
      }
    }
  }
}

final placeDetail =
    StateNotifierProvider<PlaceDetailNotifier, PlaceDetail?>((ref) {
  return PlaceDetailNotifier();
});

class PlaceDetailNotifier extends StateNotifier<PlaceDetail?> {
  PlaceDetailNotifier() : super(null);

  Future<void> getPlaceDetail(String id, WidgetRef ref) async {
    try {
      final api = ref.watch(apiProvider);
      final res = await api.maps.find(id);
      log(res.toString());
      state = res;
      return;
    } catch (e) {
      log(e.toString());
      state = null;
      return;
    }
  }
}
