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
    showDialog(
      context: context,
      barrierDismissible: true, // Allows tapping outside to dismiss
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            // Dismiss dialog when tapping outside
            Navigator.of(context).pop();
          },
          child: WillPopScope(
            onWillPop: () async {
              // Allow back navigation
              return true;
            },
            child: AlertDialog(
              title: const Text('Select Stops'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stopCoordinates.keys.map((stop) {
                    return CheckboxListTile(
                      title: Text(stop),
                      value: selectedStops.contains(stop),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedStops
                                .add(stop); // Add stop to the selected stops
                          } else {
                            selectedStops.remove(
                                stop); // Remove stop from the selected stops
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    // Start monitoring after the "Submit" button is pressed
                    if (selectedStops.isNotEmpty) {
                      _monitoringTimer =
                          Timer.periodic(Duration(seconds: 5), (Timer t) {
                        beginMonitoring();
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
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
          print('$timestamp');
          // Check proximity to selected stops
          for (String stop in selectedStops) {
            if (stopCoordinates.containsKey(stop)) {
              LatLng stopPosition = stopCoordinates[stop]!;
              double distance = _calculateDistance(busPosition, stopPosition);

              if (distance <= 1) {
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
  'San Fernando Terminal': LatLng(10.283636641282095, -61.468293973896834),
  'Skinner Park': LatLng(10.266362580449908, -61.46269418938906),
  'Pleasantville': LatLng(10.270515402223923, -61.455563772018294),
  'Mon Repos': LatLng(10.27933085037673, -61.44783628399069),
  'San Fernando Technical Institute':
      LatLng(10.290749968131781, -61.4399564881722),
  'Gasparillo': LatLng(10.315527141658691, -61.431574976417274),
  'Claxton Bay': LatLng(10.366337692296643, -61.42320697369503),
  'Preysal': LatLng(10.41785614724562, -61.41715760229082),
  'Freeport': LatLng(10.460592061486595, -61.41065536393663),
  'Chaguanas': LatLng(10.515293334140432, -61.40802185557044),
  'Mount Hope': LatLng(10.650215602739129, -61.424693660508304),
  'WASA': LatLng(10.651229117569864, -61.419143656872485),
  'Curepe Terminal': LatLng(10.649894269876095, -61.41016550215149),
  'The UWI St. Augustine Campus':
      LatLng(10.644778345612824, -61.399909971872724),
};

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
