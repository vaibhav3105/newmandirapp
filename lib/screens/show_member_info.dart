// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mandir_app/services/docs_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/api_service.dart';
import '../services/advertisementService.dart';
import '../utils/utils.dart';
import '../widgets/advertisement.dart';
import '../widgets/custom_textfield.dart';
import 'editScreen.dart';
import 'loginInfo.dart';
import 'myFamilyList.dart';

class ShowMemberInfo extends StatefulWidget {
  final String memberCode;
  const ShowMemberInfo({
    Key? key,
    required this.memberCode,
  }) : super(key: key);

  @override
  State<ShowMemberInfo> createState() => _ShowMemberInfoState();
}

class _ShowMemberInfoState extends State<ShowMemberInfo> {
  var advertisementResponse = [];
  getRandomAdvertisement() async {
    try {
      var response =
          await AdvertisementService().getRandomAdvertisement(context);
      setState(() {
        advertisementResponse = response;
      });
      print(response);
    } catch (e) {}
  }

  Uint8List? _byteImage;
  File? imageFile;
  final remarkController = TextEditingController();
  List<dynamic> memberInfo = [];
  String mobile = '';
  String email = '';
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getProfilePic();
    getRandomAdvertisement();
  }

  getProfilePic() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await DocsService().getDoc(widget.memberCode, context);
      Uint8List byteImage =
          const Base64Decoder().convert(response['fileBytes']);
      setState(() {
        _byteImage = byteImage;
      });
    } catch (e) {}

    getMemberInfo();
  }

  var menus = [];
  bool? containsUpdateProfilePhoto = false;

  void getMemberInfo() async {
    var response = await ApiService().post2(
      context,
      "/api/family-member/view-info",
      {'familyMemberCode': widget.memberCode},
      headers,
    );

    bool? flag;
    var data = [];
    if (response.success == true && response.data.length > 0) {
      menus = response.data['menu'];
      flag = menus.any((item) => item['menu'] == 'UPDATE_PROFILE_PHOTO');

      var cats = List.from(Set.from(response.data['data'].map((e) => e['c'])));
      for (var cat in cats) {
        var item = {"cat": cat};
        item['items'] =
            response.data['data'].where((x) => x['c'] == cat).toList();
        data.add(item);
      }

      mobile = response.data['otherInfo'][0]['mobileText'];
      email = response.data['otherInfo'][0]['emailText'];
    }

    setState(() {
      memberInfo = data;
      isLoading = false;
      containsUpdateProfilePhoto = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: advertisementResponse.isNotEmpty
          ? AdvertisementBanner(
              title: advertisementResponse[0]['title'],
              subTitle: advertisementResponse[0]['subTitle'],
              url: advertisementResponse[0]['url'],
              mobile: advertisementResponse[0]['mobile'],
            )
          : null,
      // bottomNavigationBar: const AdvertisementBanner(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              fnShowBottomSheet(context, menus);
            },
            icon: const Icon(
              Icons.more_vert,
            ),
          )
        ],
        title: const Text("Details"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: Theme.of(context).primaryColor,
                        child: Image.asset(
                          'assets/images/network.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Stack(
                        children: [
                          Positioned(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 90,
                                    backgroundImage: _byteImage != null
                                        ? MemoryImage(
                                            _byteImage!,
                                          )
                                        : const AssetImage(
                                                'assets/images/person.jpeg')
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // const Positioned(
                          //   right: 140,
                          //   top: 150,
                          //   child: CircleAvatar(
                          //     backgroundColor: Colors.blue,
                          //     child: Icon(
                          //       FontAwesomeIcons.pencil,
                          //       size: 20,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                      if (containsUpdateProfilePhoto == true)
                        Positioned(
                          right: MediaQuery.of(context).size.width / 3.5,
                          top: 150,
                          child: GestureDetector(
                            onTap: () async {
                              Map<Permission, PermissionStatus> statuses =
                                  await [
                                // Permission.storage,
                                Permission.camera
                              ].request();

                              if (statuses[Permission.camera]!.isGranted) {
                                showImagePicker(context);
                              }
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                FontAwesomeIcons.pencil,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                                  text: memberInfo[outerIndex]
                                                          ['items'][innerIndex]
                                                      ['v'],
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
                ],
              ),
            ),
    );
  }

  void fnShowBottomSheet(BuildContext context, menuItems) {
    print(menuItems.length);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              child: Center(
                child: Container(
                  height: 6,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(
                          0.7,
                        ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "     Select an action",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(
              height: menuItems.length * 60.0,
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final menuItem = menuItems[index];
                  String title = '';
                  Function? onTap;
                  Icon? icon;

                  // Assign titles and functions based on menu item
                  if (menuItem['menu'] == 'SHOW_CALL') {
                    title = 'Make Call';
                    icon = Icon(
                      FontAwesomeIcons.phone,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () async {
                      // Implement the call functionality here

                      Navigator.pop(context);
                      await launchUrl(
                        Uri(scheme: 'tel', path: mobile),
                      );
                    };
                  } else if (menuItem['menu'] == 'SHOW_WHATSAPP') {
                    title = 'Send WhatsApp';
                    icon = Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    );
                    onTap = () async {
                      // Implement the WhatsApp functionality here

                      Navigator.pop(context);
                      await launchUrl(
                          Uri(scheme: 'https', path: 'wa.me/$mobile'),
                          mode: LaunchMode.externalApplication);
                    };
                  } else if (menuItem['menu'] == 'SHOW_EMAIL') {
                    title = 'Send Email';
                    icon = Icon(
                      FontAwesomeIcons.solidEnvelope,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () async {
                      // Implement the email functionality here

                      Navigator.pop(context);
                      await launchUrl(
                        Uri(scheme: 'mailto', path: email),
                      );
                    };
                  } else if (menuItem['menu'] == "VIEW_FAMILY") {
                    title = 'View Family';
                    icon = Icon(
                      FontAwesomeIcons.userGroup,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () {
                      Navigator.pop(context);
                      nextScreen(
                        context,
                        MyFamilyList(
                          code: widget.memberCode,
                        ),
                      );
                    };
                  } else if (menuItem['menu'] == "EDIT_MEMBER") {
                    title = 'Edit Member';
                    icon = Icon(
                      FontAwesomeIcons.pencil,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () {
                      Navigator.pop(context);
                      nextScreen(
                        context,
                        EditScreen(
                          groupCode: '',
                          membercode: widget.memberCode,
                        ),
                      );
                    };
                  } else if (menuItem['menu'] == "DELETE_MEMBER") {
                    title = 'Delete Member';
                    icon = Icon(
                      FontAwesomeIcons.trash,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () {
                      // Implement the email functionality here

                      Navigator.pop(context);
                      remarkController.text = '';
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Delete Member",
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    var response = await ApiService().post(
                                      '/api/family-member/delete',
                                      {
                                        "familyMemberCode": widget.memberCode,
                                        'remark': remarkController.text.trim()
                                      },
                                      headers,
                                      context,
                                    );
                                    if (response['errorCode'] == 0) {
                                      Navigator.pop(context);
                                      remarkController.text = '';
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
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Are you sure you want to delete this member?",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 13,
                                  ),
                                  CustomTextAreaField(
                                    labelText: "Please enter a remark",
                                    controller: remarkController,
                                  )
                                ],
                              ),
                            );
                          });
                    };
                  } else if (menuItem['menu'] == "SHOW_LOGIN_INFO") {
                    title = 'Show Login Info';
                    icon = Icon(
                      FontAwesomeIcons.key,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () {
                      // Implement the email functionality here

                      Navigator.pop(context);
                      nextScreen(
                        context,
                        LoginInfo(
                          familyMemberCode: widget.memberCode,
                          familyGroupCode: '',
                        ),
                      );
                    };
                  } else if (menuItem['menu'] == "UPDATE_PROFILE_PHOTO") {
                    title = 'Update Profile Photo';
                    icon = Icon(
                      FontAwesomeIcons.image,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () async {
                      Map<Permission, PermissionStatus> statuses = await [
                        // Permission.storage,
                        Permission.camera
                      ].request();
                      print('object');
                      if (statuses[Permission.camera]!.isGranted) {
                        Navigator.pop(context);
                        print('object');
                        showImagePicker(context);
                      }
                    };
                  }

                  // Add more menu items as needed

                  return ListTile(
                    title: Text(title),
                    onTap: () {
                      onTap!();
                    },
                    leading: icon,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  final picker = ImagePicker();

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: InkWell(
                      child: Column(
                        children: [
                          CircleAvatar(
                            // backgroundColor: Color(0xff35769F),
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 40,
                            child: const Icon(
                              FontAwesomeIcons.image,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            "Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[800]),
                          )
                        ],
                      ),
                      onTap: () {
                        _imgFromGallery();
                        // Navigator.pop(context);
                      },
                    )),
                    Expanded(
                        child: InkWell(
                      child: SizedBox(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              // backgroundColor: Color(0xff662E57),
                              backgroundColor: Color(0xff35769F),
                              radius: 40,
                              child: Icon(
                                FontAwesomeIcons.camera,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              "Camera",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[800]),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        _imgFromCamera();
                        // Navigator.pop(context);
                      },
                    ))
                  ],
                ),
              ));
        });
  }

  _imgFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
        compressQuality: 90,
        sourcePath: imgFile.path,
        aspectRatio: const CropAspectRatio(
          ratioX: 1.0,
          ratioY: 1.0,
        ),
        maxHeight: 300,
        maxWidth: 300,
        // aspectRatioPresets: Platform.isAndroid
        //     ? [
        //         CropAspectRatioPreset.square,
        //         // CropAspectRatioPreset.ratio3x2,
        //         // CropAspectRatioPreset.original,
        //         // CropAspectRatioPreset.ratio4x3,
        //         // CropAspectRatioPreset.ratio16x9
        //       ]
        //     : [
        //         // CropAspectRatioPreset.original,
        //         CropAspectRatioPreset.square,
        //         // CropAspectRatioPreset.ratio3x2,
        //         // CropAspectRatioPreset.ratio4x3,
        //         // CropAspectRatioPreset.ratio5x3,
        //         // CropAspectRatioPreset.ratio5x4,
        //         // CropAspectRatioPreset.ratio7x5,
        //         // CropAspectRatioPreset.ratio16x9
        //       ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop your image",
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            // lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: "Crop your image",
          )
        ]);
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        imageFile = File(croppedFile.path);
      });
      Navigator.of(context).pop();
      try {
        var response = await DocsService()
            .uploadDoc(context, widget.memberCode, 'PROFILE_PHOTO', imageFile!);
        if (response['errorCode'] == 0) {
          showCustomSnackbar(
            context,
            Colors.black,
            response['message'],
          );
          getProfilePic();
        }
      } catch (e) {}
    }
  }
}
