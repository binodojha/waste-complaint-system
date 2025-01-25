import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  //Accept the callback as the parameter
  final Function(String) onLocationSelected;
  const Map({super.key, required this.onLocationSelected});
  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng mylatlong = LatLng(28.6852, 80.6216);
  String address = "Dhangadhi";

  setMarker(LatLng value) async {
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
          draggable: true,
          onDragEnd: (value) {
            setMarker(value);
          },
        ),
      },
      onTap: (value) {
        setMarker(value);
      },
    );
  }
}
