// wheelchair_access_page.dart
import 'package:flutter/material.dart';
import 'capacity_page.dart';

class WheelChairAccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wheelchair Access")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Does the bus have wheelchair access?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Pass "Yes" to CapacityPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CapacityPage(wheelchairAccess: "Yes"),
                      ),
                    );
                  },
                  child: Text("Yes"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Pass "No" to CapacityPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CapacityPage(wheelchairAccess: "No"),
                      ),
                    );
                  },
                  child: Text("No"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
