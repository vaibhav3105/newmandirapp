import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';

import '../service/api_service.dart';
import '../utils/styling.dart';
import 'editScreen.dart';

class CreateNewLogin extends StatefulWidget {
  const CreateNewLogin({super.key});

  @override
  State<CreateNewLogin> createState() => _CreateNewLoginState();
}

class _CreateNewLoginState extends State<CreateNewLogin> {
  bool gotResponse = false;
  FocusNode loginNameFocus = FocusNode();
  APIDropDownItem? initialArea;
  APIDropDownItem? initialMandir;
  List<DropdownMenuItem<APIDropDownItem>> areaOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> mandirOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  final loginNameController = TextEditingController();
  final memberNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = false;
  bool? loginNameAvailable;
  List<dynamic> memberInfo = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginNameFocus.addListener(() {
      if (loginNameFocus.hasFocus) {
        print("Textfield one got focused.");
      } else {
        checkLoginNameAvailability();
      }
    });
    getAreaAndMandirList();
  }

  createMember() async {
    try {
      var response = await ApiService().post(
        '/api/family-member/create-with-login',
        {
          'loginName': loginNameController.text.trim(),
          'name': memberNameController.text.trim(),
          'mobile': mobileController.text.trim(),
          'address': addressController.text.trim(),
          'areaCode': initialArea!.actualValue,
          'mandirCode': initialMandir!.actualValue
        },
        headers,
        context,
      );

      var cats = List.from(Set.from(response.map((e) => e['c'])));
      var data = [];
      for (var cat in cats) {
        var item = {"cat": cat};
        item['items'] = response.where((x) => x['c'] == cat).toList();
        data.add(item);
      }
      setState(() {
        memberInfo = data;
        gotResponse = true;
      });
    } catch (e) {
      // print(e.toString());
    }
  }

  checkLoginNameAvailability() async {
    try {
      var response = await ApiService().post(
        '/api/account/check-availability',
        {'loginName': loginNameController.text.trim()},
        headers,
        context,
      );

      setState(() {
        loginNameAvailable = response;
      });
      print(loginNameAvailable);
    } catch (e) {
      print(e.toString());
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
        initialArea = areaItems[0];

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
        initialMandir = mandirItems[0];
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gotResponse == false ? Colors.white : null,
      appBar: AppBar(
        title: gotResponse == true
            ? const Text("Member Details")
            : const Text('Create New Login'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : gotResponse == false
              ? SingleChildScrollView(
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
                              suffixIcon: loginNameAvailable == null
                                  ? null
                                  : loginNameAvailable == true
                                      ? const Icon(
                                          FontAwesomeIcons.circleCheck,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          FontAwesomeIcons.circleXmark,
                                          color: Colors.red,
                                        ),
                              focus: loginNameFocus,
                              labelText: 'Login Name',
                              controller: loginNameController),
                          const SizedBox(
                            height: 5,
                          ),
                          if (loginNameAvailable == null)
                            const Text(
                              'Please enter a unique login name.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          if (loginNameAvailable != null)
                            Text(
                              loginNameAvailable == true
                                  ? "Login name is available, please proceed."
                                  : 'Login name already taken.',
                              style: TextStyle(
                                color: loginNameAvailable == true
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(
                            height: 17,
                          ),
                          CustomTextField(
                            controller: memberNameController,
                            labelText: 'Family Member Name',
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
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomTextAreaField(
                            labelText: 'Residential Address',
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
                          DropdownButtonFormField(
                            isExpanded: true,
                            isDense: false,
                            hint: const Text("Select Mandir Ji"),
                            value: initialMandir,
                            decoration: textInputDecoration.copyWith(
                              labelText: 'Nearby Jain Mandir',
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
                            height: 30,
                          ),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  createMember();
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
                                child: const Text(
                                  "Create",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: memberInfo.length,
                        itemBuilder: (context, outerIndex) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  memberInfo[outerIndex]['cat'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin: EdgeInsets.zero,
                                  color: Colors.white,
                                  child: Column(
                                    children: List.generate(
                                      memberInfo[outerIndex]['items'].length,
                                      (innerIndex) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                memberInfo[outerIndex]['items']
                                                    [innerIndex]['k'],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              // trailing: FaIcon(
                                              //   FontAwesomeIcons.angleRight,
                                              //   color: Colors.grey[600],
                                              // ),
                                              subtitle: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          memberInfo[outerIndex]
                                                                  ['items']
                                                              [innerIndex]['v'],
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Divider(
                                                height: 0,
                                                thickness: 1,
                                                color: Color(0xFFF0F1F3),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
