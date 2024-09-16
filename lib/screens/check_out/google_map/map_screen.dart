import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  LatLng? _currentP;

  static const LatLng _initialCameraPosition = LatLng(36.8065, 10.1815);
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    _fetchUserAddressLocation();
  }

  Future<void> _fetchUserAddressLocation() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("AddDeliverAddress")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
        final latitude = data['latitude'] as double?;
        final longitude = data['longitude'] as double?;

        if (latitude != null && longitude != null) {
          final location = LatLng(latitude, longitude);
          setState(() {
            _currentP = location;
            _markers.add(Marker(
              markerId: const MarkerId('deliveryLocation'),
              position: location,
            ));
          });

          final GoogleMapController mapController = await _mapController.future;
          mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 13,
            ),
          ));
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching user address location: $e');
    }
  }

  void _onMapCreated(GoogleMapController value) {
    _mapController.complete(value);
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final newLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        setState(() {
          _currentP = newLocation;
          _markers.add(Marker(
            markerId: const MarkerId('currentLocation'),
            position: newLocation,
          ));
        });
        value.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newLocation,
            zoom: 13,
          ),
        ));
      }
    });
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
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                initialCameraPosition: CameraPosition(
                  target: _currentP!,
                  zoom: 11.0,
                ),
                onTap: (LatLng latLng) {
                  setState(() {
                    _markers.add(Marker(
                      markerId: MarkerId(latLng.toString()),
                      position: latLng,
                    ));
                  });
                },
                markers: _markers,
                mapType: MapType.normal,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.only(right: 60, left: 10, bottom: 40, top: 40),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: Colors.blue, // Replace with your `primaryColor`
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
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }
}
