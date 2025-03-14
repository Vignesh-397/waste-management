import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_management/models/waste_report_model.dart';

class WasteReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<WasteReport> _reports = [];
  bool isLoading = true;

  WasteReportProvider() {
    fetchWasteReports();
  }

  List<WasteReport> get activeReports =>
      _reports.where((report) => report.status == "Pending").toList();

  List<WasteReport> get resolvedReports =>
      _reports.where((report) => report.status == "Resolved").toList();

  Future<void> fetchWasteReports() async {
    try {
      final snapshot = await _firestore.collection("waste_reports").get();
      _reports =
          snapshot.docs.map((doc) {
            return WasteReport.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
    } catch (e) {
      print("Error fetching waste reports: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsResolved(WasteReport report) async {
    try {
      await _firestore.collection("waste_reports").doc(report.id).update({
        'status': 'Resolved',
      });
      report.status = "Resolved";
      notifyListeners();
    } catch (e) {
      print("Error updating status: $e");
    }
  }
}
