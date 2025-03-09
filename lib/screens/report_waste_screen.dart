import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:user_management/providers/auth_provider.dart';
import 'package:user_management/screens/home_screen.dart';
import 'package:user_management/screens/landing_screen.dart';
import 'package:user_management/services/database_service.dart';

class ReportWasteScreen extends StatefulWidget {
  const ReportWasteScreen({super.key});

  @override
  State<ReportWasteScreen> createState() => _ReportWasteScreenState();
}

class _ReportWasteScreenState extends State<ReportWasteScreen> {
  File? _image;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _address;

  /// 📸 Capture image from camera
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    await _getLocation(); // Get GPS coordinates

    setState(() {
      _image = file;
    });
  }

  /// 📍 Get current location
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("⚠️ Location permission is required.");
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      String address = await _getAddressFromCoordinates(
        _latitude!,
        _longitude!,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address; // Store the address
      });

      print("✅ GPS Extracted: Latitude = $_latitude, Longitude = $_longitude");
      print("📍 Address: $_address");
    } catch (e) {
      _showError("❌ Error getting location: ${e.toString()}");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _getAddressFromCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] ?? "Address Not Found";
      } else {
        return "Address Not Found";
      }
    } catch (e) {
      return "Address Not Found";
    }
  }

  /// 🚀 Submit the report
  Future<void> _submitReport() async {
    try {
      if (_image == null || _latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Please select an image with GPS data"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await DatabaseService.uploadWasteReport(
        _image!,
        _latitude!,
        _longitude!,
        _address!,
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Waste Report Submitted Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ), // Replace with your target screen
      );
    } catch (e) {
      print("❌ Error submitting report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Submission failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 🛑 Show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Waste"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(
                          Icons.camera_alt,
                          size: 120,
                          color: Colors.grey,
                        ),
                    const SizedBox(height: 10),
                    _latitude != null
                        ? Text(
                          "📍 Location: $_latitude, $_longitude",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : const Text(
                          "⚠️ Location Not Available",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera),
              label: const Text("Capture Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: const Icon(Icons.send),
                  label: const Text("Submit Report"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
