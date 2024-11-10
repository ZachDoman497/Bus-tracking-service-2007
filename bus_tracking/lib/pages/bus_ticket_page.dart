import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusTickets extends StatefulWidget {
  const BusTickets({super.key});

  @override
  State<BusTickets> createState() => BusTicketsState();
}

class BusTicketsState extends State<BusTickets> {
  static const LatLng Area = LatLng(10.4203732, -61.4654937);
  static const LatLng SanFernandoTerminal =
      LatLng(10.283747195847697, -61.468306873025114);
  static const LatLng CurepeTerminal =
      LatLng(10.649978794473325, -61.41020473278368);
  static const LatLng ChaguanasTerminal =
      LatLng(10.51787412792931, -61.41437016382593);
  static const LatLng UwiBookshop =
      LatLng(10.64534959041072, -61.40197833285121);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: Area, zoom: 11),
        markers: {
          Marker(
            markerId: MarkerId("MarkerId"),
            position: SanFernandoTerminal,
            infoWindow: InfoWindow(
              title: "San Fernando Terminal",
            ),
          ),
          Marker(
            markerId: MarkerId("MarkerId2"),
            position: CurepeTerminal,
            infoWindow: InfoWindow(
              title: "Curepe Terminal",
            ),
          ),
          Marker(
            markerId: MarkerId("MarkerId3"),
            position: ChaguanasTerminal,
            infoWindow: InfoWindow(
              title: "Chaguanas Terminal",
            ),
          ),
          Marker(
            markerId: MarkerId("MarkerId4"),
            position: UwiBookshop,
            infoWindow: InfoWindow(
              title: "Uwi Bookshop",
            ),
          ),
        },
      ),
    );
  }
}
