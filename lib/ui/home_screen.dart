import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'HOme';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    var Usermarker = Marker(
      markerId: MarkerId("UserMarker"),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLong),
    );
    markers.add(Usermarker);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  } //AIzaSyDyzqZ4YE_WxIzvX0FAqAXRf9jtjwRhyqk

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS'),
      ),
      body: GoogleMap(
        onLongPress: (argument) {
          var marker = Marker(
            markerId: MarkerId("marker$counter"),
            position: argument,
          );
          markers.add(marker);
          counter++;
          setState(() {});
        },
        mapType: MapType.hybrid,
        initialCameraPosition:
            CurrentLocation == null ? _kGooglePlex : CurrentLocation!,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Location location = Location();
  CameraPosition? CurrentLocation;
  PermissionStatus? permissionStatus;
  bool serviceEnabled = false;
  double defLat = 37.42796133580664;
  double defLong = -122.085749655962;
  Set<Marker> markers = {};
  late StreamSubscription<LocationData> streamSubscription;
  LocationData? locationData;

  void getCurrentLocation() async {
    bool hasPermission = await isPermissionGranted();
    if (!hasPermission) return;
    bool hasService = await isServiceEnabled();
    if (!hasService) return;

    locationData = await location.getLocation();

    //print("My Location lat : ${locationData?.latitude} long: ${locationData?.longitude}");
    CurrentLocation = CameraPosition(
        target: LatLng(locationData!.latitude!, locationData!.longitude!),
        zoom: 19.151926040649414);

    streamSubscription = location.onLocationChanged.listen((event) {
      locationData = event;
      print(
          "My Location lat : ${locationData?.latitude} long: ${locationData?.longitude}");
      var Usermarker = Marker(
        markerId: MarkerId("UserMarker"),
        position: LatLng(locationData?.latitude ?? defLat,
            locationData?.longitude ?? defLong),
      );
      markers.add(Usermarker);
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CurrentLocation!));
    setState(() {});
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CurrentLocation!));
  }

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
      return serviceEnabled;
    } else {
      return serviceEnabled;
    }
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    } else {
      return permissionStatus == PermissionStatus.granted;
    }
  }
}
