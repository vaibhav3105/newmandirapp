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
  bool? hideMobileFlag = false;
  bool? hideEmailFlag = false;
  bool? hideDobFlag = false;
  bool? hideProfilePhotoFlag = false;
  bool? hideProfileViewFlag = false;
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
          "hideMobile": hideMobileFlag,
          "hideEmail": hideEmailFlag,
          "hideDob": hideDobFlag,
          "hideProfilePhoto": hideProfilePhotoFlag,
          "hideProfileView": hideProfileViewFlag,
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
          "hideMobile": hideMobileFlag,
          "hideEmail": hideEmailFlag,
          "hideDob": hideDobFlag,
          "hideProfilePhoto": hideProfilePhotoFlag,
          "hideProfileView": hideProfileViewFlag,
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

          hideMobileFlag = response['info'][0]['hideMobile'];
          hideEmailFlag = response['info'][0]['hideEmail'];
          hideDobFlag = response['info'][0]['hideDob'];
          hideProfilePhotoFlag = response['info'][0]['hideProfilePhoto'];
          hideProfileViewFlag = response['info'][0]['hideProfileView'];

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
                        title: const Text("Hide your mobile from others?"),
                        subtitle: Text(
                          "Using this option, you can hide or show your mobile number from others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: hideMobileFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              hideMobileFlag = value;
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
                        title: const Text("Hide your email from others?"),
                        subtitle: Text(
                          "Using this option, you can hide or show your email address from others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: hideEmailFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              hideEmailFlag = value;
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
                        title: const Text("Hide your DOB from others?"),
                        subtitle: Text(
                          "Using this option, you can hide or show your date of birth from others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: hideDobFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              hideDobFlag = value;
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
                        title:
                            const Text("Hide your profile photo from others?"),
                        subtitle: Text(
                          "Using this option, you can hide or show your profile photo from others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: hideProfilePhotoFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              hideProfilePhotoFlag = value;
                            });
                          },
                        ),
                      ),
                      // -- Hide this member from others?
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 0.0, right: 0.0),
                        title:
                            const Text("Hide my profile details from others?"),
                        subtitle: Text(
                          "Using this option, you can hide or show your profile view/details from others.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Switch(
                          thumbIcon: thumbIcon,
                          value: hideProfileViewFlag!,
                          onChanged: (bool value) {
                            setState(() {
                              hideProfileViewFlag = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // --
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.membercode != ''
                                  ? updateInfo()
                                  : createMember();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: widget.membercode != ''
                                ? const Text(
                                    "Update",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                : const Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
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
