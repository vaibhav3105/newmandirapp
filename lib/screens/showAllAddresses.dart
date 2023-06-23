// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:mandir_app/screens/show_members.dart';

// import 'package:mandir_app/service/api_service.dart';
// import 'package:http/http.dart' as http;
// import 'package:mandir_app/utils/utils.dart';
// import 'package:mandir_app/widgets/drawer.dart';

// import '../constants.dart';

// class AllAddressScreen extends StatefulWidget {
//   const AllAddressScreen({super.key});

//   @override
//   State<AllAddressScreen> createState() => _AllAddressScreenState();
// }

// class _AllAddressScreenState extends State<AllAddressScreen> {
//   List<dynamic> addresses = [];
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getAddresses();
//   }

//   void getAddresses() async {
//     http.Response response = await ApiService().getResponse(headers, context,
//         {}, "http://122.160.175.36:1000/SocietyApi/api/family-group/list");
//     List<dynamic> parsedResponse = jsonDecode(response.body);

//     setState(() {
//       addresses = parsedResponse;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F1F3),
//       appBar: AppBar(
//         title: const Text("My Addresses"),
//       ),
//       drawer: const MyDrawer(),
//       body: Column(
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           const Padding(
//             padding: EdgeInsets.only(
//               left: 85,
//               right: 20,
//             ),
//             child: Divider(
//               color: Color.fromARGB(
//                 255,
//                 243,
//                 235,
//                 234,
//               ),
//               thickness: 2,
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: addresses.length + 1,
//               itemBuilder: (context, index) {
//                 if (index < addresses.length) {
//                   return Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () => nextScreen(
//                           context,
//                           Show_members_Screen(
//                             familyCode: addresses[index]['code'],
//                             address: addresses[index]['t1'],
//                           ),
//                         ),
//                         child: Container(
//                           // color: Colors.white,
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 30,
//                               vertical: 1,
//                             ),
//                             leading: CircleAvatar(
//                               backgroundColor: colors[index % colors.length],
//                               child: const Icon(
//                                 Icons.location_on_outlined,
//                               ),
//                             ),
//                             title: Text(
//                               addresses[index]['t1'],
//                               style: const TextStyle(
//                                   // fontSize: 20,
//                                   ),
//                             ),
//                             subtitle: Text(
//                               addresses[index]['t3'],
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             trailing: const Icon(
//                               FontAwesomeIcons.angleRight,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(
//                           left: 85,
//                           right: 20,
//                         ),
//                         child: Divider(
//                           color: Color.fromARGB(
//                             255,
//                             243,
//                             235,
//                             234,
//                           ),
//                           thickness: 2,
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () => nextScreen(
//                           context,
//                           const Show_members_Screen(
//                             familyCode: null,
//                             address: "Showing full family",
//                           ),
//                         ),
//                         child: Container(
//                           // color: Colors.white,
//                           child: const ListTile(
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 30,
//                               vertical: 8,
//                             ),
//                             leading: CircleAvatar(
//                               child: Icon(
//                                 Icons.location_on_outlined,
//                               ),
//                             ),
//                             title: Text(
//                               'Show Full Family',
//                               style: TextStyle(
//                                   // fontSize: 20,
//                                   ),
//                             ),
//                             trailing: Icon(
//                               FontAwesomeIcons.angleRight,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(
//                           left: 85,
//                           right: 20,
//                         ),
//                         child: Divider(
//                           color: Color.fromARGB(
//                             255,
//                             243,
//                             235,
//                             234,
//                           ),
//                           thickness: 2,
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
