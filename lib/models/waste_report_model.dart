class WasteReport {
  String id;
  String imageUrl;
  double latitude;
  double longitude;
  String address;
  String ward;
  String status;

  WasteReport({
    required this.id,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.ward,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'ward': ward,
      'status': status,
    };
  }

  factory WasteReport.fromMap(Map<String, dynamic> map) {
    return WasteReport(
      id: map['id'],
      imageUrl: map['imageUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      ward: map['ward'],
      status: map['status'],
    );
  }
}
