import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/map_pages.dart';
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 215, 30, 205)),
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

  // Create a GlobalKey to control the Scaffold's state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MapPage();

      case 1:
        page = Placeholder();

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
        key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
        appBar: AppBar(
          title: Text('UWI Bus Tracker'),
          leading: isLargeScreen
              ? null
              : IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer(); // Open the drawer using GlobalKey
                  },
                ),
        ),
        drawer: isLargeScreen
            ? null
            : Drawer(
                child: SafeArea(
                  child: NavigationRail(
                    extended: true, // Always extended in the Drawer for small screens
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
                      Navigator.pop(context); // Close the drawer on selection
                    },
                  ),
                ),
              ),
        body: Row(
          children: [
            if (isLargeScreen)
              SafeArea(
                child: NavigationRail(
                  extended: isLargeScreen, // Only extend on large screens
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