import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSelectionScreen extends StatefulWidget {
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;

  Future<void> _initializeLocation() async {
    Location location = new Location();
    LocationData locationData = await location.getLocation();

    setState(() {
      selectedLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
  }

  void _confirmLocation() {
    if (selectedLocation != null) {
      Navigator.pop(context, selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecciona ubicación"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: selectedLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: selectedLocation!,
                zoom: 15,
              ),
              markers: selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId("selectedLocation"),
                        position: selectedLocation!,
                      ),
                    }
                  : {},
              onTap: _onMapTapped,
            ),
    );
  }
}
