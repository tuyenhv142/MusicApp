import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> signInWithGoogle() async {
    bool result = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection("user").doc(user.uid).get();

        if (!userSnapshot.exists) {
          UserModel userModel = UserModel(
            idUser: user.uid,
            fullname: user.displayName ?? '',
            email: user.email ?? '',
            img: user.photoURL ?? '',
            dateEnter: DateTime.now().toString(),
          );

          await _firestore
              .collection("user")
              .doc(user.uid)
              .set(userModel.toFirestore());
        } else {
          await _firestore.collection("user").doc(user.uid).update({
            'fullname': user.displayName,
            'img': user.photoURL,
            'email': user.email,
            // 'dataEnter': user.,
          });
        }
        result = true;
      }
      return result;
    } catch (e) {
      print(e);
    }
    return result;
  }
}

class AuthUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> saveCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('idUser', userId);
    }
  }

  static Future<String?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  static Future<void> removeCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('idUser');
  }
}
