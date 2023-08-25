import 'package:api/api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final modelTrackingProvider = FutureProvider.autoDispose.family<Direction, ModelTracking>((ref, arg) async {
  final result =
      await ref.read(apiProvider).maps.directions(oriLatLng: '${arg.courierLat},${arg.courierLng}', desLatLng: '${arg.cusLat},${arg.cusLng}');
  return result.first;
});

class MyBitmap {
  final BitmapDescriptor customer;
  final BitmapDescriptor courier;

  MyBitmap(this.customer, this.courier);
}

final streamTrackingProvider = StreamProvider.family<ModelTracking, String>((ref, deliveryId) {
  return FirebaseFirestore.instance.doc('tracking/$deliveryId').snapshots().map((event) => ModelTracking.fromMap(event.data() ?? {}));
});

final bitmapProvider = FutureProvider.autoDispose<MyBitmap>((ref) async {
  final courier = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/car.png',
  );
  final customer = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(100, 100)),
    'assets/customer.png',
  );
  return MyBitmap(customer, courier);
});

class PageTracking extends ConsumerWidget {
  final Delivery arg;
  const PageTracking({super.key, required this.arg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(streamTrackingProvider(arg.id));
    final bitmap = ref.watch(bitmapProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Pengantaran'),
      ),
      body: stream.when(
        data: (data) {
          final future = ref.watch(modelTrackingProvider(data));

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(data.courierLat, data.courierLng),
              zoom: 12,
            ),
            markers: bitmap.when(
              data: (icon) => {
                Marker(
                  markerId: const MarkerId('courier'),
                  icon: icon.courier,
                  position: LatLng(data.courierLat, data.courierLng),
                  rotation: data.heading,
                ),
                Marker(
                  markerId: const MarkerId('customer'),
                  icon: icon.customer,
                  position: LatLng(data.cusLat, data.cusLng),
                ),
              },
              error: (error, stackTrace) => {},
              loading: () => {},
            ),
            polylines: data.overviewPolyline.isEmpty
                ? future.when(
                    data: (p) => {
                      Polyline(
                          polylineId: const PolylineId('tracking'),
                          color: Colors.orange,
                          width: 5,
                          points: decodePolyline(p.overviewPolyline).map((e) => LatLng(e.first.toDouble(), e.last.toDouble())).toList())
                    },
                    error: (error, stackTrace) => {},
                    loading: () => {},
                  )
                : {
                    Polyline(
                        polylineId: const PolylineId('tracking'),
                        color: Colors.orange,
                        width: 5,
                        points: decodePolyline(data.overviewPolyline).map((e) => LatLng(e.first.toDouble(), e.last.toDouble())).toList())
                  },
          );
        },
        error: (error, stackTrace) {
          return Center(child: Text('$error'));
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
