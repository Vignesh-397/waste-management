import 'dart:io';
import 'package:xml/xml.dart';
import 'package:turf/turf.dart';

/// Represents a ward with name and boundary
class Ward {
  final String name;
  final List<Position> boundary;

  Ward({required this.name, required this.boundary});
}

/// **Parses KML file and extracts ward polygons**
Future<List<Ward>> parseKML(String filePath) async {
  final file = File(filePath);
  final xmlString = await file.readAsString();
  final document = XmlDocument.parse(xmlString);

  List<Ward> wards = [];

  for (var placemark in document.findAllElements('Placemark')) {
    final name = placemark.findElements('name').first.innerText;

    final coordinates =
        placemark
            .findAllElements('coordinates')
            .first
            .innerText
            .trim()
            .split(' ')
            .map((point) {
              final parts = point.split(',');
              return Position(
                lng: double.parse(parts[0]),
                lat: double.parse(parts[1]),
              );
            })
            .toList();

    wards.add(Ward(name: name, boundary: coordinates));
  }

  return wards;
}
