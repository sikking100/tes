import 'dart:async';
import 'dart:developer';

import 'package:api/api.dart';
import 'package:common/constant/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sales/config/app_assets.dart';
import 'package:sales/presentation/pages/maps/provider/maps_provider.dart';
import 'package:sales/presentation/widgets/app_button_widget.dart';
import 'package:sales/presentation/widgets/shimmer/app_shimmer.dart';

class MapsPage extends ConsumerWidget {
  const MapsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latLngWatch = ref.watch(latLngProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: latLngWatch == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: size.width),
                Lottie.asset(
                  AppAssets.animLocLoad,
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ref.read(latLngProvider.notifier).getLatLng();
                  },
                  child: const Text('Muat Ulang'),
                ),
              ],
            )
          : _Mapsview(
              title: title,
              initialPosition: latLngWatch,
            ),
    );
  }
}

class _Mapsview extends StatefulWidget {
  const _Mapsview({
    Key? key,
    required this.initialPosition,
    required this.title,
  }) : super(key: key);

  final LatLng initialPosition;
  final String title;

  @override
  State<_Mapsview> createState() => _MapsviewState();
}

class _MapsviewState extends State<_Mapsview>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  late LatLng _currentPosition;
  late CameraPosition _initPosition;

  double _posisionedBottom = -1000;
  bool _onCameraMove = false;
  String _address = '';

  late GoogleMapController _mapsController;

  @override
  void initState() {
    setState(() {
      _initPosition = CameraPosition(
        target: LatLng(
          widget.initialPosition.latitude,
          widget.initialPosition.longitude,
        ),
        zoom: 20,
      );
      _currentPosition = _initPosition.target;
    });

    _lottieController = AnimationController(
      vsync: this,
    );

    _lottieController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        _lottieController.reset();
      }
    });

    Future.delayed(const Duration(milliseconds: 800)).then((value) {
      setState(() {
        _posisionedBottom = 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _mapsController = controller;
          },
          onCameraIdle: () async {
            final name = await getGeocoding(_currentPosition);
            setState(() {
              _address = name;
              _onCameraMove = false;
            });
          },
          onCameraMove: (position) {
            setState(() {
              _currentPosition = position.target;
              _onCameraMove = true;
            });
          },
          onTap: (pos) {
            _mapsController.animateCamera(
              CameraUpdate.newCameraPosition(CameraPosition(
                target: pos,
                zoom: 20,
              )),
            );
            setState(() {
              _currentPosition = pos;
              _onCameraMove = true;
            });
          },
        ),
        _back(),
        _search(_currentPosition),
        _locationPin(),
        _getInitLocation(),
        AnimatedPositioned(
          bottom: _posisionedBottom,
          duration: const Duration(milliseconds: 800),
          child: _bottomContainer(),
        ),
      ],
    );
  }

  Widget _locationPin() {
    if (_onCameraMove) {
      return Align(
        alignment: Alignment.center,
        child: Lottie.asset(
          AppAssets.animLocPin,
          animate: true,
          repeat: true,
          height: 68,
          width: 68,
          frameRate: FrameRate.max,
        ),
      );
    }

    return Align(
      child: Lottie.asset(
        AppAssets.animLocPin,
        animate: false,
        height: 68,
        width: 68,
        controller: _lottieController,
        onLoaded: (_) {
          Future.delayed(const Duration(milliseconds: 800)).then(
            (value) => _lottieController.reset(),
          );
        },
      ),
    );
  }

  Widget _back() {
    final theme = Theme.of(context);
    return Positioned(
      top: Dimens.px12,
      left: Dimens.px12,
      child: SafeArea(
        child: ClipOval(
          child: Material(
            color: theme.highlightColor.withOpacity(0.2),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.arrow_left_circle_fill),
            ),
          ),
        ),
      ),
    );
  }

  Widget _search(LatLng initialPosition) {
    final theme = Theme.of(context);
    return Positioned(
      top: Dimens.px12,
      right: Dimens.px12,
      child: SafeArea(
        child: ClipOval(
          child: Material(
            color: theme.highlightColor.withOpacity(0.2),
            child: IconButton(
              onPressed: () {
                _showAddressSearch(_initPosition.target);
              },
              icon: const Icon(Icons.search, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressSearch(LatLng initialPosition) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimens.px30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: Dimens.px16,
                            top: Dimens.px30,
                            right: Dimens.px16),
                        child: TextFormField(
                          onChanged: (value) {
                            ref.read(placeProvider.notifier).searchPlace(value);
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Cari Alamat',
                            prefixIcon: const Icon(
                              Icons.search_outlined,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimens.px30,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(
                              Dimens.px16,
                            ),
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final placeWatch = ref.watch(placeProvider);
                          if (placeWatch == []) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(Dimens.px16),
                                itemBuilder: (__, index) => ListTile(
                                  onTap: () async {
                                    await ref
                                        .read(placeDetail.notifier)
                                        .getPlaceDetail(
                                            placeWatch[index]!.id, ref);
                                    final placeDetailWatch =
                                        ref.watch(placeDetail);
                                    if (placeDetailWatch != null) {
                                      _mapsController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: LatLng(
                                              placeDetailWatch.lat,
                                              placeDetailWatch.lng,
                                            ),
                                            zoom: 20,
                                          ),
                                        ),
                                      );
                                    }
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                                  title: Text(placeWatch[index]!.description),
                                ),
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemCount: placeWatch.length,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _getInitLocation() {
    final theme = Theme.of(context);
    return Positioned(
      top: 64,
      right: Dimens.px12,
      child: SafeArea(
        child: ClipOval(
          child: Material(
            color: theme.highlightColor.withOpacity(0.2),
            child: IconButton(
              onPressed: () {
                _mapsController.animateCamera(
                  CameraUpdate.newCameraPosition(_initPosition),
                );
              },
              icon: Icon(Icons.my_location_rounded, color: theme.primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomContainer() {
    final size = MediaQuery.of(context).size;

    if (_onCameraMove) {
      return Container(
        padding: const EdgeInsets.all(Dimens.px12),
        width: size.width,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimens.px30),
            topRight: Radius.circular(Dimens.px30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: Dimens.px10),
            Text(
              widget.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimens.px30),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: Dimens.px12),
                const Flexible(child: AppShimmerMapAddress()),
              ],
            ),
            const SizedBox(height: Dimens.px30),
            const AppButtonDisable(title: 'Pilih'),
          ],
        ),
      );
    }
    if (_address == "Oops! alamat tidak ditemukan.") {
      return Container(
        padding: const EdgeInsets.all(Dimens.px12),
        width: size.width,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimens.px30),
            topRight: Radius.circular(Dimens.px30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: Dimens.px10),
            Text(
              widget.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimens.px30),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: Dimens.px12),
                Flexible(
                    child: Text(_address, style: theme.textTheme.bodyLarge)),
              ],
            ),
            const SizedBox(height: Dimens.px30),
            const AppButtonDisable(title: 'Pilih'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Dimens.px12),
      width: size.width,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.px30),
          topRight: Radius.circular(Dimens.px30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimens.px10),
          Text(
            widget.title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimens.px30),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: theme.primaryColor),
              const SizedBox(width: Dimens.px12),
              Flexible(
                  child: Text(_address, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: Dimens.px30),
          AppButtonPrimary(
            onPressed: () {
              final address = BusinessAddress(
                lngLat: [_currentPosition.longitude, _currentPosition.latitude],
                name: _address,
              );
              Navigator.pop(context, address);
            },
            title: 'Pilih',
          ),
        ],
      ),
    );
  }

  Future<String> getGeocoding(LatLng latLng) async {
    String address = '';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        address =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
      }
      return address;
    } catch (e) {
      log(e.toString());
      address = 'Oops! alamat tidak ditemukan.';
      return address;
    }
  }
}
