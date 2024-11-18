import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'dart:html';

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
    Set<Polyline> _polylines = {};
    String selectedCapacity = 'Moderate';
    String selectedWheelchairAccess = 'No';
    TimeOfDay? selectedDepartureTime = TimeOfDay(hour: 9, minute: 0);
    bool isSharingLocation = false;
    String? documentId;
    Timer? _locationTimer;
    static double minLat = 10.236324341653932;
    static double maxLat = 10.651843368801126;
    static double minLong = -61.47365576757059;
    static double maxLong = -61.3716931241147;
    String? userId;
  
  final List<LatLng> routeStops = [
    LatLng(10.283636641282095, -61.468293973896834), // San Fernando Terminal

    LatLng(10.283538449409988, -61.46830438578212),
    LatLng(10.283560817836255, -61.46846352105889),
    LatLng(10.282515092201193, -61.46875053290637),

    LatLng(10.282215913372625, -61.468861359266505),
    LatLng(10.281578409880959, -61.46925067236121),
    LatLng(10.27939187494313, -61.471310905944165),
    LatLng(10.279126246272957, -61.47145299101271),

    LatLng(10.278838248612454, -61.471512666741496),
    LatLng(10.278374096493401, -61.47151550843942),
    LatLng(10.2778148761666, -61.4714188905878),

    LatLng(10.27114956340049, -61.46922043005624),
    LatLng(10.27067225248922, -61.46920131343891),
    LatLng(10.2701737792385, -61.46918219682882),
    LatLng(10.268556524438594, -61.46863292511264),

    LatLng(10.268232166692021, -61.46845673960881),
    LatLng(10.26785747717013, -61.46814983586078),
    LatLng(10.267591838807343, -61.467817356800396),

    LatLng(10.267303830639406, -61.467303008820416),
    LatLng(10.26678094135522, -61.46516889101298),

    LatLng(10.266543264121395, -61.46454371667608),
    LatLng(10.266344733593836, -61.46399242661016),
    LatLng(10.266783737551291, -61.463912858971774),

    LatLng(10.266385011469136, -61.46218307546875), // Skinner Park

    LatLng(10.266262996780519, -61.46178389807265),
    LatLng(10.265781505530663, -61.46049041134256),
    LatLng(10.265464243449058, -61.45962176479223),
    LatLng(10.265546358370035, -61.45945486327868),

    LatLng(10.266154754630305, -61.459557280116535),
    LatLng(10.266783842321715, -61.4595644996049),
    LatLng(10.26803999006468, -61.45965471797956),

    LatLng(10.268159834286358, -61.458391660459554),
    LatLng(10.268057744765272, -61.456880502335274),

    LatLng(10.26829299447762, -61.45655120519614),
    LatLng(10.268337381207912, -61.45651511783842),
    LatLng(10.269265062212888, -61.456285060923264),
    LatLng(10.270515402223923, -61.455563772018294), // Pleasantville
    LatLng(10.271020029772789, -61.45514182114348),
    LatLng(10.276543184912555, -61.4494174964299),

    LatLng(10.277131052400785, -61.448921107360796),
    LatLng(10.277709338773395, -61.44853473848809),
    LatLng(10.278319751011392, -61.44819734596535),

    LatLng(10.27933085037673, -61.44783628399069), // Mon Repos

    LatLng(10.279883689296774, -61.447751437755066),
    LatLng(10.28018353900618, -61.44787115768249),

    LatLng(10.280408426101449, -61.447762321384836),
    LatLng(10.280906389826686, -61.44761539238108),
    LatLng(10.282544845561231, -61.44790380857778),

    LatLng(10.283064223548148, -61.44793645947431),

    LatLng(10.28417793840467, -61.44778953047056),
    LatLng(10.285414799832754, -61.44738139434367),

    LatLng(10.286585521531967, -61.44698141681673),
    LatLng(10.28898209959513, -61.446136067723145),
    LatLng(10.289943930094083, -61.44584069242793),

    LatLng(10.290831219931297, -61.4457973119406),

    LatLng(10.290957686241963, -61.44596393004433),
    LatLng(10.291154411505158, -61.44594488797437),

    LatLng(10.291229354430298, -61.4457544672748),
    LatLng(10.29107478462768, -61.44557356761022),
    LatLng(10.291196566902746, -61.44497374240659),

    LatLng(10.290840587814044,
        -61.44015609854938), // San Fernando Technical Institute

    LatLng(10.29074222510474, -61.43947534449412),

    LatLng(10.29034877393905, -61.438361383346994),
    LatLng(10.290404981278078, -61.43815668109495),

    LatLng(10.290582971118946, -61.437999584017824),
    LatLng(10.291346452733919, -61.43714269083768),
    LatLng(10.29474594611, -61.43503160478408),
    LatLng(10.296197968984591, -61.43437834511059),

    LatLng(10.297793827680119, -61.4339059752504),
    LatLng(10.298857056407536, -61.433767920239106),

    LatLng(10.309729398664405, -61.43294570119035),
    LatLng(10.310900310881093, -61.43291237756551),

    LatLng(10.311434245407748, -61.43285525135227),
    LatLng(10.312277298071653, -61.43263150702692),
    LatLng(10.313918256300841, -61.43197724040799),
    LatLng(10.314541173834755, -61.431934395750595),

    LatLng(10.315527141658691, -61.431574976417274), // Gasparillo

    LatLng(10.316413576735867, -61.43091097950294),
    LatLng(10.318177006191764, -61.43034999594168),

    LatLng(10.323222947303517, -61.42996333450235),
    LatLng(10.329199641416695, -61.43034440300163),

    LatLng(10.341273692193532, -61.43205554013215),
    LatLng(10.345936630505735, -61.43230882093171),
    LatLng(10.348274887392884, -61.432319219234124),
    LatLng(10.353490420079572, -61.43204959936183),

    LatLng(10.356237065071348, -61.43139227540598),
    LatLng(10.357868430309923, -61.43059625007492),
    LatLng(10.359100113237309, -61.42972128029228),
    LatLng(10.364475549184927, -61.42460452225378),
    LatLng(10.36514587538267, -61.42426681454438),

    LatLng(10.366337692296643, -61.42320697369503), // claxton bay

    LatLng(10.36665818813525, -61.422891338616616),
    LatLng(10.367141331883868, -61.42203576669028),

    LatLng(10.368567380903203, -61.421037599356524),
    LatLng(10.370055763908884, -61.420538515722896),
    LatLng(10.375223727278719, -61.42039106259475),
    LatLng(10.376353628196036, -61.42020093550034),
    LatLng(10.384487084702748, -61.41763091776937),

    LatLng(10.384931898986958, -61.41746002771357),
    LatLng(10.393577598098078, -61.41626454709428),
    LatLng(10.394736213375744, -61.41616913121276),
    LatLng(10.4132700650031, -61.41707394474782),
    LatLng(10.413893933016672, -61.41755154740377),

    LatLng(10.41420953635985, -61.418469440016864),
    LatLng(10.415002213101754, -61.418879879816906),
    LatLng(10.415780208690204, -61.41923061927531),
    LatLng(10.416117828809615, -61.41905898081201),

    LatLng(10.415949018805426, -61.418641078483944),
    LatLng(10.416565541920761, -61.41752915978171),

    LatLng(10.41785614724562, -61.41715760229082), // Preysal

    LatLng(10.418334369256257, -61.41653664173996),
    LatLng(10.419376578177873, -61.41577546249613),

    LatLng(10.428298288277169, -61.413171589479504),
    LatLng(10.447579426254993, -61.41084325129907),
    LatLng(10.450953693992833, -61.41056211844158),
    LatLng(10.459423849056904, -61.41051107934139),

    LatLng(10.460592061486595, -61.41065536393663), // Freeport

    LatLng(10.46176596836045, -61.410645530322775),
    LatLng(10.463127657818013, -61.41026479166359),
    LatLng(10.464191307266486, -61.40978169267009),

    LatLng(10.470556444007629, -61.40594023593889),
    LatLng(10.47240740881364, -61.4051719445931),
    LatLng(10.47429613701939, -61.40481660984552),

    LatLng(10.475901546953143, -61.404768591636106),
    LatLng(10.512582094106813, -61.4075255920574),
    LatLng(10.513654745545125, -61.40783986189108),

    LatLng(10.515293334140432, -61.40802185557044), // Chaguanas

    LatLng(10.51631378670676, -61.407823569128105),
    LatLng(10.519649435941245, -61.40811207283588),

    LatLng(10.521536308332461, -61.40842157869408),
    LatLng(10.61162828254427, -61.42425079055426),
    LatLng(10.61195812175266, -61.424324209700316),
    LatLng(10.621444453209689, -61.427840358936756),
    LatLng(10.622613052843086, -61.42811940370112),

    LatLng(10.628730241102588, -61.428798816963685),
    LatLng(10.629958433696507, -61.4289808026501),
    LatLng(10.630661959267167, -61.42921131785289),
    LatLng(10.631508572666489, -61.42949036259536),

    LatLng(10.6369101492204, -61.43124955764823),
    LatLng(10.637829410233822, -61.43142328175792),
    LatLng(10.641453179888453, -61.431128005214575),
    LatLng(10.641951640796266, -61.43097845100104),

    LatLng(10.642807969149645, -61.430399741236236),
    LatLng(10.643855913772548, -61.42896651689763),
    LatLng(10.64394538046552, -61.42890799568693),
    LatLng(10.644143485192236, -61.428784450908786),
    LatLng(10.644098751878108, -61.42857637549296),
    LatLng(10.645600509573516, -61.42658665427862),
    LatLng(10.645990326312756, -61.42630055058188),
    LatLng(10.646405704293576, -61.42615099635684),
    LatLng(10.648839181042835, -61.42559473439378),
    LatLng(10.648963646450495, -61.42557037929152),
    LatLng(10.649887269839388, -61.42562944935876),

    LatLng(10.650215602739129, -61.424693660508304), // Mount Hope
    LatLng(10.651229117569864, -61.419143656872485), // WASA
    LatLng(10.65163737482498, -61.41688806204902),
    LatLng(10.65151076909091, -61.415284900573084),
    LatLng(10.651285692100432, -61.41398233187389),
    LatLng(10.649894269876095, -61.41016550215149), // Curepe Terminal
    LatLng(10.647999394465788, -61.40584338578394), //test
    LatLng(10.64747941101955, -61.40520373264287), // test 2
    LatLng(10.646816861128263, -61.404588590801644),
    LatLng(10.645687290166283, -61.40385800297523), //test 3
    LatLng(10.645398201157368, -61.40141066955223), //test 4
    LatLng(10.644818896095092, -61.40149405543516), //test 5
    LatLng(10.644773049858022, -61.40054725059592),
    LatLng(10.644614604984717, -61.40038252662922),
    LatLng(10.64462046441406, -61.40010704773899), // test 6
    LatLng(10.643960157896306, -61.40005307869582),
    LatLng(10.643843046163848, -61.400007516747586),
    LatLng(10.643686462277167, -61.39979675270385),
    LatLng(10.643693497466154, -61.39953666599724),
    LatLng(10.64491996293649, -61.39953189375455),
    LatLng(10.644866026700466, -61.39974903036283),
    LatLng(10.644778345612824,
        -61.399909971872724), // The UWI St. Augustine Campus
  ];

  @override
  void initState() {
    super.initState();
    _initializeRealTimeTracking();
    initializeUserId(); 
    _createRoutePolyline();
  }

  void _createRoutePolyline() {
    Polyline routePolyline = Polyline(
      polylineId: PolylineId("routePolyline"),
      color: Colors.blue,
      width: 5,
      points: routeStops,
    );

    setState(() {
      _polylines.add(routePolyline);
    });
  }

  bool isLocationValid(GeoPoint geoPoint, Map<String, GeoPoint> locations) {
  // Check if location is within the valid geofencing area
  if (geoPoint.latitude < minLat || geoPoint.latitude > maxLat || 
      geoPoint.longitude < minLong || geoPoint.longitude > maxLong) {
    return false;
  }

  // Calculate the average location of existing locations
  GeoPoint averageLocation = calculateAverageLocation(locations);

  // Check if the new location is too far from the average location
  double distance = calculateDistance(geoPoint, averageLocation);

  // Define a threshold for valid distance (e.g., 100 meters)
  return distance < 100; 
}


void initializeUserId() {
  // Try retrieving the existing user ID
  userId = window.localStorage['userId'];

  // Generate a new UUID if no ID exists
  if (userId == null) {
    var uuid = Uuid();
    userId = uuid.v4(); // Generate a unique ID
    window.localStorage['userId'] = userId!; // Save to local storage
  }

  print('User ID initialized: $userId');
}

GeoPoint calculateAverageLocation(Map<String, GeoPoint> locations) {
  double totalLatitude = 0;
  double totalLongitude = 0;
  int count = locations.length;

  locations.forEach((userId, geoPoint) {
    totalLatitude += geoPoint.latitude;
    totalLongitude += geoPoint.longitude;
  });

  double averageLatitude = totalLatitude / count;
  double averageLongitude = totalLongitude / count;

  return GeoPoint(averageLatitude, averageLongitude);
}

double calculateDistance(GeoPoint point1, GeoPoint point2) {
  double distance = Geolocator.distanceBetween(
    point1.latitude, point1.longitude,
    point2.latitude, point2.longitude,
  );
  return distance; // Distance in meters
}

void _initializeRealTimeTracking() {
  firestore.collection('bus_details').snapshots().listen((querySnapshot) {
    for (var change in querySnapshot.docChanges) {
      if (change.type == DocumentChangeType.added || 
          change.type == DocumentChangeType.modified) {
        // Handle added or modified documents
        var doc = change.doc;
        if (doc['average_location'] != null) {
          GeoPoint averageGeoPoint = doc['average_location'];

          print("Average GeoPoint for doc ${doc.id}: ${averageGeoPoint.latitude}, ${averageGeoPoint.longitude}");

          _updateMarkerLocation(doc.id, averageGeoPoint);
        } else {
          print("No average_location found in doc ${doc.id}");
        }
      } else if (change.type == DocumentChangeType.removed) {
        // Handle deleted documents
        String docId = change.doc.id;

        // Remove the marker for the deleted document
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == docId);
        });

        print("Marker removed for docId: $docId");
      }
    }
  });
}

  void _updateMarkerLocation(String docId, GeoPoint geoPoint) {
    final markerId = docId;
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(geoPoint.latitude, geoPoint.longitude),
      onTap: () => _showBusInfo(docId),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == markerId);
      _markers.add(marker);
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
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: permissionDenied
                    ? showPermissionDeniedDialog
                    : isSharingLocation
                        ? _stopSharingLocation
                        : showInformationDialog,
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
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitInformation();
              },
              child: Text("Submit and Share Location"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> handleSubmission(
    int departureTime,
    GeoPoint geoPoint,
    String selectedCapacity,
    String selectedWheelchairAccess,
    String userId,
) async {
  try {
    // Query Firestore for an existing document with the same departure_time
    QuerySnapshot querySnapshot = await firestore
        .collection('bus_details')
        .where('departure_time', isEqualTo: departureTime)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If a matching document exists, update it
      DocumentSnapshot existingDoc = querySnapshot.docs.first;

      // Retrieve the locations map from the existing document
      Map<String, GeoPoint> locations = Map.from(existingDoc['locations']);

      // Validate the new location before adding it
      if (isLocationValid(geoPoint, locations)) {
        // Add the new location to the locations map
        locations[userId] = geoPoint;  // Add or update the user's location

        // Calculate the average location after adding the new location
        GeoPoint averageLocation = calculateAverageLocation(locations);

        // Update Firestore with the new location and average location
        await firestore.collection('bus_details').doc(existingDoc.id).update({
          'capacity': selectedCapacity,
          'wheelchair_access': selectedWheelchairAccess,
          'departure_time': departureTime,
          'locations.$userId': geoPoint, // Update the user's specific location
          'average_location': averageLocation, // Update the average location
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Return the document ID of the updated document
        return existingDoc.id;
      } else {
        // Reject submission if the location is invalid
        print('New location is too far from the average or outside the valid area.');
        return null;
      }
    } else {
      // If no matching document exists, create a new one
      DocumentReference newDocRef =
          await firestore.collection('bus_details').add({
        'capacity': selectedCapacity,
        'wheelchair_access': selectedWheelchairAccess,
        'departure_time': departureTime,
        'locations': {userId: geoPoint}, // Store the user's location
        'average_location': geoPoint, // Store the initial average location (just the first user's)
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Return the document ID of the new document
      return newDocRef.id;
    }
  } catch (e) {
    print('Error handling submission: $e');
    return null; // Return null if an error occurs
  }
}



  Future<void> _selectDepartureTime(
    BuildContext context, StateSetter setDialogState) async {
  // Show the time picker dialog
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: selectedDepartureTime ?? TimeOfDay.now(),
  );

  // Validate the picked time
  if (pickedTime != null) {
    int hour = pickedTime.hour;

    // Check if the selected time is within the allowed range (5 AM to 7 PM)
    if (hour >= 5 && hour <= 19) {
      // Round to the nearest hour
      setDialogState(() {
        selectedDepartureTime = TimeOfDay(hour: hour, minute: 0);
      });
    } else {
      // Notify user of invalid selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time between 5 AM and 7 PM.'),
        ),
      );
    }
  }
}


  void _submitInformation() async {
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  // Check and request location service
  serviceEnabled = await locationController.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await locationController.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  // Check and request location permissions
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

  // Get user's current location
  LocationData locationData = await locationController.getLocation();
  GeoPoint geoPoint = GeoPoint(locationData.latitude!, locationData.longitude!);

  String? userId = window.localStorage['userId'];

  if (userId == null) {
    // Handle error: userId should always exist at this point
    print('Error: userId is null');
    return;
  }

  // Query Firestore for an existing document with the same departure_time
  String? docId = await handleSubmission(
    selectedDepartureTime!.hour,
    geoPoint,
    selectedCapacity,
    selectedWheelchairAccess,
    userId,
  );

  if (docId != null) {
    // Assign the document ID to the global variable
    setState(() {
      documentId = docId; // Ensure documentId is assigned
    });

    // Add marker for the returned document ID
    _addMarker(docId, geoPoint);

    setState(() {
      currentP = LatLng(locationData.latitude!, locationData.longitude!);
      isSharingLocation = true;
    });

    // Start location updates
    _startLocationUpdates();
  } else {
    print("Error: Document ID is null.");
  }
}

void _startLocationUpdates() {
  if (documentId == null) {
    print("Error: documentId is not set. Cannot start location updates.");
    return;
  }

  _locationTimer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
    try {
      // Get the current location of the user
      LocationData locationData = await locationController.getLocation();
      GeoPoint geoPoint = GeoPoint(locationData.latitude!, locationData.longitude!);

      print('Location updated: Latitude ${locationData.latitude}, Longitude ${locationData.longitude}');

      // Update Firestore with the new location for this user
      await firestore.collection('bus_details').doc(documentId).update({
        'locations.$userId': geoPoint,  // Update the user's location in the locations map
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch the latest locations from Firestore and calculate the new average
      DocumentSnapshot docSnapshot = await firestore.collection('bus_details').doc(documentId).get();
      if (docSnapshot.exists && docSnapshot['locations'] != null) {
        Map<String, GeoPoint> locations = Map.from(docSnapshot['locations']);
        GeoPoint averageLocation = calculateAverageLocation(locations);

        // Update Firestore with the new average location
        await firestore.collection('bus_details').doc(documentId).update({
          'average_location': averageLocation,
        });

        // Update the marker with the average location
        _updateMarkerLocation(documentId!, averageLocation);
      }
    } catch (e) {
      print("Error in periodic location update: $e");
    }
  });
}



  void _stopSharingLocation() async {
    _locationTimer?.cancel();
    if (documentId != null) {
      await firestore.collection('bus_details').doc(documentId).delete();
    }

    setState(() {
      _markers.clear();
      isSharingLocation = false;
      documentId = null;
    });
  }

  String formatHourToTimeString(int hour) {
  // Convert 24-hour clock to 12-hour clock
  final isPM = hour >= 12;
  final formattedHour = (hour % 12 == 0) ? 12 : hour % 12; // 0 and 12 both map to 12
  final period = isPM ? "PM" : "AM";

  return "$formattedHour:00 $period";
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
  DocumentSnapshot docSnapshot =
      await firestore.collection('bus_details').doc(docId).get();
  if (docSnapshot.exists) {
    Map<String, dynamic> busInfo = docSnapshot.data() as Map<String, dynamic>;

    // Convert the stored departure time (integer) to a readable string
    String formattedTime = busInfo['departure_time'] != null
        ? formatHourToTimeString(busInfo['departure_time'])
        : 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("Bus Information")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Capacity: ${busInfo['capacity']}"),
              Text(
                  "Wheelchair Access: ${busInfo['wheelchair_access'] == 'Yes' ? 'Yes' : 'No'}"),
              Text("Departure Time: $formattedTime"),
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
  }
}


  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Denied"),
          content: Text(
              "Location permissions are required to share your location. Please enable permissions."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}