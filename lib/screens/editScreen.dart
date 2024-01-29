// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  bool? isDefault;
  APIDropDownItem({
    required this.displayText,
    required this.actualValue,
    this.isDefault,
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
  bool? showMobileFlag = true;
  bool? showEmailFlag = true;
  bool? showDobFlag = true;
  bool? showProfilePhotoFlag = true;
  bool? showFamilyViewFlag = true;
  APIDropDownItem? initialGender;
  APIDropDownItem? initialOccupation;
  APIDropDownItem? initialMaritalStatus;
  List<DropdownMenuItem<APIDropDownItem>> genderOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> ocuupationOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> maritalStatusOptionsButton =
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
          "showMobile": showMobileFlag,
          "showEmail": showEmailFlag,
          "showDob": showDobFlag,
          "showProfilePhoto": showProfilePhotoFlag,
          "showFamilyView": showFamilyViewFlag,
          "email": emailController.text.trim(),
          "gender": initialGender != null ? initialGender!.actualValue : null,
          "phone": otherPhoneController.text.trim(),
          "nativePlace": nativePlaceController.text.trim(),
          "dob": dateController.text.trim(),
          "occType":
              initialOccupation != null ? initialOccupation!.actualValue : null,
          "occDetail": occupationDetailController.text.trim(),
          'maritalStatus': initialMaritalStatus != null
              ? initialMaritalStatus!.actualValue
              : null,
          "qualification": qualificationController.text.trim(),
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
          "showMobile": showMobileFlag,
          "showEmail": showEmailFlag,
          "showDob": showDobFlag,
          "showProfilePhoto": showProfilePhotoFlag,
          "showFamilyView": showFamilyViewFlag,
          "email": emailController.text.trim(),
          "gender": initialGender != null ? initialGender!.actualValue : null,
          "phone": otherPhoneController.text.trim(),
          "nativePlace": nativePlaceController.text.trim(),
          "dob": dateController.text.trim(),
          "occType":
              initialOccupation != null ? initialOccupation!.actualValue : null,
          "occDetail": occupationDetailController.text.trim(),
          'maritalStatus': initialMaritalStatus != null
              ? initialMaritalStatus!.actualValue
              : null,
          "qualification": qualificationController.text.trim(),
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
  final TextEditingController qualificationController = TextEditingController();
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
      print(response);
      var genderItems = (response['gender'] as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['text'],
              actualValue: apiItem['value'],
            ),
          )
          .toList();

      var maritalItems = (response['maritalStatus'] as List<dynamic>)
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

          var initialMaritalValue = response['info'][0]['maritalStatus'];
          if (initialMaritalValue.toString().isNotEmpty) {
            initialMaritalStatus = maritalItems.firstWhere(
              (item) => item.actualValue == initialMaritalValue,
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

          showMobileFlag = response['info'][0]['showMobile'];
          showEmailFlag = response['info'][0]['showEmail'];
          showDobFlag = response['info'][0]['showDob'];
          showProfilePhotoFlag = response['info'][0]['showProfilePhoto'];
          showFamilyViewFlag = response['info'][0]['showFamilyView'];

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
          maritalStatusOptionsButton = maritalItems
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

          isFamilyHead = response['info'][0]['isFamilyHead'];

          dateController.text = response['info'][0]['dob'] != null
              ? DateFormat('dd-MMM-yyyy')
                  .format(DateTime.parse(response['info'][0]['dob']))
              : DateFormat('dd-MMM-yyyy').format(DateTime.now());
          qualificationController.text = response['info'][0]['qualification'];
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
          maritalStatusOptionsButton = maritalItems
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
                      const Text('Name'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        labelText: '',
                        controller: nameController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Relationship'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        controller: relationshipController,
                        labelText: '',
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'e.g. Son of Gaurav Jain, Wife of Gaurav Jain, etc.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Mobile'),
                      const SizedBox(
                        height: 5,
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
                            labelText: '',
                          )),
                      // -- Show your mobile to others?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: const Text("Show your mobile to others?"),
                        subtitle: Text(
                          "Using this switch, you can show or hide your mobile number with others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: showMobileFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              showMobileFlag = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Email'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        controller: emailController,
                        labelText: '',
                      ),
                      // -- Show your email to others?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: const Text("Show your email to others?"),
                        subtitle: Text(
                          "Using this switch, you can show or hide your email address with others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: showEmailFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              showEmailFlag = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Gender'),
                      const SizedBox(
                        height: 5,
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Select a gender"),
                        value: initialGender,
                        decoration: textInputDecoration.copyWith(
                          labelText: '',
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
                      const Text('Marital Status'),
                      const SizedBox(
                        height: 5,
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Select a marital status"),
                        value: initialMaritalStatus,
                        decoration: textInputDecoration.copyWith(
                          labelText: '',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: maritalStatusOptionsButton,
                        onChanged: (APIDropDownItem? item) {
                          setState(() {
                            initialMaritalStatus = item!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Other Phone Number'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        controller: otherPhoneController,
                        labelText: '',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Qualification'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextAreaField(
                        controller: qualificationController,
                        labelText: '',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Native Place'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        controller: nativePlaceController,
                        labelText: '',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Date of Birth'),
                      const SizedBox(
                        height: 5,
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
                            labelText: ''),
                      ),
                      // -- Show your DOB to others?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: const Text("Show your DOB to others?"),
                        subtitle: Text(
                          "Using this switch, you can show or hide your date of birth with others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: showDobFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              showDobFlag = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Occupation Type'),
                      const SizedBox(
                        height: 5,
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Enter Occupation type"),
                        value: initialOccupation,
                        decoration: textInputDecoration.copyWith(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: ''),
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
                      const Text('Occupation Detail'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextAreaField(
                        controller: occupationDetailController,
                        labelText: '',
                      ),

                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'e.g. Your company or business name with address.',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // -- Are you the family head?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: const Text("Are you the family head?"),
                        subtitle: Text(
                          "You should mark only one person as family head in the group.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: isFamilyHead!,
                          onChanged: (bool value) {
                            setState(() {
                              isFamilyHead = value;
                            });
                          },
                        ),
                      ),
                      // -- Show your profile photo to others?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: const Text("Show your profile photo to others?"),
                        subtitle: Text(
                          "Using this switch, you can show or hide your profile photo with others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: showProfilePhotoFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              showProfilePhotoFlag = value;
                            });
                          },
                        ),
                      ),
                      // -- Show your family view to others?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title: const Text("Show your family view to others?"),
                        subtitle: Text(
                          "Using this switch, you can show or hide your family view with others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: showFamilyViewFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              showFamilyViewFlag = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // --
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
