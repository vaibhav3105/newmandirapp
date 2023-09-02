import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/utils/styling.dart';

import 'package:mandir_app/widgets/custom_textfield.dart';

import '../service/api_service.dart';

class APIDropDownItem {
  String displayText;
  String? actualValue;
  APIDropDownItem({
    required this.displayText,
    required this.actualValue,
  });
}

class EditScreen extends StatefulWidget {
  final String membercode;
  final String groupCode;
  const EditScreen({
    Key? key,
    required this.membercode,
    required this.groupCode,
  }) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  bool isLoading = false;
  bool? isFamilyHead = false;
  bool? maskMobile = false;
  APIDropDownItem? initialGender;
  APIDropDownItem? initialOccupation;
  APIDropDownItem? initialMask;
  List<DropdownMenuItem<APIDropDownItem>> genderOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> ocuupationOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> maskMobileOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyFamily();
  }

  createMember() async {
    var response = await ApiService().post(
        '/api/family-member/create',
        {
          "familyGroupCode": widget.groupCode,
          "name": nameController.text.trim(),
          "relationship": relationshipController.text.trim(),
          "mobile": mobileController.text.trim(),
          "maskMobile": maskMobile,
          "email": emailController.text.trim(),
          "gender": initialGender != null ? initialGender!.actualValue : null,
          "phone": otherPhoneController.text.trim(),
          "nativePlace": nativePlaceController.text.trim(),
          "dob": dateController.text.trim(),
          "occType":
              initialOccupation != null ? initialOccupation!.actualValue : null,
          "occDetail": occupationDetailController.text.trim(),
          "isFamilyHead": isFamilyHead
        },
        headers,
        context);
    print(response);
    if (response['errorCode'] == 0) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return MyFamilyList(code: '');
      }), (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          behavior: SnackBarBehavior.floating, // Make the SnackBar float
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Customize the border shape
          ),
          margin: const EdgeInsets.all(
              16), // Adjust the margin to position the SnackBar
          elevation: 10, // Increase the elevation for an elevated effect
        ),
      );
    }
  }

  updateInfo() async {
    var response = await ApiService().post(
        '/api/family-member/update',
        {
          "familyMemberCode": widget.membercode,
          "name": nameController.text.trim(),
          "relationship": relationshipController.text.trim(),
          "mobile": mobileController.text.trim(),
          "maskMobile": maskMobile,
          "email": emailController.text.trim(),
          "gender": initialGender != null ? initialGender!.actualValue : null,
          "phone": otherPhoneController.text.trim(),
          "nativePlace": nativePlaceController.text.trim(),
          "dob": dateController.text.trim(),
          "occType":
              initialOccupation != null ? initialOccupation!.actualValue : null,
          "occDetail": occupationDetailController.text.trim(),
          "isFamilyHead": isFamilyHead
        },
        headers,
        context);
    print(response);
    if (response['errorCode'] == 0) {
      // nextScreenReplace(
      //   context,
      //   MyFamilyList(code: ''),
      // );
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return MyFamilyList(code: '');
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          behavior: SnackBarBehavior.floating, // Make the SnackBar float
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Customize the border shape
          ),
          margin: const EdgeInsets.all(
              16), // Adjust the margin to position the SnackBar
          elevation: 10, // Increase the elevation for an elevated effect
        ),
      );
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController otherPhoneController = TextEditingController();
  final TextEditingController nativePlaceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController occupationDetailController =
      TextEditingController();
  var result = {};

  void getMyFamily() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await ApiService().post("/api/family-member/edit-info",
          {"familyMemberCode": widget.membercode}, headers, context);
      var genderItems = (response['gender'] as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['text'],
              actualValue: apiItem['value'],
            ),
          )
          .toList();
      var maskItems = (response['mobileConfigList'] as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['text'],
              actualValue: apiItem['value'],
            ),
          )
          .toList();

      var ocuupationItems = (response['occupationType'] as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['text'],
              actualValue: apiItem['value'],
            ),
          )
          .toList();
      if (widget.membercode != '') {
        setState(() {
          var initialGenderValue = response['info'][0]['gender'];

          if (initialGenderValue.toString().isNotEmpty) {
            print(initialGenderValue.toString().isEmpty);
            initialGender = genderItems.firstWhere(
              (item) => item.actualValue == initialGenderValue,
            );
          } else {}

          var initialOccupationValue = response['info'][0]['occType'];
          if (initialOccupationValue != "") {
            initialOccupation = ocuupationItems.firstWhere(
              (item) => item.actualValue == initialOccupationValue,
            );
          } else {
            initialOccupation = ocuupationItems[2];
          }

          var initialMaskValue = response['info'][0]['mobileConfig'];
          if (initialMaskValue != "") {
            initialMask = maskItems.firstWhere(
              (item) => item.actualValue == initialMaskValue,
            );
          } else {
            initialMask = maskItems[2];
          }
          result = response;
          genderOptionsButton = genderItems
              .map(
                (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                  value: item,
                  child: Text(
                    item.displayText,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList();
          ocuupationOptionsButton = ocuupationItems
              .map(
                (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                  value: item,
                  child: Text(
                    item.displayText,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList();
          maskMobileOptionsButton = maskItems
              .map(
                (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                  value: item,
                  child: Text(
                    item.displayText,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList();

          isFamilyHead = response['info'][0]['isFamilyHead'];
          maskMobile = response['info'][0]['maskMobile'];
          dateController.text = response['info'][0]['dob'] != null
              ? DateFormat('dd-MMM-yyyy')
                  .format(DateTime.parse(response['info'][0]['dob']))
              : DateFormat('dd-MMM-yyyy').format(DateTime.now());
          nameController.text = response['info'][0]['name'];
          relationshipController.text = response['info'][0]['relationship'];
          mobileController.text = response['info'][0]['mobile'];
          emailController.text = response['info'][0]['email'];
          otherPhoneController.text = response['info'][0]['phone'];
          nativePlaceController.text = response['info'][0]['nativePlace'];
          occupationDetailController.text = response['info'][0]['occDetail'];
          isLoading = false;
        });
      } else {
        setState(() {
          dateController.text =
              DateFormat('dd-MMM-yyyy').format(DateTime.now());
          genderOptionsButton = genderItems
              .map(
                (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                  value: item,
                  child: Text(
                    item.displayText,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList();
          maskMobileOptionsButton = maskItems
              .map(
                (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                  value: item,
                  child: Text(
                    item.displayText,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList();
          ocuupationOptionsButton = ocuupationItems
              .map(
                (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                  value: item,
                  child: Text(
                    item.displayText,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: widget.membercode != ''
            ? const Text(
                "Edit Member Info",
              )
            : const Text(
                "Add a Member",
              ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        labelText: 'Name',
                        controller: nameController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: relationshipController,
                        labelText: 'Relationship',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          controller: mobileController,
                          decoration: textInputDecoration.copyWith(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Mobile',
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Show/Hide Mobile number"),
                        value: initialMask,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Show/Hide Mobile number',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: maskMobileOptionsButton,
                        onChanged: (APIDropDownItem? item) {
                          setState(() {
                            initialMask = item!;
                          });
                        },
                      ),

                      // SizedBox(
                      //   height: 80,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Expanded(
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             const Text('Hide Mobile Number?'),
                      //             Text(
                      //               maskMobile == false
                      //                   ? "This will show your mobile number to other logins. But you can mask it by hiding your number."
                      //                   : ' This will hide some part of your mobile number from other logins. Only admin can view it.',
                      //               style: TextStyle(
                      //                 color: Colors.grey[500],
                      //                 fontSize: 13,
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       ),
                      //       Switch(
                      //         thumbIcon: thumbIcon,
                      //         value: maskMobile!,
                      //         onChanged: (bool value) {
                      //           setState(() {
                      //             maskMobile = value;
                      //           });
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: emailController,
                        labelText: 'Email',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Select a gender"),
                        value: initialGender,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'gender',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: genderOptionsButton,
                        onChanged: (APIDropDownItem? item) {
                          setState(() {
                            initialGender = item!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: otherPhoneController,
                        labelText: 'Other Phone Number',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: nativePlaceController,
                        labelText: 'Native Place',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: widget.membercode != ''
                                  ? result['info'][0]['dob'] != null
                                      ? DateTime.parse(result['info'][0]['dob'])
                                      : DateTime.now()
                                  : DateTime.now(),
                              firstDate: DateTime(1920),
                              lastDate: DateTime(2080));
                          if (pickedDate != null) {
                            setState(() {
                              dateController.text =
                                  DateFormat('dd-MMM-yyyy').format(pickedDate);
                            });
                          }
                        },
                        controller: dateController,
                        decoration: textInputDecoration.copyWith(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'DOB'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Enter Occupation type"),
                        value: initialOccupation,
                        decoration: textInputDecoration.copyWith(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Occupation Type'),
                        items: ocuupationOptionsButton,
                        onChanged: (APIDropDownItem? item) {
                          setState(() {
                            initialOccupation = item!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: occupationDetailController,
                        labelText: 'Occupation Detail',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Are you the family head?"),
                                  Text(
                                    "You should mark only one person as family head in the group.",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              thumbIcon: thumbIcon,
                              value: isFamilyHead!,
                              onChanged: (bool value) {
                                setState(() {
                                  isFamilyHead = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.membercode != ''
                                  ? updateInfo()
                                  : createMember();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              fixedSize: const Size(170, 45),
                              backgroundColor: const Color.fromARGB(
                                255,
                                106,
                                78,
                                179,
                              ),
                            ),
                            child: widget.membercode != ''
                                ? const Text(
                                    "Update",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  )
                                : const Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
