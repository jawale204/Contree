import 'package:Contri/models/sharedpreferences.dart';
import 'package:Contri/screen/Welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final userRef = FirebaseFirestore.instance.collection('users');
final DateTime time = DateTime.now();
final fauth.FirebaseAuth _auth = fauth.FirebaseAuth.instance;

class User {
  final String uid;
  final String email;
  String photoUrl;
  final String displayName;
  
  User({this.uid, this.email, this.photoUrl, this.displayName});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc['Uid'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
    );
  }
}

class HandleUser with ChangeNotifier {
  bool isAuth = false;
  bool loading = false;
  static User userinfo;
  User tocopy;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  fauth.User currentUser;
  login() async {
   
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      auth("auth", googleSignInAccount);
      fauth.AuthCredential credential = fauth.GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final fauth.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final fauth.User user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
    } catch (e) {
      print(e.code);
      return e.code;
    }
    try {
      DocumentSnapshot doc = await userRef.doc(currentUser.uid).get();
      if (!doc.exists) {
        await createUserInFirebase(doc, currentUser);
      } else {
        userinfo = User.fromDocument(doc);
        userinfo.photoUrl = currentUser.photoURL;
        setiflogged("logged", true);
      }
    } catch (e) {
      print(e.code);
      return e.code;
    }

    isAuth = true;
    loading = false;
    notifyListeners();
    return false;
  }

  Future<dynamic> autoSignin() async {
    
    try {
      //   googleSignIn.signInSilently();

      GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signInSilently();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      fauth.AuthCredential credential = fauth.GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final fauth.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final fauth.User user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
    } on NoSuchMethodError catch (e) {
      print(e);
      return "network Error";
    } catch (e) {
      print(e);
      return "error restart the app";
    }
    try {
      DocumentSnapshot doc = await userRef.doc(currentUser.uid).get();
      if (!doc.exists) {
        var b =await createUserInFirebase(doc, currentUser);
        if (b != null) {
          print(b);
          return b;
        }
      } else {
        userinfo = User.fromDocument(doc);
        setiflogged("logged", true);
      }
    } catch (e) {
      print(e.code);
      return e.code;
    }

    isAuth = true;
    loading = false;
    notifyListeners();
    return false;
  }

  Future<dynamic> logout(context) async {
    try {
      await googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print(e.code);
      return e.code;
    }
    isAuth = false;
    loading = false;
    userinfo = tocopy;
    Navigator.of(context).popUntil(ModalRoute.withName(Welcome.id));
    setiflogged("logged", false);
    notifyListeners();
    return true;
  }

  createUserInFirebase(doc, user) async {
  
    WriteBatch writebatch = _firestore.batch();
    try {
      if (!doc.exists) {
        DocumentReference docref1 = userRef.doc(user.uid);
        writebatch.set(docref1, {
          'Uid': user.uid,
          'photoUrl': user.photoUrl,
          'email': user.email,
          'displayName': user.displayName,
          'timeStamp': time,
        });
        // await userRef.doc(user.uid).set({
        //   'Uid': user.uid,
        //   'photoUrl': user.photoUrl,
        //   'email': user.email,
        //   'displayName': user.displayName,
        //   'timeStamp': time,
        // });
        writebatch.commit();
        doc = await userRef.doc(user.uid).get();
      }
    } catch (e) {
      print(e.code);
      return e.code;
    }
    userinfo = User.fromDocument(doc);
    setiflogged("logged", true);
    return true;
  }
}
