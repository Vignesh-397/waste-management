import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AuthorityScreen extends StatefulWidget {
  @override
  _AuthorityScreenState createState() => _AuthorityScreenState();
}

class _AuthorityScreenState extends State<AuthorityScreen> {
  String? selectedWard;
  List<Map<String, String>> wards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWards();
  }

  Future<void> fetchWards() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('waste_reports').get();

      Set<Map<String, String>> wardSet =
          snapshot.docs
              .map(
                (doc) => {
                  "number":
                      double.parse(
                        doc['ward_no'].toString(),
                      ).toInt().toString(), // Fix decimal issue
                  "name": doc['ward_name'].toString(),
                },
              )
              .toSet();

      setState(() {
        wards = wardSet.toList();
        if (wards.isNotEmpty) {
          selectedWard = "${wards.first['number']} - ${wards.first['name']}";
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching wards: $e");
      setState(() => isLoading = false);
    }
  }

  void proceed() {
    if (selectedWard != null) {
      Map<String, String> selectedWardData = wards.firstWhere(
        (ward) => "${ward['number']} - ${ward['name']}" == selectedWard,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => WardDetailsScreen(
                wardNumber: selectedWardData['number']!,
                wardName: selectedWardData['name']!,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Ward"), backgroundColor: Colors.green),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : wards.isEmpty
                ? Text("No wards available")
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selectedWard,
                      isExpanded: true,
                      items:
                          wards.map((ward) {
                            String wardDisplay =
                                "${ward['number']} - ${ward['name']}";
                            return DropdownMenuItem(
                              value: wardDisplay,
                              child: Text(wardDisplay),
                            );
                          }).toList(),
                      onChanged: (val) => setState(() => selectedWard = val),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: proceed,
                      icon: Icon(Icons.arrow_forward),
                      label: Text("Proceed"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class WardDetailsScreen extends StatelessWidget {
  final String wardNumber;
  final String wardName;

  WardDetailsScreen({required this.wardNumber, required this.wardName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ward $wardNumber - $wardName"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('waste_reports')
                .where(
                  'ward_no',
                  isEqualTo: wardNumber,
                ) // 🔹 Fix: Ensure correct format
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          List<QueryDocumentSnapshot> reports = snapshot.data!.docs;
          List<QueryDocumentSnapshot> activeReports =
              reports.where((r) => r['status'] == 'Pending').toList();
          List<QueryDocumentSnapshot> resolvedReports =
              reports.where((r) => r['status'] == 'Resolved').toList();

          return ListView(
            children: [
              _buildSection(context, "Active Issues", activeReports, true),
              _buildSection(context, "Resolved Issues", resolvedReports, false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<QueryDocumentSnapshot> reports,
    bool isActive,
  ) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          reports.isEmpty
              ? Center(
                child: Text(
                  "No reports available",
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : Column(
                children:
                    reports
                        .map(
                          (report) =>
                              _buildReportTile(context, report, isActive),
                        )
                        .toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context,
    QueryDocumentSnapshot report,
    bool isActive,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: ListTile(
        leading:
            report['imageBase64'] != null
                ? Image.memory(
                  base64Decode(report['imageBase64']),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                : Icon(Icons.image_not_supported),
        title: Text(report['address']),
        subtitle: Text("Status: ${report['status']}"),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportDetailScreen(report: report),
              ),
            ),
      ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot report;

  ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    double lat = report['latitude'];
    double lng = report['longitude'];
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

    return Scaffold(
      appBar: AppBar(
        title: Text("Report Details"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            report['imageBase64'] != null
                ? Image.memory(
                  base64Decode(report['imageBase64']),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Icon(Icons.image_not_supported, size: 200),
            SizedBox(height: 10),
            Text(
              "📍 Address: ${report['address']}",
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () => launch(googleMapsUrl),
              child: Text("View on Map", style: TextStyle(color: Colors.blue)),
            ),
            if (report['status'] == 'Pending')
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('waste_reports')
                      .doc(report.id)
                      .update({'status': 'Resolved'});
                  Navigator.pop(context);
                },
                child: Text("Mark as Resolved"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
