import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  final Function(String) onLocationSelected;
  final String? initialLocation;
  final bool draggableMarker;
  const Map({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.draggableMarker = true,
  });

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  // Center of Dhangadhi
  LatLng mylatlong = LatLng(28.685244, 80.621591);
  String address = "Dhangadhi";

  // Define Dhangadhi boundaries (approximate)
  final LatLngBounds dhangadhiBounds = LatLngBounds(
    southwest: LatLng(28.6400, 80.5169),
    northeast: LatLng(28.7200, 80.6700),
  );

  bool isLocationWithinDhangadhi(LatLng position) {
    return position.latitude >= dhangadhiBounds.southwest.latitude &&
        position.latitude <= dhangadhiBounds.northeast.latitude &&
        position.longitude >= dhangadhiBounds.southwest.longitude &&
        position.longitude <= dhangadhiBounds.northeast.longitude;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _setInitialLocation();
    }
  }

  Future<void> _setInitialLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(widget.initialLocation!);
      if (locations.isNotEmpty) {
        final newLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        if (isLocationWithinDhangadhi(newLocation)) {
          setState(() {
            mylatlong = newLocation;
            address = widget.initialLocation!;
          });
        }
      }
    } catch (e) {
      print('Error setting initial location: $e');
    }
  }

  Future<void> setMarker(LatLng value) async {
    if (!widget.draggableMarker) return;

    if (!isLocationWithinDhangadhi(value)) {
      // Show error message using callback
      widget.onLocationSelected(
          "ERROR: Please select a location within Dhangadhi");
      return;
    }

    mylatlong = value;
    List<Placemark> result =
        await placemarkFromCoordinates(value.latitude, value.longitude);

    if (result.isNotEmpty) {
      address = '${result[0].name} ${result[0].locality}';
      setState(() {});
    }
    // call the callback function to pass the address to the parent widget
    widget.onLocationSelected(address);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: mylatlong,
        zoom: 13, // Increased zoom level for better view of Dhangadhi
      ),
      markers: {
        Marker(
          infoWindow: InfoWindow(title: address),
          markerId: MarkerId('1'),
          position: mylatlong,
          draggable: widget.draggableMarker,
          onDragEnd: widget.draggableMarker
              ? (value) {
                  setMarker(value);
                }
              : null,
        ),
      },
      onTap: widget.draggableMarker
          ? (value) {
              setMarker(value);
            }
          : null,
      // Add camera bounds
      cameraTargetBounds: CameraTargetBounds(dhangadhiBounds),
    );
  }
}
