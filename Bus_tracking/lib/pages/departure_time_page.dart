import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DepartureTimePage extends StatefulWidget {
  final String capacity;
  final String wheelchairAccess;

  const DepartureTimePage({
    Key? key,
    required this.capacity,
    required this.wheelchairAccess,
  }) : super(key: key);

  @override
  _DepartureTimePageState createState() => _DepartureTimePageState();
}

class _DepartureTimePageState extends State<DepartureTimePage> {
  TimeOfDay? selectedTime;
  final Location locationController = Location();

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _requestLocationPermissionAndSubmit() async {
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
        return;
      }
    }

    LocationData locationData = await locationController.getLocation();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          initialLocation: LatLng(
            locationData.latitude!,
            locationData.longitude!,
          ),
          initialWheelchairAccess: widget.wheelchairAccess,
          initialCapacity: widget.capacity,
          initialDepartureTime: selectedTime,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Departure Time")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedTime != null
                  ? "Selected Time: ${selectedTime!.format(context)}"
                  : "No time selected",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text("Select Departure Time"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestLocationPermissionAndSubmit,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
