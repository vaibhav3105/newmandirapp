// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/app_enums.dart';
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
  APIDropDownItem? initialCountry;
  APIDropDownItem? initialState;
  APIDropDownItem? initialCity;
  var EditData = [];
  bool isLoading = false;

  bool countryUpdated = false;
  bool stateUpdated = false;
  bool cityUpdated = false;

  List<DropdownMenuItem<APIDropDownItem>> CountryDropDownList =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> StateDropDownList =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> CityDropDownList =
      <DropdownMenuItem<APIDropDownItem>>[];

  final addressController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getAreaAndMandirList();
    if (widget.groupCode.isNotEmpty) {
      getCurrentAddress();
      print(EditData);
    } else {
      getCountryList();
    }
  }

  updateAddress() async {
    try {
      var response = await ApiService().post2(
        context,
        '/api/family-group/save',
        {
          "familyGroupCode": widget.groupCode == '' ? null : widget.groupCode,
          "address": addressController.text.trim(),
          'countryId': initialCountry != null
              ? int.parse(initialCountry!.actualValue!)
              : null,
          'stateId': initialState != null
              ? int.parse(initialState!.actualValue!)
              : null,
          'cityId':
              initialCity != null ? int.parse(initialCity!.actualValue!) : null,
        },
        headers,
      );
      if (response.success == false) {
        ApiService().handleApiResponse2(context, response.data);
        return;
      }
      showToast(context, ToastTypes.SUCCESS, "Address Updated Successfully");

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return MyFamilyList(code: '');
      }), (route) => false);
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  String makeLabel(APIDropDownItem? country, APIDropDownItem? state,
      APIDropDownItem? city, String? address) {
    String? countryLabel;
    String? stateLabel;
    String? cityLabel;
    if (country == null) {
      countryLabel = '';
    } else {
      countryLabel = country.displayText;
    }
    if (state == null) {
      stateLabel = '';
    } else {
      stateLabel = state.displayText;
    }
    if (city == null) {
      cityLabel = '';
    } else {
      cityLabel = city.displayText;
    }
    return '$address, $cityLabel, $stateLabel, $countryLabel';
  }

  getCurrentAddress() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await ApiService().post2(
        context,
        '/api/family-group/item',
        {"familyGroupCode": widget.groupCode},
        headers,
      );
      if (response.success == false) {
        ApiService().handleApiResponse2(context, response.data);
        setState(() {
          isLoading = false;
        });
        return;
      }
      setState(() {
        EditData = response.data;
        isLoading = false;
        addressController.text = EditData[0]['address'];
        // addressController.text = response[0]['address'];
        // var initialAreaValue = response[0]['areaCode'];
        // var initialMandirValue = response[0]['mandirCode'];
        // initialArea = areaList
        //     .firstWhere((element) => element.actualValue == initialAreaValue);
        // initialMandir = mandirList
        //     .firstWhere((element) => element.actualValue == initialMandirValue);
      });
      getCountryList();
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  void _handleCountryChange() {
    setState(() {
      initialState = null;
      initialCity = null;
      StateDropDownList.clear();
      CityDropDownList.clear();
      getStateList();
    });
  }

  void _handleStateChange() {
    setState(() {
      initialCity = null;
      CityDropDownList.clear();
      getCityList();
    });
  }

  void _handleCityChange() {
    setState(() {});
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
      if (EditData.isNotEmpty && countryUpdated == false) {
        initialCountry = result.firstWhere((element) =>
            element.actualValue == EditData[0]['countryId'].toString());
        _handleCountryChange();
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
        initialCountry = result[0];
        getStateList();
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
      if (EditData.isNotEmpty &&
          countryUpdated == false &&
          EditData[0]['stateId'] != null) {
        initialState = result.firstWhere((element) =>
            element.actualValue == EditData[0]['stateId'].toString());
        _handleStateChange();
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
      if (EditData.isNotEmpty &&
          stateUpdated == false &&
          EditData[0]['cityId'] != null) {
        print(EditData);
        initialCity = result.firstWhere((element) =>
            element.actualValue == EditData[0]['cityId'].toString());
        _handleCityChange();
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
                        height: 30,
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
                            countryUpdated = true;
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
                            stateUpdated = true;
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
                            cityUpdated = true;
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
                        onChanged: (p0) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'Note: Please enter your house no, floor, street, sector, etc.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text('Your full address will be:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).primaryColor,
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      if (addressController.text.isNotEmpty)
                        Text(
                            makeLabel(
                              initialCountry,
                              initialState,
                              initialCity,
                              addressController.text.trim(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                            )),
                      const SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                updateAddress();
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
                              child: Text(
                                widget.groupCode == '' ? 'Save' : "Update",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Note: if your city or state or country are not available, you can ask your mandir admin to add them.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
