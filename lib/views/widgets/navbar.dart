import 'package:app/views/pages/account_page.dart';
import 'package:app/views/pages/libary_page.dart';
import 'package:app/views/pages/search_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../view_models/user_provider.dart';

import '../pages/favorite_pages/favorite_song_page.dart';


UserProvider userProvider = UserProvider();

class NavBar1 extends StatelessWidget {
  const NavBar1({super.key});

  get isLoggedIn => false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userProvider
          .getDocCurrentUser(FirebaseAuth.instance.currentUser?.uid),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return CircularProgressIndicator();
        // }
        return Drawer(
          child: ListView(
            // padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userProvider.currentUser.fullname!),
                accountEmail: Text(userProvider.currentUser.email!),
                currentAccountPicture: CircleAvatar(
                  child: ClipOval(
                    child: userProvider.currentUser.img!.isNotEmpty
                        ? Image.network(
                            userProvider.currentUser.img!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/images/apple.png",
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // decoration: BoxDecoration(
                //   color: Colors.blue,
                //   image: DecorationImage(
                //       image: AssetImage(
                //         'assets/images/app_logo.png',
                //       ),
                //       fit: BoxFit.cover),
                // ),
              ),
              ListTile(
                leading: Icon(Icons.grid_view_rounded),
                title: Text("Libary"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LibraryPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text("Favorite Songs"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoritePage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text("Search"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text("Account"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccountPage()));
                },
              ),
              const Divider(),
              // ListTile(
              //   leading: Icon(Icons.settings),
              //   title: Text("Settings"),
              //   onTap: () => const FavoritePage(),
              // ),
              // ListTile(
              //   leading: Icon(Icons.description),
              //   title: Text("Policies"),
              //   onTap: () => const FavoritePage(),
              // ),
              // Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Logout"),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              try {
                                await FirebaseAuth.instance.signOut();
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove('idUser');

                                userProvider.currentTrackId = null;
                                userProvider.trackList = [];

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.blueAccent,
                                    content: Text(
                                      "Logout Successfully!",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyApp(
                                      isLoggedIn: false,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                Fluttertoast.showToast(
                                  msg: "Error ${e.toString()}!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            },
                            child: Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
