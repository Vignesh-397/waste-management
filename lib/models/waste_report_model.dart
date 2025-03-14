import 'package:cloud_firestore/cloud_firestore.dart';

class WasteReport {
  String id;
  String imageBase64;
  double latitude;
  double longitude;
  String address;
  String wardName;
  String wardNo;
  String status;
  DateTime timestamp;

  WasteReport({
    required this.id,
    required this.imageBase64,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.wardName,
    required this.wardNo,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageBase64': imageBase64,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'ward_name': wardName,
      'ward_no': wardNo,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory WasteReport.fromMap(Map<String, dynamic> map) {
    return WasteReport(
      id: map['id'],
      imageBase64: map['imageBase64'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'],
      wardName: map['ward_name'],
      wardNo: map['ward_no'],
      status: map['status'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
