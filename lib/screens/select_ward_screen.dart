import 'package:flutter/material.dart';
import 'authority_dashboard_screen.dart';

class SelectWardScreen extends StatefulWidget {
  const SelectWardScreen({super.key});

  @override
  State<SelectWardScreen> createState() => _SelectWardScreenState();
}

class _SelectWardScreenState extends State<SelectWardScreen> {
  String selectedWard = 'Ward 1'; // Default selection
  final List<String> wards = [
    'Ward 1',
    'Ward 2',
    'Ward 3',
    'Ward 4',
    'Ward 5',
  ]; // Sample ward list

  void proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthorityDashboardScreen(ward: selectedWard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select Your Ward",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: selectedWard,
              isExpanded: true,
              underline: const SizedBox(),
              items:
                  wards.map((ward) {
                    return DropdownMenuItem(
                      value: ward,
                      child: Text(ward, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => selectedWard = val!),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: proceed,
            icon: const Icon(Icons.arrow_forward),
            label: const Text("Proceed"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
