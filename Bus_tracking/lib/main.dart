import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/map_pages.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialWheelchairAccess;
  final String? initialCapacity;
  final TimeOfDay? initialDepartureTime;

  const MyHomePage({
    Key? key,
    this.initialLocation,
    this.initialWheelchairAccess,
    this.initialCapacity,
    this.initialDepartureTime,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MapPage(
          userLocation:
              widget.initialLocation ?? LatLng(10.4203732, -61.4654937),
          wheelchairAccess: widget.initialWheelchairAccess ?? 'null',
          capacity: widget.initialCapacity ?? 'Moderate',
          departureTime: widget.initialDepartureTime,
        );
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      bool isLargeScreen = constraints.maxWidth >= 600;

      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('UWI Bus Tracker'),
          leading: isLargeScreen
              ? null
              : IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
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
        body: Row(
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
      );
    });
  }
}
