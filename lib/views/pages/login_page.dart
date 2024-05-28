import 'package:app/views/pages/forget_password_page.dart';
import 'package:app/views/pages/myhome_page.dart';

import 'package:app/views/pages/signup_page.dart';
import 'package:app/view_models/auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool loading = false;

  bool _obscureText = true;

  String email = "";
  String password = "";

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      email = _emailTextController.text.trim();
      password = _passwordTextController.text;

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueAccent,
            content: Text(
              "Login Successfully",
              style: TextStyle(fontSize: 20),
            ),
          ),
        );

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("idUser", userCredential.user!.uid);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "No User Found for that Email",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Wrong Password",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Account or Password is incorrect. Please check again!",
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
              "An error occurred while logging in. Please try again later.",
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      } finally {
        setState(
          () {
            loading = false;
          },
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: loading
          ? Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: LoadingAnimationWidget.beat(
                      color: Colors.black,
                      size: 50,
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                if (value == null ||
                                    value.isEmpty ||
                                    !isEmailValid(value)) {
                                  return 'Please Check Your Email';
                                }
                                return null;
                              },
                              controller: _emailTextController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_2_outlined),
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
                                    setState(
                                      () {
                                        _obscureText = !_obscureText;
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.remove_red_eye_sharp),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    builder: (context) => Container(
                                      padding: const EdgeInsets.all(30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Make Selection!",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                          Text(
                                            "Select one of the options given below to reset your password.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ForgetPassword(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey.shade300,
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.mail_outline_rounded,
                                                    size: 60,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "E-Mail",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6,
                                                      ),
                                                      Text(
                                                        "Reset via Mail Verification.",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Forget Password?"),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      email = _emailTextController.text;
                                      password = _passwordTextController.text;
                                    });
                                  }
                                  userLogin();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                ),
                                child: const Text(
                                  "LOGIN",
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
                            onPressed: () async {
                              bool loggedIn =
                                  await AuthMethods().signInWithGoogle();
                              if (loggedIn) {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('idUser', user.uid);
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyHomePage(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.blueAccent,
                                    content: Text(
                                      "Login Successfully!",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Login error. Please try again!",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                              }
                            },
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
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an Account?",
                              style: Theme.of(context).textTheme.bodyText1,
                              children: const [
                                TextSpan(
                                  text: " Register",
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: const AssetImage("assets/images/logo3.png"),
          height: size.height * 0.2,
        ),
        const Text(
          "Welcome Back,",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        ),
        const Text(
          "Helps you have moments of relaxation.",
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
