import 'package:app/views/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../models/user_model.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _repasswordTextController =
      TextEditingController();
  final TextEditingController _fullnameTextController = TextEditingController();

  String email = "";
  String password = "";
  String fullname = "";

  final _formkey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _obscureText1 = true;

  signup() async {
    if (!isEmailValid(_emailTextController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Invalid email format",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
      return;
    }

    if (_formkey.currentState!.validate()) {
      if (_passwordTextController.text == _repasswordTextController.text) {
        email = _emailTextController.text.trim();
        password = _passwordTextController.text;
        fullname = _fullnameTextController.text;

        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Registered Successfully",
                style: TextStyle(fontSize: 20),
              ),
            ),
          );

          UserModel newUser = UserModel(
            idUser: userCredential.user!.uid,
            email: email,
            fullname: fullname,
            img:
                "https://lh3.googleusercontent.com/a/ACg8ocK0JSPCAXRu84zvrJD3P_f8j0mYwZR7yf4IbxP26UqC=s96-c",
            dateEnter: DateTime.now().toString(),
          );

          final docRef = FirebaseFirestore.instance
              .collection("user")
              .doc(userCredential.user!.uid);
          await docRef.set(newUser.toFirestore());

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("idUser", userCredential.user!.uid);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orangeAccent,
                content: Text(
                  "Password provided is too weak",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          } else if (e.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orangeAccent,
                content: Text(
                  "An account already exists for that email",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error: $e");
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "An error occurred while registering. Please try again later.",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Passwords do not match",
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      }
    }
  }

  bool isEmailValid(String email) {
    String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailRegex);
    return regExp.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _obscureText = true;
    _obscureText1 = true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoginHeader(size),
              Form(
                key: _formkey,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Name';
                          }
                          return null;
                        },
                        controller: _fullnameTextController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_2_outlined),
                          labelText: "Fullname",
                          hintText: "Fullname",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Email';
                          }
                          return null;
                        },
                        controller: _emailTextController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: "Email",
                          hintText: "E-mail",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        obscureText: _obscureText,
                        controller: _passwordTextController,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.fingerprint),
                            labelText: "Password",
                            hintText: "Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: const Icon(Icons.remove_red_eye_sharp),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Re-Password';
                          }
                          return null;
                        },
                        obscureText: _obscureText1,
                        controller: _repasswordTextController,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.fingerprint),
                            labelText: "Re-Password",
                            hintText: "Re-Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText1 = !_obscureText1;
                                });
                              },
                              icon: const Icon(Icons.remove_red_eye_sharp),
                            )),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = _emailTextController.text;
                                password = _passwordTextController.text;
                                fullname = _fullnameTextController.text;
                              });
                            }
                            signup();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              // side: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: const Text(
                            "SIGNUP",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("OR"),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                      ),
                      icon: const Image(
                        image: AssetImage("assets/images/google.png"),
                        width: 20,
                      ),
                      label: const Text(
                        "SIGN-IN WITH GOOGLE",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an Account?",
                        style: Theme.of(context).textTheme.bodyText1,
                        children: const [
                          TextSpan(
                            text: " Login",
                            style: TextStyle(color: Colors.blue),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Column LoginHeader(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          image: const AssetImage("assets/images/logo3.png"),
          height: size.height * 0.2,
        ),
        const Text(
          "Get On Board!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        ),
        const Text(
          "Create your profile to start your Music.",
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
