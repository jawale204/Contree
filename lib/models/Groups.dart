import 'package:Contri/models/HandleUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class Groups with ChangeNotifier {
  CollectionReference groups = Firestore.instance.collection('GroupsDB');
  final String groupName;
  final String groupId;
  final Timestamp date;
  QuerySnapshot groupDoc;
  QuerySnapshot a;
  Groups({this.groupName, this.groupId, this.date});

//creates a new groups with input as the name of group
  Future<bool> createGroup(groupname, date) async {
    DocumentReference doc = groups.document();
    DateTime time=DateTime.now();
    var groupID = doc.documentID;
    await doc.collection('Members').document().setData({
      'name': HandleUser.userinfo.displayName,
      'uid': HandleUser.userinfo.uid,
      'photoUrl': HandleUser.userinfo.photoUrl,
      'email': HandleUser.userinfo.email,
    });
    await userRef
        .document(HandleUser.userinfo.uid)
        .collection('Groups').document(time.toString().substring(0, 23)).setData({'name': groupname, 'groupid': groupID, 'Date&Time': time});
    await userRef
        .document(HandleUser.userinfo.uid)
        .collection('Activity')
        .document(time.toString().substring(0, 23))
        .setData({'data': 'You created a Group : $groupname'});
    notifyListeners();

    return (true);
  }

//returns the Groups of user
  Future<QuerySnapshot> getGroups() async {
    groupDoc = await userRef
        .document(HandleUser.userinfo.uid)
        .collection('Groups')
        .orderBy('Date&Time', descending: true)
        .getDocuments();
    return groupDoc;
  }

//returns Groups object with 2 parametes
  factory Groups.fromDocument(DocumentSnapshot doc) {
    return Groups(
        groupName: doc['name'],
        groupId: doc['groupid'],
        date: doc['Date&Time']);
  }


}
