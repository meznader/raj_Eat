import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raj_eat/config/colors.dart';
import 'package:raj_eat/providers/check_out_provider.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CostomGoogleMap extends StatefulWidget {
  const CostomGoogleMap({super.key});

  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<CostomGoogleMap> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};

  static const LatLng _initialcameraposition = LatLng(36.8065, 10.1815);

  late GoogleMapController controller;
  final Location _location = Location();

  void _onMapCreated(GoogleMapController value) {
    controller = value;
    _location.onLocationChanged.listen((event) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: _initialcameraposition, zoom: 13),
        ),
      );
    });
  }

  LatLng? _currentP;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    CheckoutProvider checkoutProvider = Provider.of(context);
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _currentP == null
                  ? const Center(
                child: Text("Loading..."),
              )
                  : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _initialcameraposition,
                  zoom: 11.0,
                ),
                onTap: (LatLng latLng) {
                  _markers.add(Marker(markerId: const MarkerId('mark'), position: latLng));
                  setState(() {});
                },
                markers: Set<Marker>.of(_markers),
                mapType: MapType.normal,
              ),
             Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                      right: 60, left: 10, bottom: 40, top: 40),
                  child: MaterialButton(
                    onPressed: () async {
                      await _location.getLocation().then((value) {
                        setState(() {
                          checkoutProvider.updateLocation(value);
                        });
                      });
                      Navigator.of(context).pop();
                    },
                    color: primaryColor,
                    shape: const StadiumBorder(),
                    child: const Text("Set Location"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,

    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);

        });
      }
    });
  }
}
