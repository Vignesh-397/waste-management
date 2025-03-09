import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<String> getAddress(double latitude, double longitude) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? 'Unknown Location';
    }
    return 'Unknown Location';
  }
}
