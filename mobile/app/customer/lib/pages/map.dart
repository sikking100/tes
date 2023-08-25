import 'dart:async';

import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:customer/main_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/argument.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:common/common.dart';

final latLngStateNotifierProvider = StateNotifierProvider.family.autoDispose<LatLngNotifier, AsyncValue<LatLng>, BusinessAddress?>((ref, arg) {
  return LatLngNotifier(arg, ref);
});

final textEditingController = Provider.autoDispose<TextEditingController>((_) => TextEditingController());

final textSearchController = Provider.autoDispose<TextEditingController>((_) => TextEditingController());

class LatLngNotifier extends StateNotifier<AsyncValue<LatLng>> {
  LatLngNotifier(BusinessAddress? address, this.ref) : super(const AsyncValue.loading()) {
    if (address != null) {
      state = AsyncValue.data(LatLng(address.lat, address.lng));
      ref.read(textEditingController).text = address.name;
      return;
    } else {
      init();
    }
  }

  final AutoDisposeRef ref;

  void init() async {
    state = await AsyncValue.guard(() async {
      final defLoc = await ref.watch(locationProvider.future);
      final lat = defLoc.latitude;
      final lng = defLoc.longitude;
      if (lat != null && lng != null) {
        await getData(LatLng(lat, lng));
        return LatLng(lat, lng);
      }
      return const LatLng(0.0, 0.0);
    });
  }

  void update(LatLng latLng) {
    state = AsyncValue.data(latLng);
  }

  Future getData(LatLng latLng) async {
    final result = await placemarkFromCoordinates(latLng.latitude, latLng.longitude, localeIdentifier: 'id_ID');
    (result);

    final res =
        '${result.first.street}, ${result.first.subLocality}, ${result.first.locality}, ${result.first.subAdministrativeArea}, ${result.first.administrativeArea}, ${result.first.postalCode}, ${result.first.country}';
    ref.read(textEditingController).text = res;
    ref.read(cameraMoveProvider.notifier).update((state) => false);

    return;
  }
}

final cameraMoveProvider = StateProvider<bool>((_) => false);

final searchState = StateProvider.autoDispose<String>((_) => '');

final suggestionState = StateNotifierProvider.autoDispose<SuggestionMap, AsyncValue<List<Place>>>((ref) => SuggestionMap(ref));

class SuggestionMap extends StateNotifier<AsyncValue<List<Place>>> {
  SuggestionMap(this.ref) : super(const AsyncValue.data([])) {
    init();
  }

  final AutoDisposeRef ref;

  void init() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final search = ref.watch(searchState);
      // (testt);
      return ref.read(apiProvider).maps.finds(search);
    });
    if (mounted) {
      state = result;
    }
  }

  Future<PlaceDetail> getDetails(String id) async {
    try {
      final result = await ref.read(apiProvider).maps.find(id);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

class PageMap extends HookConsumerWidget {
  final ArgMap? argument;
  PageMap({super.key, this.argument});
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latLngStateNotifierProvider(argument?.address));
    final cameraMove = ref.watch(cameraMoveProvider);
    final textEdit = ref.watch(textEditingController);
    final textSearch = ref.watch(textSearchController);
    final search = ref.watch(searchState);
    final loading = ref.watch(loadingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alamat'),
      ),
      body: state.when(
        data: (data) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(data.latitude, data.longitude), zoom: 14.0),
              onMapCreated: (c) => _controller.complete(c),
              trafficEnabled: false,
              indoorViewEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('MyPosition'),
                  position: LatLng(data.latitude, data.longitude),
                ),
              },
              onCameraIdle: () async {
                if (argument != null && cameraMove == false) return;
                if (cameraMove == true) {
                  await ref.read(latLngStateNotifierProvider(argument?.address).notifier).getData(data);
                }
              },
              onTap: (arg) {
                ref.read(cameraMoveProvider.notifier).update((state) => true);
                ref.read(latLngStateNotifierProvider(argument?.address).notifier).update(arg);
                ref.read(latLngStateNotifierProvider(argument?.address).notifier).getData(arg);
              },
              onCameraMove: (position) {
                ref.read(cameraMoveProvider.notifier).update((state) => true);
                ref.read(latLngStateNotifierProvider(argument?.address).notifier).update(position.target);
              },
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
            Positioned(
              top: 10,
              left: 10,
              right: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 85 / 100),
              child: TextField(
                controller: textSearch,
                style: Theme.of(context).brightness == Brightness.light ? null : const TextStyle(color: Colors.black),
                onChanged: (value) => ref.read(searchState.notifier).update((state) => value),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari Alamat',
                  suffixIcon: search.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            ref.invalidate(searchState);
                            ref.invalidate(textSearchController);
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            search.isNotEmpty
                ? Positioned(
                    top: 65,
                    left: 10,
                    right: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 85 / 100),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 30 / 100,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final result = ref.watch(suggestionState);
                          return result.when(
                            data: (data) {
                              if (data.isEmpty) return const Center(child: Text('Tidak ada data'));
                              return ListView.builder(
                                itemBuilder: (context, index) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(Dimens.px16),
                                  child: GestureDetector(
                                      onTap: () async {
                                        try {
                                          final res = await ref.watch(suggestionState.notifier).getDetails(data[index].id);
                                          ref.read(latLngStateNotifierProvider(argument?.address).notifier).update(LatLng(res.lat, res.lng));
                                          ref.read(textEditingController).text = res.address;
                                          ref.invalidate(searchState);
                                          final contr = await _controller.future;
                                          await contr.moveCamera(CameraUpdate.newLatLng(LatLng(res.lat, res.lng)));
                                          return;
                                        } catch (e) {
                                          Alerts.dialog(context, content: e.toString());
                                          return;
                                        }
                                      },
                                      child: Text(data[index].description)),
                                ),
                                itemCount: data.length,
                              );
                            },
                            error: (error, stackTrace) => Center(
                              child: Text('$error'),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(),
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.all(Dimens.px16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Alamat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    cameraMove
                        ? const LinearProgressIndicator()
                        : TextField(
                            controller: textEdit,
                            minLines: 3,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                          ),
                    const Divider(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fixedSize: Size(MediaQuery.of(context).size.width, 48),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                              if (MediaQuery.of(context).viewInsets.bottom > 0) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }

                              await _controller.future;

                              if (!_controller.isCompleted) return;

                              ref.read(loadingProvider.notifier).update((state) => true);

                              await Future.delayed(const Duration(seconds: 2));

                              ref.read(loadingProvider.notifier).update((state) => false);

                              final arg = argument;
                              if (arg != null) {
                                final act = arg.action;
                                if (act != null) {
                                  act(BusinessAddress(name: textEdit.text, lngLat: [data.longitude, data.latitude]));
                                }
                              }

                              if (context.mounted) {
                                Navigator.pop(
                                  context,
                                  BusinessAddress(name: textEdit.text, lngLat: [data.longitude, data.latitude]),
                                );
                              }
                            },
                      child: loading ? const BtnLoading() : const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => Center(
          child: Text('$error'),
        ),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
