// import 'package:flutter/material.dart';
// import 'package:mandir_app/service/notificationAPI.dart';

// class ReminderScreen extends StatefulWidget {
//   const ReminderScreen({super.key});

//   @override
//   State<ReminderScreen> createState() => _ReminderScreenState();
// }

// class _ReminderScreenState extends State<ReminderScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 50,
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 NotificationApi.showNotification(
//                   title: 'hu',
//                   body: 'hi',
//                   payload: 'newScreen',
//                 );
//               },
//               child: const Text("Schedule"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
