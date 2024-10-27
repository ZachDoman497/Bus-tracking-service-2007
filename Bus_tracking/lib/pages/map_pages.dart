import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Import Location package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'intro_page.dart'; // Import your IntroPage here
import 'location_shared.dart'; // Import your location shared page if needed

class MapPage extends StatefulWidget {
  final TimeOfDay? departureTime;
  final String wheelchairAccess;
  final String capacity;
  final LatLng userLocation; // Accept user location

  const MapPage({
    Key? key,
    this.departureTime,
    required this.wheelchairAccess,
    this.capacity = "Moderate",
    required this.userLocation,
  }) : super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Location locationController = Location(); // Location controller instance
  LatLng? currentP; // Current position of the user
  bool permissionDenied = false; // Flag to check if permission was denied
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Firestore instance
  Marker? locationMarker; // To hold the marker for the user's location
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _checkUserLocation();
  }

  void _checkUserLocation() {
    if (widget.userLocation.latitude != 10.4203732 ||
        widget.userLocation.longitude != -61.4654937) {
      locationMarker = Marker(
        markerId: MarkerId("userLocation"),
        position: widget.userLocation,
        onTap: _showBusDetails, // Show bus details when marker is tapped
      );
    }
  }

  void _showBusDetails() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bus Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                  "Departure Time: ${widget.departureTime?.format(context) ?? "N/A"}"),
              Text("Capacity: ${widget.capacity}"),
              Text("Wheelchair Access: ${widget.wheelchairAccess}"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context), // Close the bottom sheet
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
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
    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          locationMarker = Marker(
            markerId: MarkerId("userLocation"),
            position: currentP!,
          );
        });

        // Store the location data in Firestore as a GeoPoint
        GeoPoint geoPoint =
            GeoPoint(currentLocation.latitude!, currentLocation.longitude!);
        firestore.collection('locations').doc('OgjD7PxI7AWVyDQNTcTH').set({
          'LatLng': geoPoint,
          'timestamp': FieldValue.serverTimestamp(),
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
          content:
              Text("Please allow location access in your browser settings."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.userLocation, // Use the passed user location
              zoom: 11,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: locationMarker != null ? {locationMarker!} : {},
          ),
          Align(
            alignment:
                Alignment.bottomRight, // Aligns the button to the bottom right
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  0, 0, 20, 80), // Add some padding for spacing
              child: FloatingActionButton(
                onPressed: () {
                  // Check the user location and navigate accordingly
                  if (widget.userLocation.latitude == 10.4203732 &&
                      widget.userLocation.longitude == -61.4654937) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IntroPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SharingPage()),
                    );
                  }
                },
                child: Icon(Icons.my_location), // Target icon
              ),
            ),
          ),
        ],
      ),
    );
  }
}
