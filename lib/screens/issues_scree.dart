import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_management/providers/waste_report_provider.dart';

import 'issue_details_screen.dart';

class IssuesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Waste Reports"),
          bottom: TabBar(tabs: [Tab(text: "Active"), Tab(text: "Resolved")]),
        ),
        body: Consumer<WasteReportProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [IssueList(isActive: true), IssueList(isActive: false)],
            );
          },
        ),
      ),
    );
  }
}

class IssueList extends StatelessWidget {
  final bool isActive;

  IssueList({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final reports =
        isActive
            ? context.watch<WasteReportProvider>().activeReports
            : context.watch<WasteReportProvider>().resolvedReports;

    if (reports.isEmpty) {
      return Center(child: Text("No reports found"));
    }

    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          child: ListTile(
            leading: Image.network(
              report.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(
              report.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IssueDetailsScreen(report: report),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
