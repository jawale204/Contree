import 'package:Contri/models/icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HandleUser.dart';

class Daily with ChangeNotifier {
  QuerySnapshot personalExpDoc;
  String description;
  String amount;
  Timestamp date;
  String type;
  int category;
  dynamic selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;
  List months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  Daily(
      {this.description,
      this.amount,
      this.selectedDate,
      this.selectedDay,
      this.selectedMonth,
      this.selectedYear,
      this.date,
      this.type,
      this.category});
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<dynamic> createPersonalExp(descriptio, amoun, dat, selectedDat,
      selectedDa, selectedMont, selectedYea, typ, Category categor) async {
    try {
      WriteBatch writebatch = _firestore.batch();
      DocumentReference docref1 = userRef
          .doc(HandleUser.userinfo.uid)
          .collection('PersonalExp')
          .doc(dat.toString().substring(0, 23));
      writebatch.set(docref1, {
        'description': descriptio,
        'amount': amoun,
        'Date&Time': dat,
        'selectedDate': selectedDat,
        'selectedDay': selectedDa,
        'selectedMonth': selectedMont,
        'selectedYear': selectedYea,
        'type': typ,
        'category': categor.index
      });
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('PersonalExp')
      //     .document(date.toString().substring(0, 23))
      //     .setData(
      //         {'description': description, 'amount': amount, 'Date&Time': date});
      DocumentReference docref2 = userRef
          .doc(HandleUser.userinfo.uid)
          .collection('Activity')
          .doc(dat.toString().substring(0, 23));
      writebatch.set(docref2, {
        'data': 'You added daily Expense : $descriptio',
        'date': DateTime.now(),
        'type': 'Personal'
      });
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('Activity')
      //     .document(date.toString().substring(0, 23))
      //     .setData(
      //         {'data': 'You added daily Expense : $description', 'date': date});
      writebatch.commit();
    } catch (e) {
      print(e.code);
      return e.code;
    }
    notifyListeners();
    return (true);
  }

  Future<void> getdate(context, personal) async {
    final DateTime picked = await showDatePicker(
        context: context,
        lastDate: new DateTime.now(),
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2020));
    if (picked != null) {
      personal.selectedMonth = picked.month;
      personal.selectedDay = picked.day;
      personal.selectedDate = picked;
      personal.selectedYear = picked.year;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> getPersonalExp(month, year, type) {
    print("yo");
    if (type == "All") {
      return userRef
          .doc(HandleUser.userinfo.uid)
          .collection('PersonalExp')
          .where('selectedYear', isEqualTo: int.parse(year))
          .where('selectedMonth', isEqualTo: months.indexOf(month) + 1)
          .orderBy('selectedDay', descending: true)
          .snapshots();
    } else {
      return userRef
          .doc(HandleUser.userinfo.uid)
          .collection('PersonalExp')
          .where('selectedYear', isEqualTo: int.parse(year))
          .where('selectedMonth', isEqualTo: months.indexOf(month) + 1)
          .where('type', isEqualTo: type)
          .orderBy('selectedDay', descending: true)
          .snapshots();
    }
    // return userRef
    //     .doc(HandleUser.userinfo.uid)
    //     .collection('PersonalExp')
    //     .orderBy('Date&Time', descending: true)
    //     .snapshots();
    //  return personalExpDoc;
  }

  factory Daily.fromDocument(doc) {
    return Daily(
        description: doc['description'],
        amount: doc['amount'],
        date: doc['Date&Time'],
        selectedDate: doc['selectedDate'],
        selectedDay: doc['selectedDay'],
        selectedMonth: doc['selectedMonth'],
        selectedYear: doc['selectedYear'],
        type: doc['type'],
        category: doc['category']);
  }

  Future<dynamic> delete(Daily da) async {
    DateTime time = DateTime.now();
    try {
      WriteBatch writebatch = _firestore.batch();
      DocumentReference docref1 = userRef
          .doc(HandleUser.userinfo.uid)
          .collection('PersonalExp')
          .doc(da.date.toDate().toString());
      writebatch.delete(docref1);
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('PersonalExp')
      //     .document(da.date.toDate().toString())
      //     .delete();
      DocumentReference docref2 = userRef
          .doc(HandleUser.userinfo.uid)
          .collection('Activity')
          .doc(time.toString().substring(0, 23));
      writebatch.set(docref2, {
        'data': 'You deleted daily Expense : ${da.description}',
        'date': time,
        'type': "Personal"
      });
      // await userRef
      //     .document(HandleUser.userinfo.uid)
      //     .collection('Activity')
      //     .document(time.toString().substring(0, 23))
      //     .setData({
      //   'data': 'You deleted daily Expense : ${da.description}',
      //   'date': time
      // });
      writebatch.commit();
    } catch (e) {
      print(e.code);
      return e.code;
    }

    notifyListeners();
    return true;
  }

  // Future<QuerySnapshot> getActivity() async {
  //   return await userRef
  //       .doc(HandleUser.userinfo.uid)
  //       .collection('Activity')
  //       .orderBy('date', descending: true)
  //       .get();
  // }
}

class ActivityClass with ChangeNotifier {
  Stream<QuerySnapshot> getActivity() {
    print("called");
    return userRef
        .doc(HandleUser.userinfo.uid)
        .collection('Activity')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
