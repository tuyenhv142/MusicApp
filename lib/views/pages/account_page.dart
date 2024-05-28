import 'package:app/views/pages/edit_profile_page.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../view_models/user_provider.dart';

import '../widgets/profile_menu.dart';
import 'forget_password_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

UserProvider userProvider = UserProvider();

class _AccountPageState extends State<AccountPage> {
  bool isLoggedIn = false;
  String? username;
  String? email;
  String? img;
  // bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    await userProvider
        .getDocCurrentUser(FirebaseAuth.instance.currentUser?.uid);
    // setState(() {
    //   _isLoading = false;
    // });
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.delete();

                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(user.uid)
                        .delete();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print("Error deleting account: $e");
                  }
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    if (userProvider.currentUser.idUser != null &&
        userProvider.currentUser.fullname != null &&
        userProvider.currentUser.email != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: Theme.of(context).textTheme.headline4,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: userProvider.currentUser.img!.isNotEmpty
                            ? Image.network(
                                userProvider.currentUser.img!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/images/apple.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.yellow),
                        child: const Icon(
                          LineAwesomeIcons.alternate_pencil,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  userProvider.currentUser.fullname!,
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(
                  userProvider.currentUser.email!,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        side: BorderSide.none,
                        shape: const StadiumBorder()),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                ProfileMenuWidget(
                  title: "Information",
                  icon: LineAwesomeIcons.info,
                  onPress: () {},
                ),
                ProfileMenuWidget(
                  title: "Change Password",
                  icon: LineAwesomeIcons.lock,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPassword(),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
                ProfileMenuWidget(
                  title: "Delete Account",
                  icon: LineAwesomeIcons.remove_user,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () {
                    _deleteAccount();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: Theme.of(context).textTheme.headline4,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
            )
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
