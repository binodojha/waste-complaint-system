import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  //Accept the callback as the parameter
  final Function(String) onLocationSelected;
  // const Map({super.key, required this.onLocationSelected});
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
  LatLng mylatlong = LatLng(28.6852, 80.6216);
  String address = "Dhangadhi";

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
        setState(() {
          mylatlong =
              LatLng(locations.first.latitude, locations.first.longitude);
          address = widget.initialLocation!;
        });
      }
    } catch (e) {
      print('Error setting initial location: $e');
    }
  }

  setMarker(LatLng value) async {
    if (!widget.draggableMarker) return;
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
        zoom: 12,
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
    );
  }
}
