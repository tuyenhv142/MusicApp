import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/navbar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late String _fullName;
  late String _email;
  late String _imageUrl;
  late String _dateEnter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      if (userSnapshot.exists) {
        setState(() {
          _fullName = userSnapshot['fullname'];
          _email = userSnapshot['email'];
          _imageUrl = userSnapshot['img'];
          _dateEnter = userSnapshot['dateEnter'];
          _isLoading = false;
        });
      }
    }
  }

  File? _pickedImage;

  // XFile? _image;
  final picker = ImagePicker();

  Future<String> _uploadImage({required File image}) async {
    String urlImage = '';

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String idUser = user.uid;
      Reference storageReference = FirebaseStorage.instance.ref().child(
          "UserImage/$idUser/${DateTime.now().millisecondsSinceEpoch}.jpg");

      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.whenComplete(() => null);

      urlImage = await storageReference.getDownloadURL();
    }

    return urlImage;
  }

  Future<void> getImage({required ImageSource source}) async {
    XFile? imageFile = await picker.pickImage(source: source);
    if (imageFile != null) {
      setState(() {
        _pickedImage = File(imageFile.path);
      });

      String downloadUrl = await _uploadImage(image: _pickedImage!);
      setState(() {
        _imageUrl = downloadUrl;
      });
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String updateEmail = _email.trim();
      String updateFullName = _fullName.trim();

      bool hasNewImage = _pickedImage != null;

      if (hasNewImage || updateEmail.isNotEmpty || updateFullName.isNotEmpty) {
        try {
          String downloadUrl = _imageUrl;
          if (hasNewImage) {
            downloadUrl = await _uploadImage(image: _pickedImage!);
          }

          await FirebaseFirestore.instance
              .collection("user")
              .doc(user.uid)
              .update({
            'email': updateEmail.isNotEmpty ? updateEmail : _email,
            'fullname': updateFullName.isNotEmpty ? updateFullName : _fullName,
            'img': downloadUrl,
          });

          if (updateEmail.isNotEmpty) {
            await user.updateEmail(updateEmail);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Information updated')),
          );
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update Error: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes made')),
        );
      }
    }
  }

  Future<void> myDialogBox(context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Pick Form Camera"),
                  onTap: () {
                    getImage(source: ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Pick Form Gallery"),
                  onTap: () {
                    getImage(source: ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headline4,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: _pickedImage == null
                                ? userProvider.currentUser.img!.isNotEmpty
                                    ? FadeInImage(
                                        fit: BoxFit.fill,
                                        placeholder: const AssetImage(
                                          'assets/icons/google.png',
                                        ),
                                        image: NetworkImage(_imageUrl),
                                      )
                                    : const Image(
                                        image: AssetImage(
                                          'assets/icons/google.png',
                                        ),
                                      )
                                : Image(
                                    image: FileImage(_pickedImage!),
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              myDialogBox(context);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.yellow,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Form(
                      child: Column(
                        children: [
                          // Text(
                          //   _email,
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          //
                          // SizedBox(height: 20,),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Fullname",
                              prefixIcon: Icon(Icons.person),
                            ),
                            initialValue: _fullName,
                            onChanged: (value) {
                              setState(() {
                                _fullName = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                            ),
                            initialValue: _email,
                            onChanged: (value) {
                              setState(() {
                                // _email = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Joined",
                            style: const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: " $_dateEnter",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
