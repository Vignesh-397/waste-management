import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_management/models/waste_report_model.dart';
import 'package:user_management/providers/waste_report_provider.dart';

class IssueDetailsScreen extends StatelessWidget {
  final WasteReport report;

  IssueDetailsScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report Details")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            report.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              report.address,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "View on Google Maps",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            onTap: () {
              launch(
                "https://www.google.com/maps?q=${report.latitude},${report.longitude}",
              );
            },
          ),
          Spacer(),
          if (report.status == "Pending")
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<WasteReportProvider>().markAsResolved(
                    report,
                  );
                  Navigator.pop(context);
                },
                child: Text("Mark as Resolved"),
              ),
            ),
        ],
      ),
    );
  }
}
