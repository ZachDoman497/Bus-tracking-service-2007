import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Location locationController = Location();
  LatLng? currentP;
  bool permissionDenied = false; // Flag to check if permission was denied
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // **Created Firestore instance**

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(10.4203732, -61.4654937),
              zoom: 11,
            ),
            markers: {
              if (currentP != null)
                Marker(markerId: MarkerId("currentLocation"), position: currentP!),
            },
          ),
          Align(
            alignment: Alignment.bottomRight, // Aligns the button to the top left
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1,1,1,110), // Add some padding for spacing
              child: FloatingActionButton(
                onPressed: permissionDenied ? showPermissionDeniedDialog : getLocationUpdates,
                child: Icon(Icons.my_location),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return; // Exit if service is not enabled
      }
    }

    // Check for location permission
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await locationController.requestPermission();

      // If permission is denied or denied forever, show dialog and set the denied flag
      if (permissionGranted == PermissionStatus.denied || 
          permissionGranted == PermissionStatus.deniedForever) {
        setState(() {
          permissionDenied = true; // Set the flag so we don't ask again
        });
        showPermissionDeniedDialog();
        return; // Exit early
      }
    }

    // Reset the permissionDenied flag when permission is granted
    setState(() {
      permissionDenied = false;
    });

    // Now we are sure that the service is enabled and permission is granted
    locationController.onLocationChanged.listen((LocationData currentLocation) async {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(currentP);
        });

        // **Store the location data in Firestore as a GeoPoint**
        GeoPoint geoPoint = GeoPoint(currentLocation.latitude!, currentLocation.longitude!); // **Create GeoPoint**

        await firestore.collection('locations').doc('OgjD7PxI7AWVyDQNTcTH').set({
          'LatLng': geoPoint, // **Store GeoPoint instead of separate latitude and longitude**
          'timestamp': FieldValue.serverTimestamp(), // **Store the timestamp**
        });
      }
    });
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Denied"),
          content: Text("Please allow location access in your browser settings."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
