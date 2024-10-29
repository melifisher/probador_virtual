import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Google Maps'),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 14.4746,
          ),
        ),
      );
    } else {
      // Muestra un mensaje o un marcador de posición en la web
      return Scaffold(
        appBar: AppBar(
          title: Text('Google Maps no disponible'),
        ),
        body: Center(
          child: Text('Esta funcionalidad no está disponible en la web'),
        ),
      );
    }
  }
}
