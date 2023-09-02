import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../utils/utils.dart';
import 'myFamilyList.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final dateController = TextEditingController();
  List<dynamic> members = [];
  bool isLoading = false;
  DateTime? date;
  void getBirthdays(DateTime date) async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().post('/api/family-member/birthday-list',
        {"ReqDate": date.toString()}, headers, context);
    setState(() {
      members = response;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    date = DateTime.now();
    getBirthdays(
      DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Birthdays"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: TextFormField(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1920),
                    lastDate: DateTime(2080));
                if (pickedDate != null) {
                  setState(() {
                    dateController.text =
                        DateFormat('dd-MMM-yyyy').format(pickedDate);
                    date = pickedDate;
                    getBirthdays(date!);
                  });
                }
              },
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.event,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                hintText: "Enter your text...",
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      date = date!.subtract(
                        const Duration(
                          days: 1,
                        ),
                      );
                      dateController.text =
                          DateFormat('dd-MMM-yyyy').format(date!);
                    });

                    getBirthdays(date!);
                  },
                  child: const Text("< Prev"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      date = DateTime.now();
                      dateController.text =
                          DateFormat('dd-MMM-yyyy').format(date!);
                    });

                    getBirthdays(date!);
                  },
                  child: const Text("Today"),
                ),
                TextButton(
                  child: const Text('Next >'),
                  onPressed: () {
                    setState(() {
                      date = date!.add(
                        const Duration(
                          days: 1,
                        ),
                      );
                      dateController.text =
                          DateFormat('dd-MMM-yyyy').format(date!);
                    });

                    getBirthdays(date!);
                  },
                ),
              ],
            ),
          ),
          // const Divider(
          //   height: 5,
          //   color: Colors.white,
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 20,
          //   ),
          //   child: Text(
          //     'Showing birthdays of ${dateController.text}',
          //   ),
          // ),
          const SizedBox(
            height: 10,
          ),
          !isLoading
              ? members.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 19,
                                ),
                                child: GestureDetector(
                                  onTap: () => nextScreen(
                                      context,
                                      ShowMemberInfo(
                                          memberCode: members[index]['code'])),
                                  child: Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                if (members[index]['age']
                                                        .length >
                                                    0)
                                                  TextSpan(
                                                    text: members[index]['age'],
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                if (members[index]['age']
                                                        .length >
                                                    0)
                                                  const TextSpan(
                                                    text: " • ",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                TextSpan(
                                                  text: members[index]
                                                      ['resultText'],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: " • ",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: members[index]
                                                      ['fullAddress'],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 1,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            colors[index % colors.length],
                                        child: Text(
                                          members[index]['name'][0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        members[index]['name'],
                                        style: const TextStyle(),
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.20,
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 13,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Text(
                                                          "     Select an action",
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                              255,
                                                              106,
                                                              78,
                                                              179,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            nextScreen(
                                                              context,
                                                              ShowMemberInfo(
                                                                memberCode:
                                                                    members[index]
                                                                        [
                                                                        'code'],
                                                              ),
                                                            );
                                                          },
                                                          child: const ListTile(
                                                            title: Text(
                                                              "View Member Info",
                                                            ),
                                                            leading: FaIcon(
                                                              FontAwesomeIcons
                                                                  .userLarge,
                                                              color: Color
                                                                  .fromARGB(
                                                                255,
                                                                106,
                                                                78,
                                                                179,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            nextScreen(
                                                                context,
                                                                MyFamilyList(
                                                                    code: members[
                                                                            index]
                                                                        [
                                                                        'code']));
                                                          },
                                                          child: const ListTile(
                                                            title: Text(
                                                              "View Family",
                                                            ),
                                                            leading: FaIcon(
                                                              FontAwesomeIcons
                                                                  .userGroup,
                                                              color: Color
                                                                  .fromARGB(
                                                                255,
                                                                106,
                                                                78,
                                                                179,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          color: Colors.white,
                                          width: 30,
                                          child: FaIcon(
                                            FontAwesomeIcons.ellipsisVertical,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 3,
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : const Text('No record found')
              : const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
        ],
      ),
    );
  }
}