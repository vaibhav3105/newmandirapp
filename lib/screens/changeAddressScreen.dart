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

  List<DropdownMenuItem<APIDropDownItem>> areaOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  final addressController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAreaList();
  }

  updateAddress() async {
    try {
      var response = await ApiService().post(
          '/api/family-group/update-address',
          {
            "familyGroupCode": widget.groupCode,
            "areaCode": initialArea!.actualValue,
            "address": addressController.text.trim()
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

  getCurrentAddress(var areaList) async {
    try {
      var response = await ApiService().post('/api/family-group/item',
          {"familyGroupCode": widget.groupCode}, headers, context);
      print(response);
      setState(() {
        addressController.text = response[0]['address'];
        var initialAreaValue = response[0]['areaCode'];

        initialArea = areaList
            .firstWhere((element) => element.actualValue == initialAreaValue);
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  getAreaList() async {
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
        getCurrentAddress(areaItems);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Address',
        ),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                labelText: 'Address',
                controller: addressController,
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
