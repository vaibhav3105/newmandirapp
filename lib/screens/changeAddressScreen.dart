// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/utils.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';

import '../utils/styling.dart';
import 'editScreen.dart';
import 'myFamilyList.dart';

class ChangeAddressScreen extends StatefulWidget {
  final String groupCode;
  const ChangeAddressScreen({
    Key? key,
    required this.groupCode,
  }) : super(key: key);

  @override
  State<ChangeAddressScreen> createState() => _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends State<ChangeAddressScreen> {
  APIDropDownItem? initialArea;
  APIDropDownItem? initialMandir;
  bool isLoading = false;
  var areaItemss = [];

  List<DropdownMenuItem<APIDropDownItem>> areaOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> mandirOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  final addressController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAreaAndMandirList();
  }

  updateAddress() async {
    try {
      var response = await ApiService().post(
          '/api/family-group/update-address',
          {
            "familyGroupCode": widget.groupCode,
            "areaCode": initialArea!.actualValue,
            "address": addressController.text.trim(),
            'mandirCode': initialMandir!.actualValue
          },
          headers,
          context);
      if (response['errorCode'] == 0) {
        showCustomSnackbar(
          context,
          Colors.black,
          response['message'],
        );
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return MyFamilyList(code: '');
        }), (route) => false);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  getCurrentAddressAndMandir(var areaList, var mandirList) async {
    try {
      var response = await ApiService().post('/api/family-group/item',
          {"familyGroupCode": widget.groupCode}, headers, context);
      print(response);
      setState(() {
        addressController.text = response[0]['address'];
        var initialAreaValue = response[0]['areaCode'];
        var initialMandirValue = response[0]['mandirCode'];
        initialArea = areaList
            .firstWhere((element) => element.actualValue == initialAreaValue);
        initialMandir = mandirList
            .firstWhere((element) => element.actualValue == initialMandirValue);
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  getAreaAndMandirList() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await ApiService().post(
        '/api/master-data/area/list',
        {},
        headers,
        context,
      );
      var areaItems = (response as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['name'],
              actualValue: apiItem['code'],
            ),
          )
          .toList();
      setState(() {
        areaItemss = areaItems;
        areaOptionsButton = areaItems
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

        getMandirList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getMandirList() async {
    try {
      var response = await ApiService().post(
        '/api/master-data/mandir-ji/list',
        {},
        headers,
        context,
      );
      var mandirItems = (response as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['name'],
              actualValue: apiItem['mandirCode'],
            ),
          )
          .toList();
      setState(() {
        mandirOptionsButton = mandirItems
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
      });
      getCurrentAddressAndMandir(areaItemss, mandirItems);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Address',
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextAreaField(
                      labelText: 'Address',
                      controller: addressController,
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Note: Please enter your full address here.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField(
                      hint: const Text("Select an Area"),
                      value: initialArea,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Area',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: areaOptionsButton,
                      onChanged: (APIDropDownItem? item) {
                        setState(() {
                          initialArea = item!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField(
                      isExpanded: true,
                      isDense: false,
                      hint: const Text("Select Mandir Ji"),
                      value: initialMandir,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Near by Jain Mandir',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: mandirOptionsButton,
                      onChanged: (APIDropDownItem? item) {
                        setState(() {
                          initialMandir = item!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              updateAddress();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              fixedSize: const Size(170, 40),
                              backgroundColor: const Color.fromARGB(
                                255,
                                106,
                                78,
                                179,
                              ),
                            ),
                            child: const Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
