// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'authority_dashboard_screen.dart';

// class SelectWardScreen extends StatefulWidget {
//   const SelectWardScreen({super.key});

//   @override
//   State<SelectWardScreen> createState() => _SelectWardScreenState();
// }

// class _SelectWardScreenState extends State<SelectWardScreen> {
//   String? selectedWard;
//   List<Map<String, String>> wards = []; // Stores ward number & name
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchWards();
//   }

//   Future<void> fetchWards() async {
//     try {
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('waste_reports').get();

//       // Ensuring unique ward numbers and names
//       Set<String> uniqueWardKeys = {};
//       List<Map<String, String>> uniqueWards = [];

//       for (var doc in snapshot.docs) {
//         String wardNumber =
//             int.tryParse(doc['ward_no'].toString())?.toString() ??
//             doc['ward_no'].toString();
//         String wardName = doc['ward_name'].toString();
//         String wardKey = "$wardNumber - $wardName";

//         if (!uniqueWardKeys.contains(wardKey)) {
//           uniqueWardKeys.add(wardKey);
//           uniqueWards.add({"number": wardNumber, "name": wardName});
//         }
//       }

//       setState(() {
//         wards = uniqueWards;
//         selectedWard =
//             wards.isNotEmpty
//                 ? "${wards.first['number']} - ${wards.first['name']}"
//                 : null;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error fetching wards: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   void proceed() {
//     if (selectedWard != null) {
//       Map<String, String> selectedWardData = wards.firstWhere(
//         (ward) => "${ward['number']} - ${ward['name']}" == selectedWard,
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder:
//               (_) => AuthorityDashboardScreen(
//                 wardNumber: selectedWardData['number']!,
//                 wardName: selectedWardData['name']!,
//               ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Ward"),
//         backgroundColor: Colors.green,
//       ),
//       body: Center(
//         child:
//             isLoading
//                 ? const CircularProgressIndicator()
//                 : wards.isEmpty
//                 ? const Text("No wards available")
//                 : Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         "Select Your Ward",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.green, width: 1),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: DropdownButton<String>(
//                           value: selectedWard,
//                           isExpanded: true,
//                           underline: const SizedBox(),
//                           items:
//                               wards
//                                   .map(
//                                     (ward) => DropdownMenuItem(
//                                       value:
//                                           "${ward['number']} - ${ward['name']}",
//                                       child: Text(
//                                         "${ward['number']} - ${ward['name']}",
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                           onChanged:
//                               (val) => setState(() => selectedWard = val),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton.icon(
//                         onPressed: proceed,
//                         icon: const Icon(Icons.arrow_forward),
//                         label: const Text("Proceed"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 14,
//                             horizontal: 24,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//       ),
//     );
//   }
// }
