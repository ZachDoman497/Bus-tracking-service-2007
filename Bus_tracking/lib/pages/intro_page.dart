// intro_page.dart
import 'package:flutter/material.dart';
import 'on_bus_page.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Share Your Location")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sharing your location helps others know where the bus is."),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OnBusPage()),
                    );
                  },
                  child: Text("Share"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Return to home page
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
