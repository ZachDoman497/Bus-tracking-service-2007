import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/map_pages.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:html' as html;
import 'package:flutter_application_1/pages/bus_ticket_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'UWI Bus Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 215, 30, 205)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> selectedStops = [];
  bool isMonitoring = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MapPage();

      case 1:
        page = BusTickets();

      case 2:
        page = Placeholder();

      case 3:
        page = Placeholder();

      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      bool isLargeScreen = constraints.maxWidth >= 600;

      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('UWI Bus Tracker'),
          actions: [
            IconButton(
              iconSize: 45.0,
              icon: Icon(Icons.notifications),
              onPressed: showNotificationDialog,
            ),
          ],
        ),
        drawer: isLargeScreen
            ? null
            : Drawer(
                child: SafeArea(
                  child: NavigationRail(
                    extended: true,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_business),
                        label: Text('Bus Tickets'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.report),
                        label: Text('Report'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.help),
                        label: Text('Help'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
        body: Stack(
          children: [
            Row(
              children: [
                if (isLargeScreen)
                  SafeArea(
                    child: NavigationRail(
                      extended: isLargeScreen,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.add_business),
                          label: Text('Bus Tickets'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.report),
                          label: Text('Report'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.help),
                          label: Text('Help'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void showNotificationDialog() {
    // Open the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Stops'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Iterate through all stops in stopCoordinates and create a CheckboxListTile for each
                ...stopCoordinates.keys.map((stop) {
                  return CheckboxListTile(
                    title: Text(stop),
                    // If the stop is in selectedStops, the box will be checked
                    value: selectedStops.contains(stop),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          // Add the stop to the selectedStops list if checkbox is checked
                          selectedStops.add(stop);
                        } else {
                          // Remove the stop from the selectedStops list if checkbox is unchecked
                          selectedStops.remove(stop);
                        }
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Timer? _monitoringTimer; // Store reference to the time

                if (selectedStops.isNotEmpty) {
                  _monitoringTimer =
                      Timer.periodic(Duration(seconds: 5), (Timer t) {
                    beginMonitoring(); // Call _monitorBuses every 5 seconds
                  });
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void beginMonitoring() {
    if (selectedStops.isNotEmpty) {
      setState(() {
        isMonitoring = true;
      });
      _requestNotificationPermission();
    }
  }

  void _requestNotificationPermission() {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        print('Notification permission granted.');
        _monitorBuses();
      } else {
        print('Notification permission denied.');
      }
    });
  }

  Set<String> notifiedBusStops = {}; // Track notified bus stops
  Timer? _clearNotifiedBusStopsTimer;

  void startClearNotifiedBusStopsTimer() {
    // Cancel any existing timer to avoid multiple timers running concurrently
    _clearNotifiedBusStopsTimer?.cancel();

    // Start a new 15-second timer
    _clearNotifiedBusStopsTimer = Timer(Duration(minutes: 30), () async {
      setState(() {
        notifiedBusStops.clear(); // Clear the set after 15 seconds
      });
      print("notifiedBusStops has been cleared.");
    });
  }

  Timer? _monitoringTimer; // Store reference to the timer

  void startMonitoring() {
    // Cancel any existing timer to avoid multiple timers running concurrently
    _monitoringTimer?.cancel();

    // Start a new periodic timer that calls _monitorBuses every 5 seconds
    _monitoringTimer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      _monitorBuses(); // Call _monitorBuses every 5 seconds
    });
  }

  void _monitorBuses() async {
    try {
      // Fetch all bus documents from Firestore
      QuerySnapshot snapshot = await firestore.collection('bus_details').get();

      for (var doc in snapshot.docs) {
        // Safely check if the document data is null
        var busData = doc.data() as Map<String, dynamic>?;

        if (busData == null) {
          print('No data found for bus document with ID: ${doc.id}');
          continue; // Skip this document if it has no data
        }

        // Safely extract bus information with null checks
        GeoPoint? geoPoint = busData['location']; // GeoPoint could be null

        String capacity = busData['capacity'] ??
            'Unknown'; // Default to 'Unknown' if capacity is null
        String wheelchairaccess = busData['wheelchair_access'] ??
            'Unknown'; // Default to 'Unknown' if departure_time is null
        String departureTime = busData['departure_time'] ??
            'Unknown'; // Default to 'Unknown' if departure_time is null

        Timestamp timestamp = busData['timestamp'] ??
            Timestamp
                .now(); // Using Timestamp if it's a Firestore Timestamp field
        String busId = doc.id;

        if (geoPoint != null) {
          // Extract latitude and longitude from GeoPoint
          LatLng busPosition = LatLng(geoPoint.latitude, geoPoint.longitude);
          print('bus id test $busId');
          print('Monitoring buses...');

          // Check proximity to selected stops
          for (String stop in selectedStops) {
            if (stopCoordinates.containsKey(stop)) {
              LatLng stopPosition = stopCoordinates[stop]!;
              double distance = _calculateDistance(busPosition, stopPosition);

              if (distance <= 0.1) {
                // 0.1 km = 100 meters
                // Check if notification has already been sent for this bus and stop
                String busStopKey = '$busId-$stop';
                if (!notifiedBusStops.contains(busStopKey)) {
                  // If no notification has been sent, send one
                  _sendNotification(busId, stopPosition, capacity,
                      wheelchairaccess, departureTime);

                  // Mark this bus-stop pair as notified
                  notifiedBusStops.add(busStopKey);
                }
              }
            }
          }
        } else {
          print('Location is missing for Bus ID: $busId');
        }
      }
    } catch (e) {
      print("Error monitoring buses: $e");
    }
  }

  double _calculateDistance(LatLng busPosition, LatLng stopPosition) {
    const double R = 6371; // Radius of Earth in kilometers
    double lat1 = busPosition.latitude;
    double lon1 = busPosition.longitude;
    double lat2 = stopPosition.latitude;
    double lon2 = stopPosition.longitude;

    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in kilometers
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  void _sendNotification(String busId, LatLng stopPosition, String capacity,
      String wheelchairaccess, String departureTime) {
    startClearNotifiedBusStopsTimer();
    // Find the stop name based on stopPosition
    String stopName = stopCoordinates.entries
        .firstWhere((entry) => entry.value == stopPosition,
            orElse: () => MapEntry('Unknown Stop', stopPosition))
        .key;

    html.Notification(
      'A bus is near $stopName',
      body: 'Capacity: $capacity\n'
          'Wheelchair Access: $wheelchairaccess\n'
          'Departure Time: $departureTime',
    );
  }
}

Map<String, LatLng> stopCoordinates = {
  'San Fernando Terminal': LatLng(10.6623435, -61.5086355),
  'Skinner Park': LatLng(10.484610, -61.322093),
  'Pleasantville': LatLng(10.2843, -61.4465),
  'Mon Repos': LatLng(10.2870, -61.4468),
  'San Fernando Technical Institute': LatLng(10.2907, -61.4456),
  'Gasparillo': LatLng(10.3119, -61.4444),
  'Claxton Bay': LatLng(10.3462, -61.4529),
  'Preysal': LatLng(10.3926, -61.4468),
  'Freeport': LatLng(10.4459, -61.4495),
  'Chaguanas': LatLng(10.5105, -61.4123),
  'Mount Hope': LatLng(10.6553, -61.5005),
  'WASA': LatLng(10.6667, -61.5076),
  'Curepe TML': LatLng(10.6679, -61.5078),
  'Curepe Terminal': LatLng(10.6606401, -61.5076074),
  'The UWI St. Augustine Campus': LatLng(10.6417, -61.3994),
};

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
