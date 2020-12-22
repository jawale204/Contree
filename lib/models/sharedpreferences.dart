import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setiflogged(String key, bool value) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  await _pref.setBool(key, value);
}

Future<bool> getiflogged(String key) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  bool islogged = _pref.getBool(key) ?? false;
  return islogged;
}

void setidtoken(String key, String value) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  await _pref.setString(key, value);
}

void auth(String key, GoogleSignInAccount value) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  await _pref.setString("displayName", value.displayName);
  await _pref.setString("id", value.id);
  await _pref.setString("email", value.email);
  await _pref.setString("photoUrl", value.photoUrl);
}

Future<dynamic> getauth(String key) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  String displayName = _pref.getString("displayName") ?? "";
  String id = _pref.getString("id") ?? "";
  String email = _pref.getString("email") ?? "";
  String photoUrl = _pref.getString("photoUrl") ?? "";
  var yo = """{
    "GoogleSignInAccount": {
      "displayName": {$displayName},
      "email": {$email},
      "id": {$id},
      "photoUrl": {$photoUrl}
    }
  }""";
  return yo;
}

void setaccesstoken(String key, String value) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  await _pref.setString(key, value);
}

Future<String> getidtoken(String key) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  String idtoken = _pref.getString(key) ?? "";
  return idtoken;
}

Future<String> getaccesstoken(String key) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  String accesstoken = _pref.getString(key) ?? "";
  return accesstoken;
}
