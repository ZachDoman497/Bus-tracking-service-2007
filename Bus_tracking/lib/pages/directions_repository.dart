import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'directions_model.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?'; // Correct URL

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng UWI,
    required LatLng SanFernando,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${SanFernando.latitude},${SanFernando.longitude}',
        'destination': '${UWI.latitude},${UWI.longitude}',
        'key':
            'AIzaSyCmq7UJeNpIOzauEIiIcrf49XflF-HOPAc', // Make sure to include your API key
      },
    );

    if (response.statusCode == 200) {
      return Directions.fromMap(response
          .data); // Assuming you have a Directions model to parse the response
    } else {
      return null;
    }
  }
}
