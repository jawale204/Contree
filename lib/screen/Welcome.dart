import 'dart:io';

import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/models/sharedpreferences.dart';
import 'package:Contri/screen/Body.dart';
import 'package:Contri/widget/genbutton.dart';
import 'package:Contri/widget/progress.dart';
import 'package:Contri/widget/toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  @override
  static String id = 'Welcome';
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  initState() {
    super.initState();
  //  doit();
    isloggedin();
  }

  var user;
  isloggedin() async {
    //setiflogged("logged", false);
    bool islogged = await getiflogged("logged");
    print(islogged);
    if (islogged) {
      setState(() {
        user.loading = true;
      });
      dynamic done = await user.autoSignin();
      if (done.runtimeType != bool) {
        toast(done);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('NetworK Error'),
                content: const Text('Check your Internet Connection'),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        child: const Text('EXIT'),
                        onPressed: () {
                          exit(0);
                        },
                      ),
                      FlatButton(
                        child: const Text('RETRY'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          isloggedin();

                          return null;
                        },
                      )
                    ],
                  ),
                ],
              );
            });
      } else {
        setState(() {
          print(done);
          user.loading = done;
        });
      }
    } else {
      setState(() {
        user.loading = false;
      });
    }
  }

  login() async {
    setState(() {
      user.loading = true;
    });
    var c = await user.login();
    if (c != false) {
      // Fluttertoast.showToast(
      //     msg: c,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.grey[400],
      //     textColor: Colors.white);
      toast(c);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Logout'),
              content: const Text('Do you want to logout of the app?'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FlatButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: const Text('Retry'),
                      onPressed: () {
                        login();
                      },
                    )
                  ],
                ),
              ],
            );
          });
    } else {
      setState(() {
        user.loading = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<HandleUser>(context);
    return user.loading
        ? Scaffold(
            body: circularProgress(),
          )
        : Scaffold(
            // Checks if logged in
            body: !user.isAuth
                ? Center(
                    child:
                        //login option
                        SaveButton(
                    onpress: () {
                      login();
                    },
                    txt: 'Sign In With Google',
                  ))
                :
                //main body if loggedin
                Body());
  }
}
