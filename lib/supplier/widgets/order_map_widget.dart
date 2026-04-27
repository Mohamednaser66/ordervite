import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderMapWidget extends StatelessWidget {
  final CameraPosition initialCamera;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(LatLng) onMapTapped;

  const OrderMapWidget({
    Key? key,
    required this.initialCamera,
    required this.markers,
    required this.polylines,
    required this.onMapTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      initialCameraPosition: initialCamera,
      markers: markers,
      polylines: polylines,
      onMapCreated: (controller) => controller,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      onTap: onMapTapped,
    );
  }
}