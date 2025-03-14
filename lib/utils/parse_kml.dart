import 'dart:convert';
import 'dart:math';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart';

class KMLParser {
  List<Map<String, dynamic>> wardBoundaries = [];

  /// Load and parse KML file
  Future<void> loadKML(String assetPath) async {
    final String kmlString = await rootBundle.loadString(assetPath);
    final XmlDocument xmlDocument = XmlDocument.parse(kmlString);

    final placemarks = xmlDocument.findAllElements('Placemark');

    for (var placemark in placemarks) {
      final wardNo =
          placemark
              .findAllElements('SimpleData')
              .firstWhere(
                (e) => e.getAttribute('name') == 'WARD_NO',
                orElse: () => XmlElement(XmlName('')),
              )
              .innerText;

      final wardName =
          placemark
              .findAllElements('SimpleData')
              .firstWhere(
                (e) => e.getAttribute('name') == 'WARD_NAME',
                orElse: () => XmlElement(XmlName('')),
              )
              .innerText;

      final coordinates =
          placemark
              .findAllElements('coordinates')
              .expand((element) => element.text.split(' '))
              .map((coord) {
                final parts = coord.split(',');
                if (parts.length >= 2) {
                  return {
                    'lat': double.parse(parts[1]),
                    'lon': double.parse(parts[0]),
                  };
                }
                return null;
              })
              .whereType<Map<String, double>>()
              .toList();

      wardBoundaries.add({
        'ward_no': wardNo,
        'ward_name': wardName,
        'polygon': coordinates,
      });
    }
  }

  /// Check if a coordinate is inside any ward polygon
  Map<String, dynamic>? getWardFromCoordinates(double lat, double lon) {
    for (var ward in wardBoundaries) {
      if (_isPointInPolygon(lat, lon, ward['polygon'])) {
        return {'ward_no': ward['ward_no'], 'ward_name': ward['ward_name']};
      }
    }
    return null;
  }

  /// Ray-casting algorithm to check if point is inside polygon
  bool _isPointInPolygon(
    double lat,
    double lon,
    List<Map<String, double>> polygon,
  ) {
    int intersections = 0;
    for (int i = 0; i < polygon.length - 1; i++) {
      var p1 = polygon[i];
      var p2 = polygon[i + 1];

      if ((p1['lat']! > lat) != (p2['lat']! > lat) &&
          lon <
              (p2['lon']! - p1['lon']!) *
                      (lat - p1['lat']!) /
                      (p2['lat']! - p1['lat']!) +
                  p1['lon']!) {
        intersections++;
      }
    }
    return intersections % 2 == 1;
  }
}
