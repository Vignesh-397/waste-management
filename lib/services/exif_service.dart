import 'dart:io';
import 'package:exif/exif.dart';

Future<Map<String, double>?> extractGPS(File imageFile) async {
  try {
    final bytes = await imageFile.readAsBytes();
    final data = await readExifFromBytes(bytes);

    if (data.isEmpty) {
      print("❌ No EXIF data found");
      return null;
    }

    print("📷 EXIF Data: $data"); // Log full EXIF data

    final latTag = data['GPS GPSLatitude'];
    final lonTag = data['GPS GPSLongitude'];
    final latRef = data['GPS GPSLatitudeRef'];
    final lonRef = data['GPS GPSLongitudeRef'];

    if (latTag == null || lonTag == null || latRef == null || lonRef == null) {
      print("❌ Missing GPS metadata in EXIF");
      return null;
    }

    // Convert EXIF GPS format to decimal degrees
    double latitude = _convertToDegrees(latTag);
    double longitude = _convertToDegrees(lonTag);

    // Adjust sign based on hemisphere (N/S, E/W)
    if (latRef.printable.contains('S')) latitude = -latitude;
    if (lonRef.printable.contains('W')) longitude = -longitude;

    return {'latitude': latitude, 'longitude': longitude};
  } catch (e) {
    print("❌ Error extracting GPS data: $e");
    return null;
  }
}

double _convertToDegrees(IfdTag tag) {
  if (tag.values is IfdRatios) {
    List values = tag.values.toList(); // Convert IfdRatios to List

    if (values.length >= 3) {
      double d = values[0].numerator / values[0].denominator;
      double m = values[1].numerator / values[1].denominator;
      double s = values[2].numerator / values[2].denominator;
      return d + (m / 60) + (s / 3600);
    }
  }
  return 0.0;
}
