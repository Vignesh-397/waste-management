import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

class DatabaseService {
  /// 🔹 Compress image before converting to Base64
  static Future<String> encodeImageToBase64(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Decode the image
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode image");
    }

    // Resize to reduce size (adjust width/height as needed)
    img.Image resizedImage = img.copyResize(originalImage, width: 600);

    // Encode back to JPEG with 85% quality
    Uint8List compressedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: 85),
    );

    // Convert to Base64
    return base64Encode(compressedBytes);
  }

  /// 🔹 Upload Report with Compressed Base64 Image
  static Future<void> uploadWasteReport(
    File image,
    double latitude,
    double longitude,
    String address,
  ) async {
    String base64Image = await encodeImageToBase64(image);

    await FirebaseFirestore.instance.collection('waste_reports').add({
      'imageBase64': base64Image, // 🔹 Store compressed image
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
