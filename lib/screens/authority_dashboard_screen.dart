import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorityDashboardScreen extends StatelessWidget {
  final String ward;
  const AuthorityDashboardScreen({super.key, required this.ward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste Reports - $ward"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('waste_reports')
                .where('ward', isEqualTo: ward)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color:
                        data['status'] == 'Resolved'
                            ? Colors.green
                            : Colors.red,
                    size: 32,
                  ),
                  title: Text(
                    data['address'] ?? 'Unknown Location',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: ${data['status']}',
                    style: TextStyle(
                      color:
                          data['status'] == 'Resolved'
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
