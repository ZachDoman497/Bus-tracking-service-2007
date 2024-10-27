import 'package:flutter/material.dart';
import 'departure_time_page.dart';

class CapacityPage extends StatelessWidget {
  final String wheelchairAccess; // Accept wheelchair access response

  const CapacityPage({Key? key, required this.wheelchairAccess})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Capacity")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What is the capacity of the bus?"),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartureTimePage(
                            capacity: "Full",
                            wheelchairAccess: wheelchairAccess),
                      ),
                    );
                  },
                  child: Text("Full"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartureTimePage(
                            capacity: "Almost Full",
                            wheelchairAccess: wheelchairAccess),
                      ),
                    );
                  },
                  child: Text("Almost Full"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartureTimePage(
                            capacity: "Moderate",
                            wheelchairAccess: wheelchairAccess),
                      ),
                    );
                  },
                  child: Text("Moderate"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartureTimePage(
                            capacity: "Almost Empty",
                            wheelchairAccess: wheelchairAccess),
                      ),
                    );
                  },
                  child: Text("Almost Empty"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartureTimePage(
                            capacity: "Empty",
                            wheelchairAccess: wheelchairAccess),
                      ),
                    );
                  },
                  child: Text("Empty"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
