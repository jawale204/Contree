import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HandleUser.dart';

class Daily with ChangeNotifier {
  QuerySnapshot personalExpDoc;
  String description;
  String amount;
  Timestamp date;
  Daily({this.description, this.amount, this.date});
  createPersonalExp(description, amount, date) async {
    await userRef
        .document(HandleUser.userinfo.uid)
        .collection('PersonalExp')
        .document(date.toString().substring(0, 23))
        .setData(
            {'description': description, 'amount': amount, 'Date&Time': date});

    await userRef
        .document(HandleUser.userinfo.uid)
        .collection('Activity')
        .document(date.toString().substring(0, 23))
        .setData(
            {'data': 'You added daily Expense : $description', 'date': date});
    notifyListeners();
    return (true);
  }

  Future<QuerySnapshot> getPersonalExp() async {
    personalExpDoc = await userRef
        .document(HandleUser.userinfo.uid)
        .collection('PersonalExp')
        .orderBy('Date&Time', descending: true)
        .getDocuments();
    return personalExpDoc;
  }

  factory Daily.fromDocument(doc) {
    return Daily(
        description: doc['description'],
        amount: doc['amount'],
        date: doc['Date&Time']);
  }

  Future<bool> delete(Daily da) async {
    DateTime time = DateTime.now();
    await userRef
        .document(HandleUser.userinfo.uid)
        .collection('PersonalExp')
        .document(da.date.toDate().toString())
        .delete();
    await userRef
        .document(HandleUser.userinfo.uid)
        .collection('Activity')
        .document(time.toString().substring(0, 23))
        .setData({
      'data': 'You deleted daily Expense : ${da.description}',
      'date': time
    });
    notifyListeners();
    return true;
  }

  Future<QuerySnapshot> getActivity() async {
    return await userRef
        .document(HandleUser.userinfo.uid)
        .collection('Activity')
        .orderBy('date',descending: true)
        .getDocuments();
  }
}
