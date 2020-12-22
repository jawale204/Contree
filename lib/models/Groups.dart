import 'package:Contri/models/HandleUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Groups with ChangeNotifier {
  CollectionReference groups = FirebaseFirestore.instance.collection('GroupsDB');
  final String groupName;
  final String groupId;
  final Timestamp date;
  Stream<QuerySnapshot> groupDoc;
  QuerySnapshot a;
  Groups({this.groupName, this.groupId, this.date});
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

//creates a new groups with input as the name of group
  Future<dynamic> createGroup(groupname, date) async {
    WriteBatch writebatch = _firestore.batch();
    print(groupname);
    print(date);
    DateTime time = DateTime.now();
    try {
      DocumentReference doc = groups.doc();
      var groupID = doc.id;
      DocumentReference docref1 = doc.collection('Members').doc();
      writebatch.set(docref1, {
        'name': HandleUser.userinfo.displayName,
        'uid': HandleUser.userinfo.uid,
        'photoUrl': HandleUser.userinfo.photoUrl,
        'email': HandleUser.userinfo.email,
      });
      // await doc.collection('Members').document().setData({
      //   'name': HandleUser.userinfo.displayName,
      //   'uid': HandleUser.userinfo.uid,
      //   'photoUrl': HandleUser.userinfo.photoUrl,
      //   'email': HandleUser.userinfo.email,
      // });
      DocumentReference docref2 = userRef
          .doc(HandleUser.userinfo.uid)
          .collection('Groups')
          .doc(time.toString().substring(0, 23));
      writebatch.set(
          docref2, {'name': groupname, 'groupid': groupID, 'Date&Time': time});
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('Groups')
      //     .document(time.toString().substring(0, 23))
      //     .setData({'name': groupname, 'groupid': groupID, 'Date&Time': time});
      DocumentReference docref3 = userRef
          .doc(HandleUser.userinfo.uid)
          .collection('Activity')
          .doc(time.toString().substring(0, 23));
      writebatch.set(docref3,
          {'data': 'You created a Group : $groupname', "date": time,'type': "Group"});
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('Activity')
      //     .document(time.toString().substring(0, 23))
      //     .setData(
      //         {'data': 'You created a Group : $groupname', "DateTime": time});
      writebatch.commit();
    } catch (e) {
      print(e.code);
      return e.code;
    }

    notifyListeners();
    return (true);
  }

//returns the Groups of user
  Stream<QuerySnapshot> getGroups() {
    print("getgroups called");
    groupDoc = userRef
        .doc(HandleUser.userinfo.uid)
        .collection('Groups')
        .orderBy('Date&Time', descending: true)
        .snapshots();
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
