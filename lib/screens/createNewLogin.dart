import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/utils/app_enums.dart';
import 'package:mandir_app/utils/utils.dart';
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
  APIDropDownItem? initialCountry;
  APIDropDownItem? initialState;
  APIDropDownItem? initialCity;
  List<DropdownMenuItem<APIDropDownItem>> CountryDropDownList =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> StateDropDownList =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> CityDropDownList =
      <DropdownMenuItem<APIDropDownItem>>[];
  bool gotResponse = false;
  FocusNode loginNameFocus = FocusNode();

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
    getCountryList();
  }

  getCountryList() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await ApiService().post2(
        context,
        '/api/master-data/country/list',
        {},
        headers,
      );
      List<APIDropDownItem> result = [];
      if (response.success == true && response.data.length > 0) {
        result = (response.data as List<dynamic>)
            .map(
              (apiItem) => APIDropDownItem(
                displayText: apiItem['name'],
                actualValue: apiItem['id'].toString(),
              ),
            )
            .toList();
      }

      var countryDropDownList = result
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
      setState(() {
        CountryDropDownList = countryDropDownList;
        // initialCountry = result[0];
        // getStateList();
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getStateList() async {
    // setState(() {
    //   isLoading = true;
    // });
    try {
      var response = await ApiService().post2(
        context,
        '/api/master-data/state/list',
        {'countryId': initialCountry!.actualValue},
        headers,
      );
      List<APIDropDownItem> result = [];
      if (response.success == true && response.data.length > 0) {
        result = (response.data as List<dynamic>)
            .map(
              (apiItem) => APIDropDownItem(
                displayText: apiItem['name'],
                actualValue: apiItem['id'].toString(),
              ),
            )
            .toList();
      }

      var stateDropDownList = result
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
      setState(() {
        StateDropDownList = stateDropDownList;
        // isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getCityList() async {
    // setState(() {
    //   isLoading = true;
    // });
    try {
      var response = await ApiService().post2(
        context,
        '/api/master-data/city/list',
        {'stateId': initialState!.actualValue},
        headers,
      );
      List<APIDropDownItem> result = [];
      if (response.success == true && response.data.length > 0) {
        result = (response.data as List<dynamic>)
            .map(
              (apiItem) => APIDropDownItem(
                displayText: apiItem['name'],
                actualValue: apiItem['id'].toString(),
              ),
            )
            .toList();
      }

      var cityDropDownList = result
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
      setState(() {
        CityDropDownList = cityDropDownList;
        // isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  createMember() async {
    try {
      var response = await ApiService().post2(
        context,
        '/api/family-member/create-with-login',
        {
          'loginName': loginNameController.text.trim(),
          'name': memberNameController.text.trim(),
          'mobile': mobileController.text.trim(),
          'address': addressController.text.trim(),
          'countryId':
              initialCountry == null ? null : initialCountry!.actualValue,
          'stateId': initialState == null ? null : initialState!.actualValue,
          'cityId': initialCity == null ? null : initialCity!.actualValue,
        },
        headers,
      );

      if (response.success == false) {
        ApiService().handleApiResponse2(context, response.data);
        return;
      }
      var cats = List.from(Set.from(response.data.map((e) => e['c'])));
      var data = [];
      for (var cat in cats) {
        var item = {"cat": cat};
        item['items'] = response.data.where((x) => x['c'] == cat).toList();
        data.add(item);
      }
      setState(() {
        memberInfo = data;
        gotResponse = true;
      });
    } catch (e) {
      print(e.toString());
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
                          const Text('Login Name'),
                          const SizedBox(
                            height: 5,
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
                              labelText: '',
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
                            height: 20,
                          ),
                          const Text('Famly Member Name'),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextField(
                            controller: memberNameController,
                            labelText: '',
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
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('Country'),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownButtonFormField(
                            isExpanded: true,
                            hint: const Text("Select a country"),
                            value: initialCountry,
                            decoration: textInputDecoration.copyWith(
                              labelText: '',
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: CountryDropDownList,
                            onChanged: (APIDropDownItem? item) {
                              setState(() {
                                initialCountry = item!;

                                initialState = null;
                                initialCity = null;
                                StateDropDownList.clear();
                                CityDropDownList.clear();
                              });
                              getStateList();
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('State'),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownButtonFormField(
                            isExpanded: true,
                            hint: const Text("Select a state"),
                            value: initialState,
                            decoration: textInputDecoration.copyWith(
                              labelText: '',
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: StateDropDownList,
                            onChanged: (APIDropDownItem? item) {
                              setState(() {
                                initialState = item!;

                                initialCity = null;
                                CityDropDownList.clear();
                              });
                              getCityList();
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('City'),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownButtonFormField(
                            isExpanded: true,
                            hint: const Text("Select a city"),
                            value: initialCity,
                            decoration: textInputDecoration.copyWith(
                              labelText: '',
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: CityDropDownList,
                            onChanged: (APIDropDownItem? item) {
                              setState(() {
                                initialCity = item!;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('Address'),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextAreaField(
                            labelText: '',
                            controller: addressController,
                          ),
                          const SizedBox(
                            height: 20,
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
                          const SizedBox(
                            height: 20,
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
