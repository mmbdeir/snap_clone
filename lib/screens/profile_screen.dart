import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snap_clone/widget/profile_widget.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _pickImageFile;
  String? _imageUrl;
  late String displayName = '';
  late String userName = '';

  bool isEditing = false;

  bool isLoadingDisplayName = false;
  bool isLoadingProfileImage = false;
  bool isLoadingUserName = false;

  var displayNameFocusNode = FocusNode();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  final User? signedUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadDisplayName();
    _loadUserName();

    displayNameController.text = displayName;
  }

  void _loadProfileImage() async {
    if (signedUser == null) {
      return;
    }

    try {
      final imageUrl = await FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${signedUser!.uid}.jpg')
          .getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
        isLoadingProfileImage = false;
      });
    } catch (error) {
      setState(() {
        isLoadingProfileImage = false;
      });
    }
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 150);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickImageFile = File(pickedImage.path);
    });

    final User? signedUser = FirebaseAuth.instance.currentUser;

    if (signedUser == null) {
      return;
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${signedUser.uid}.jpg');
    await storageRef.putFile(_pickImageFile!);

    _loadProfileImage();
  }

  void _loadUserName() async {
    setState(() {
      isLoadingUserName = true;
    });
    if (signedUser == null) {
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(signedUser!.uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      userName = data['username'] ?? '';
      setState(() {
        userNameController = TextEditingController(text: userName);
      });
    }
    setState(() {
      isLoadingUserName = false;
    });
  }

  void _loadDisplayName() async {
    setState(() {
      isLoadingDisplayName = true;
    });
    if (signedUser == null) {
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(signedUser!.uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      displayName = data['display_name'] ?? '';
      setState(() {
        displayNameController = TextEditingController(text: displayName);
      });
    }
    setState(() {
      isLoadingDisplayName = false;
    });
  }

  void _changeDisplayName(value) async {
    if (signedUser == null) {
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(signedUser!.uid)
        .update({'display_name': value});
  }

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEditing) {
          _changeDisplayName(displayNameController.text);
          setState(() {
            isEditing = false;
          });
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
            ),
            Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 50),
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 25),
                        child: Text(
                          'Tap to take image',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: Colors.grey[700]),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.only(top: 13),
                            width: 142,
                            height: 142,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(27),
                              ),
                              color: Colors.white,
                            ),
                            child: isLoadingProfileImage
                                ? const CircularProgressIndicator.adaptive()
                                : Container(
                                    child: _imageUrl != null
                                        ? Image.network(
                                            _imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Center(
                                            child: Text('Tap to take image',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge),
                                          ),
                                  )),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 150),
                        child: !isEditing
                            ? Container(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(displayNameController.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w300,
                                        )))
                            : TextField(
                                focusNode: displayNameFocusNode,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w300,
                                    ),
                                textAlign: TextAlign.center,
                                controller: displayNameController,
                                decoration: InputDecoration(
                                  suffix: isLoadingDisplayName
                                      ? const CircularProgressIndicator
                                          .adaptive()
                                      : null,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'Display Name',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.grey[600],
                                      ),
                                ),
                                onChanged: (value) {
                                  _changeDisplayName(value);
                                },
                              ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(userName),
                      const SizedBox(
                        height: 10,
                      ),
                      ProfileWidget(
                        onTap: () {
                          setState(() {
                            isEditing = !isEditing;
                          });
                          // if (isEditing) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            FocusScope.of(context)
                                .requestFocus(displayNameFocusNode);
                          });
                          // } else {
                          //   FocusScope.of(context).unfocus();
                          // }
                        },
                        icon: Icons.person_outlined,
                        text: 'Change username',
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
