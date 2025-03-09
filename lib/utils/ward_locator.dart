import 'package:turf/turf.dart';
import 'parse_kml.dart';

bool isPointInPolygon(List<List<double>> polygon, double lat, double lon) {
  // Convert coordinates to Turf.js GeoJSON format
  var point = Point(
    coordinates: Position(lon, lat),
  ); // Turf uses [longitude, latitude]
  var poly = Polygon(
    coordinates: [polygon.map((p) => Position(p[0], p[1])).toList()],
  );

  return booleanPointInPolygon(point, poly);
}

Future<Map<String, dynamic>?> getWardForLocation(double lat, double lon) async {
  List<Map<String, dynamic>> wards = await parseKML();

  for (var ward in wards) {
    if (isPointInPolygon(ward['boundary'], lat, lon)) {
      return ward; // Return full ward details
    }
  }
  return null; // No ward found
}
