import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleGroup with ChangeNotifier {
  final Groups obj;
  String name;
  dynamic date;
  Map<dynamic, dynamic> expense;
  String docId;
  String creator;
  dynamic pickedTime;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SingleGroup(
      {this.obj,
      this.expense,
      this.name,
      this.date,
      this.docId,
      this.creator,
      this.pickedTime});
  static CollectionReference groups =
      FirebaseFirestore.instance.collection('GroupsDB');
  QuerySnapshot expensesq;
  Stream<QuerySnapshot> expenses;
  //List docID = [];
  // returns members list
  Future<dynamic> allMembers(vobj) async {
    Map<String, Map<String, dynamic>> memberMap = {};
    try {
      DocumentReference allMembersAndExpense = groups.doc(vobj.groupId);
      QuerySnapshot members =
          await allMembersAndExpense.collection('Members').get();

      var i = 0;
      members.docs.forEach((element) {
        i = i + 1;
        memberMap.addAll({'member' + i.toString(): element.data()});
      });
    } catch (e) {
      print(e.code);
      return e.code;
    }

    return memberMap;
  }

  //adds expense with expense list its description //obj for that particular group info
  Future<dynamic> addExpense(expense, description, obj, time, picked) async {
    WriteBatch writebatch = _firestore.batch();
    try {
      DocumentReference docref1 = groups
          .doc(obj.groupId)
          .collection('Expense')
          .doc(time.toString().substring(0, 23));
      writebatch.set(docref1, {
        'name': description,
        'expense': expense,
        'Date&Time': time,
        "creator": HandleUser.userinfo.email,
        'pickedTime': picked
      });
      // groups
      //     .document(obj.groupId)
      //     .collection('Expense')
      //     .document(time.toString().substring(0, 23))
      //     .setData({
      //   'name': description,
      //   'expense': expense,
      //   'Date&Time': time,
      //   "creator": HandleUser.userinfo.email
      // });
      // DocumentReference docref2 = userRef
      //     .doc(HandleUser.userinfo.uid)
      //     .collection('Activity')
      //     .doc(time.toString().substring(0, 23));
      // writebatch.set(docref2, {
      //   'data': 'You added an Expense in group : ${obj.groupName}',
      //   'date': time,
      //   'type': "Group"
      // });
      DocumentReference docref3 =
          groups.doc(obj.groupId).collection('Chats').doc();
      writebatch.set(docref3, {
        'date': DateTime.now().toIso8601String().toString(),
        'sendby': HandleUser.userinfo.email,
        'type': "Notify",
        'note': '${HandleUser.userinfo.email} created an Expense $description',
      });
      // groups.doc(obj.groupId).collection('Chats').add({
      //   'date': DateTime.now().toIso8601String().toString(),
      //   'sendby': HandleUser.userinfo.email,
      //   'type': "Notify",
      //   'note': '${HandleUser.userinfo.email} created an Expense $description',
      // });
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('Activity')
      //     .document(time.toString().substring(0, 23))
      //     .setData({
      //   'data': 'You added a Expense in group : ${obj.groupName}',
      //   'date': time
      // });
      writebatch.commit();
    } catch (e) {
      print(e.code);
      return e.code;
    }
    //notifyListeners();
    return true;
  }

  Stream<QuerySnapshot> allExpense(vobj) {
    DocumentReference allMembersAndExpense = groups.doc(vobj.groupId);
    //  plz(vobj);
    expenses = allMembersAndExpense
        .collection('Expense')
        .orderBy('Date&Time', descending: true)
        .snapshots();
    return expenses;
  }

  // plz(vobj) async {
  //   docID = [];
  //   try {
  //     DocumentReference allMembersAndExpense = groups.doc(vobj.groupId);
  //     expensesq = await allMembersAndExpense
  //         .collection('Expense')
  //         .orderBy('Date&Time', descending: true)
  //         .get();
  //     expensesq.docs.forEach((element) {
  //       docID.add([element.id]);
  //     });
  //   } catch (e) {
  //     print(e.code);
  //     print(e.code);
  //   }
  // }

  factory SingleGroup.fromDocument(DocumentSnapshot doc) {
    return SingleGroup(
        name: doc['name'],
        expense: doc['expense'],
        date: doc['Date&Time'],
        creator: doc['creator'],
        pickedTime: doc['pickedTime']);
  }

  Future<dynamic> deleteExpense(docId, obj, a) async {
    DateTime time = DateTime.now();
    WriteBatch writebatch = _firestore.batch();
    var koko = a.date.toDate().toString();
    try {
      DocumentReference docref1 =
          groups.doc(obj.groupId).collection('Expense').doc(koko);
      writebatch.delete(docref1);
     
       DocumentReference docref3 =
          groups.doc(obj.groupId).collection('Chats').doc();
      writebatch.set(docref3, {
        'date': DateTime.now().toIso8601String().toString(),
        'sendby': HandleUser.userinfo.email,
        'type': "Notify",
        'note': '${HandleUser.userinfo.email} deleted an Expense ${a.name}',
      });
     
      writebatch.commit();
    } catch (e) {
      print(e.code);
      return e.code;
    }
    notifyListeners();
    return true;
  }

  addMember(user, Groups obj) async {
    DateTime time = DateTime.now();
    WriteBatch writebatch = _firestore.batch();
    var a;
    try {
      QuerySnapshot isPresent = await FirebaseFirestore.instance
          .collection('GroupsDB')
          .doc(obj.groupId)
          .collection('Members')
          .get();
      a = isPresent.docs
          .any((element) => element.data().containsValue(user.uid));
    } catch (e) {
      print(e.code);
      return e.code;
    }

    try {
      if (!a) {
        DocumentReference docref1 = FirebaseFirestore.instance
            .collection('GroupsDB')
            .doc(obj.groupId)
            .collection('Members')
            .doc();
        writebatch.set(docref1, {
          'name': user.displayName,
          'uid': user.uid,
          'photoUrl': user.photoUrl,
          'email': user.email,
        });
    
        DocumentReference docref2 =
            userRef.doc(user.uid).collection('Groups').doc();
        writebatch.set(docref2, {
          'name': obj.groupName,
          'groupid': obj.groupId,
          'Date&Time': obj.date
        });
        DocumentReference docref4 =
          groups.doc(obj.groupId).collection('Chats').doc();
      writebatch.set(docref4, {
        'date': DateTime.now().toIso8601String().toString(),
        'sendby': HandleUser.userinfo.email,
        'type': "Notify",
        'note': '${HandleUser.userinfo.email} Added ${user.email} to the group',
      });
        writebatch.commit();
      }
    } catch (e) {
      print(e.code);
      return e.code;
    }

    notifyListeners();
    return !a;
  }

  leaveGroup(Groups obj) async {
    DateTime time = DateTime.now();
    var deleteid;
    var deleteid2;
    bool deleteGroup = false;
    WriteBatch writebatch = _firestore.batch();
    try {
      QuerySnapshot a = await FirebaseFirestore.instance
          .collection('GroupsDB')
          .doc(obj.groupId)
          .collection('Members')
          .where('email', isEqualTo: HandleUser.userinfo.email)
          .get();
       QuerySnapshot chesk = await FirebaseFirestore.instance
          .collection('GroupsDB')
          .doc(obj.groupId)
          .collection('Members')
          .get();
      if (chesk.docs.length == 1) {
        DocumentReference docrefDG =
            FirebaseFirestore.instance.collection('GroupsDB').doc(obj.groupId);
        docrefDG.collection('Chats').snapshots().forEach((element) => {
              for (QueryDocumentSnapshot snapshot in element.docs)
                {snapshot.reference.delete()}
            });
        docrefDG.collection('Expense').snapshots().forEach((element) => {
              for (QueryDocumentSnapshot snapshot in element.docs)
                {snapshot.reference.delete()}
            });
        // deleteGroup = true;
      }
      deleteid = a.docs.first.id;
      QuerySnapshot b = await FirebaseFirestore.instance
          .collection('users')
          .doc(HandleUser.userinfo.uid)
          .collection('Groups')
          .where('groupid', isEqualTo: obj.groupId)
          .get();
      deleteid2 = b.docs.first.id;
    } catch (e) {
      print(e.code);
      return e.code;
    }

    DocumentReference docref1 = FirebaseFirestore.instance
        .collection('GroupsDB')
        .doc(obj.groupId)
        .collection('Members')
        .doc(deleteid);
    writebatch.delete(docref1);

    // Firestore.instance
    //     .collection('GroupsDB')
    //     .document(obj.groupId)
    //     .collection('Members')
    //     .document(deleteid)
    //     .delete();
    DocumentReference docref2 = FirebaseFirestore.instance
        .collection('users')
        .doc(HandleUser.userinfo.uid)
        .collection('Groups')
        .doc(deleteid2);
    writebatch.delete(docref2);
    // Firestore.instance
    //     .collection('users')
    //     .document(HandleUser.userinfo.uid)
    //     .collection('Groups')
    //     .document(deleteid2)
    //     .delete();
    DocumentReference docref3 = userRef
        .doc(HandleUser.userinfo.uid)
        .collection('Activity')
        .doc(time.toString().substring(0, 23));
    writebatch.set(docref3, {
      'data': 'You left Group ${obj.groupName}',
      'date': time,
      'type': "Group"
    });
      DocumentReference docref4 =
          groups.doc(obj.groupId).collection('Chats').doc();
      writebatch.set(docref4, {
        'date': DateTime.now().toIso8601String().toString(),
        'sendby': HandleUser.userinfo.email,
        'type': "Notify",
        'note': '${HandleUser.userinfo.email} left the group',
      });
    // userRef
    //     .document(HandleUser.userinfo.uid)
    //     .collection('Activity')
    //     .document(time.toString().substring(0, 23))
    //     .setData({'data': 'You left Group ${obj.groupName}', 'date': time});
    writebatch.commit();
    notifyListeners();
    return true;
  }
}
