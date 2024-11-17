import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Help Page"),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("How to submit location?",
            style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text("Click 'submit bus location' on bottom of the home page. A pop-up appears where you enter the capacity of the bus and the departure time when the bus left the San Fernando Terminal. Select 'yes' or 'no' for wheel chair access. Click 'submit and Share Location'. A pop-up will appear at the top left of the screen. It will ask to allow or block the use of your location. Click 'allow'.",
            style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),
            Text("Where to buy Bus Tickets",
            style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text("Click bus tickets on the menu. The location of bus terminals and the UWI bookshop will be shown. " +
            "Tickets can be purchased at these locations.",
            style: TextStyle(fontSize: 16),
            ),
            
            SizedBox(height: 20),
            Text("Types of Buses",
            style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text("Each red marker on the map represents a bus travelling from the San Fernando Terminal to UWI Campass. " +
            "Click the red marker and bus information will be shown. This includes capacity, wheelchair access and departure time",
            style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),
            Text("Bugs and Errors",
            style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text("Bugs or error are to be reported on the report page of the menu. " +
            "Write a descriptive report of the bug or error experienced in the message field and click 'Submit Report'.",
            style: TextStyle(fontSize: 16),
            ),
          ],
        ),
       ),
      ),
    );
  }
}