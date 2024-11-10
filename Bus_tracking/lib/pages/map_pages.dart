import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Import the Timer package

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Location locationController = Location();
  LatLng? currentP;
  bool permissionDenied = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Set<Marker> _markers = {};
  Map<String, Map<String, dynamic>> busData = {};

  // Variables for storing form data
  String selectedCapacity = 'Moderate';
  String selectedWheelchairAccess = 'No';
  TimeOfDay? selectedDepartureTime;

  bool isSharingLocation = false; // New flag to track sharing status
  String? documentId; // Variable to store the Firestore document ID

  Timer? _locationTimer; // Timer to update location every 5 seconds

  @override
  void initState() {
    super.initState();
    _initializeRealTimeTracking();
  }

  void _initializeRealTimeTracking() {
    // Listen for real-time updates from Firestore for bus locations
    firestore.collection('bus_details').snapshots().listen((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        _updateMarkerLocation(doc.id, doc['location']);
      }
    });
  }

  void _updateMarkerLocation(String docId, GeoPoint geoPoint) {
    final markerId = docId;
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(geoPoint.latitude, geoPoint.longitude),
      onTap: () => _showBusInfo(
          docId), // Calls the updated function to fetch data on tap
    );

    setState(() {
      _markers.removeWhere((m) =>
          m.markerId.value == markerId); // Remove existing marker with same ID
      _markers.add(marker); // Add the updated marker
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(10.4203732, -61.4654937),
                  zoom: 11,
                ),
                markers: _markers,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: permissionDenied
                    ? showPermissionDeniedDialog
                    : isSharingLocation
                        ? _stopSharingLocation // Call stop sharing if already sharing
                        : showInformationDialog, // Show info dialog if not sharing
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text(
                  isSharingLocation
                      ? 'Stop Sharing Location'
                      : 'Submit Bus Information',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showInformationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Bus Details"),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Capacity:', style: TextStyle(fontSize: 16)),
                    DropdownButton<String>(
                      value: selectedCapacity,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedCapacity = newValue!;
                        });
                      },
                      items: ['Full', 'Almost full', 'Moderate', 'Almost empty']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                    Text('Wheelchair Accessible:',
                        style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        Text('No', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: selectedWheelchairAccess == 'Yes',
                          onChanged: (bool value) {
                            setDialogState(() {
                              selectedWheelchairAccess = value ? 'Yes' : 'No';
                            });
                          },
                        ),
                        Text('Yes', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text('Departure Time:', style: TextStyle(fontSize: 16)),
                    ElevatedButton(
                      onPressed: () =>
                          _selectDepartureTime(context, setDialogState),
                      child: Text(selectedDepartureTime == null
                          ? 'Select Time'
                          : selectedDepartureTime!.format(context)),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitInformation(); // Call the submit function when dialog is closed
              },
              child: Text("Submit and Share Location"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDepartureTime(
      BuildContext context, StateSetter setDialogState) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDepartureTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedDepartureTime) {
      setDialogState(() {
        selectedDepartureTime = pickedTime;
      });
    }
  }

  void _submitInformation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          permissionDenied = true;
        });
        showPermissionDeniedDialog();
        return;
      }
    }

    LocationData locationData = await locationController.getLocation();
    GeoPoint geoPoint =
        GeoPoint(locationData.latitude!, locationData.longitude!);

    DocumentReference docRef = await firestore.collection('bus_details').add({
      'capacity': selectedCapacity,
      'wheelchair_access': selectedWheelchairAccess,
      'departure_time': selectedDepartureTime?.format(context),
      'location': geoPoint,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Store the document ID for deletion later
    documentId = docRef.id;
    _addMarker(docRef.id, geoPoint);

    setState(() {
      currentP = LatLng(locationData.latitude!, locationData.longitude!);
      isSharingLocation = true; // Set flag to true after sharing starts
    });

    // Start the timer to update the location every 5 seconds
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      LocationData locationData = await locationController.getLocation();
      GeoPoint geoPoint =
          GeoPoint(locationData.latitude!, locationData.longitude!);

      print(
          'Location updated: Latitude ${locationData.latitude}, Longitude ${locationData.longitude}');
      // Update Firestore with the new location
      await firestore.collection('bus_details').doc(documentId).update({
        'location': geoPoint,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Optionally, update the local marker as well
      _updateMarkerLocation(documentId!, geoPoint);
    });
  }

  void _stopSharingLocation() async {
    if (_locationTimer != null) {
      _locationTimer?.cancel(); // Stop the location updates
    }

    if (documentId != null) {
      // Delete the document from Firestore
      await firestore.collection('bus_details').doc(documentId).delete();
    }

    setState(() {
      _markers.clear(); // Clear markers when stopping location sharing
      isSharingLocation = false; // Reset the sharing flag
      documentId = null; // Clear the document ID
    });
  }

  void _addMarker(String docId, GeoPoint geoPoint) {
    final markerId = docId;
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(geoPoint.latitude, geoPoint.longitude),
      onTap: () => _showBusInfo(docId),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _showBusInfo(String docId) async {
    // Fetch the specific document data from Firestore
    DocumentSnapshot docSnapshot =
        await firestore.collection('bus_details').doc(docId).get();

    if (docSnapshot.exists) {
      // Extract information from the document
      Map<String, dynamic> busInfo = docSnapshot.data() as Map<String, dynamic>;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Bus Information",
                textAlign: TextAlign.center,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Capacity: ${busInfo['capacity']}"),
                Text(
                    "Wheelchair Access: ${busInfo['wheelchair_access'] == 'Yes' ? 'Yes' : 'No'}"),
                Text("Departure Time: ${busInfo['departure_time']}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    } else {
      print("Document with ID $docId does not exist in Firestore.");
    }
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Permission Denied"),
          content: Text(
              "Please enable location permissions to share your location."),
          actions: <Widget>[
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
