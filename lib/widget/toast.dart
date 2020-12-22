import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

 toast(error){
  return Fluttertoast.showToast(
        msg: error,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[500],
        textColor: Colors.white
      );
}