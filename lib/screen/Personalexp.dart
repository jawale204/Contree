import 'dart:async';

import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/models/icons.dart';
import 'package:Contri/screen/NewCreatePersonalexp.dart';
import 'package:Contri/widget/genbutton.dart';
import 'package:Contri/widget/progress.dart';
import 'package:Contri/widget/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalExp extends StatefulWidget {
  @override
  _PersonalExpState createState() => _PersonalExpState();
}

class _PersonalExpState extends State<PersonalExp>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController description = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var da;
  int totalInc = 0;
  String typeoftran = "All";
  int totalExp = 0;
  Stream<QuerySnapshot> a;
  String dropdownyear = DateTime.now().year.toString();
  String dropdownmonth = [
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
  ][DateTime.now().month - 1];
  validator(da) async {
    DateTime date = DateTime.now();
    dynamic p;
    if (_formKey.currentState.validate()) {
      p = await da.createPersonalExp(
          description.value.text, amount.value.text, date);
    }
    if (p.runtimeType != bool) {
      toast(p);
    } else {
      if (p) {
        description.clear();
        amount.clear();
        Navigator.pop(context);
      }
    }
  }

  forUpdatingIncExp(dai) {
    if (dai.type == "Income") {
      totalInc = totalInc + int.parse(dai.amount);
    }
    if (dai.type == "Expense") {
      totalExp = totalExp + int.parse(dai.amount);
    }
  }

  @override
  initState() {
    super.initState();
    da = Provider.of<Daily>(context, listen: false);
    a = da.getPersonalExp(dropdownmonth, dropdownyear, typeoftran);
  }

  @override
  bool get wantKeepAlive => true;

  sortingChange() {
    a = da.getPersonalExp(dropdownmonth, dropdownyear, typeoftran);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //final da = Provider.of<Daily>(context, listen: false);
    // Stream<QuerySnapshot> a =
    //     da.getPersonalExp(dropdownmonth, dropdownyear, typeoftran);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Card(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton(
                      value: dropdownmonth,
                      items: <String>[
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
                      ].map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                            value: val, child: Text(val));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownmonth = value;
                          sortingChange();
                        });
                      }),
                  DropdownButton(
                      value: dropdownyear,
                      items: <String>[
                        '2020',
                        '2021',
                        '2022',
                        '2023',
                        '2024',
                        '2025'
                      ].map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                            value: val, child: Text(val));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownyear = value;
                          sortingChange();
                        });
                      }),
                  DropdownButton(
                      value: typeoftran,
                      items: <String>["All", "Expense", "Income"]
                          .map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                            value: val, child: Text(val));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          typeoftran = value;
                          sortingChange();
                        });
                      }),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 24,
          child: Stack(children: <Widget>[
            StreamBuilder(
              stream: a,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Widget> exps = [];
                  totalExp = 0;
                  totalInc = 0;
                  snapshot.data.documents.forEach((doc) {
                    Daily dai = Daily.fromDocument(doc);
                    forUpdatingIncExp(dai);
                    var boi;
                    if (dai.type == "Expense") {
                      boi = CategoryIconService.expensetype[dai.category];
                    } else {
                      boi = CategoryIconService.incomelist[dai.category];
                    }
                    //print(boi.name);
                    //var boy = boi[dai.category];
                    exps.add(PersonalExpSingle(dai, boi));
                  });
                  exps.insert(
                    0,
                    buildContainer(context),
                  );
                  return ListView(
                    children: exps,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  );
                } else {
                  return circularProgress();
                }
              },
            ),
            Positioned(
              bottom: 20,
              right: 50,
              left: 50,
              child: SaveButton(
                txt: 'Create a Transaction',
                onpress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectCategory()));
                  // showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return AlertDialog(
                  //         title: Text('Create new Expense'),
                  //         content: Container(
                  //           width: 250,
                  //           height: 220,
                  //           child: Form(
                  //             key: _formKey,
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: <Widget>[
                  //                 TextFormField(
                  //                     validator: (value) {
                  //                       if (value.isEmpty) {
                  //                         return 'Please enter Description';
                  //                       }
                  //                       return null;
                  //                     },
                  //                     controller: description, //controller,
                  //                     decoration: KTextDecoration.copyWith(
                  //                         hintText: 'Enter Description',
                  //                         hintStyle: TextStyle(
                  //                             color: Colors.black54))),
                  //                 SizedBox(
                  //                   height: 10,
                  //                 ),
                  //                 TextFormField(
                  //                     validator: (value) {
                  //                       if (value.isEmpty) {
                  //                         return 'Please enter Amount';
                  //                       }
                  //                       return null;
                  //                     },
                  //                     controller: amount, //controller,
                  //                     keyboardType:
                  //                         TextInputType.numberWithOptions(),
                  //                     decoration: KTextDecoration.copyWith(
                  //                         hintText: 'Enter Amount',
                  //                         hintStyle: TextStyle(
                  //                             color: Colors.black54))),
                  //                 SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Center(
                  //                   child: SaveButton(
                  //                     onpress: () {
                  //                       validator(da);
                  //                     },
                  //                     txt: 'Save',
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     });
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Container buildContainer(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Card(
            elevation: 5,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                      child: Text(
                    "Total Expense",
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  )),
                  Center(
                    child: Text(
                      totalExp.toString() + "  ",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                      child: Text(
                    "Total Income",
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  )),
                  Center(
                      child: Text(
                    totalInc.toString(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalExpSingle extends StatelessWidget {
  final Daily singlePE;
  final boi;
  delete1(context, da) async {
    bool p = await da.delete(singlePE);
    if (p) {
      Navigator.of(context).pop();
    }
  }

  PersonalExpSingle(this.singlePE, this.boi);
  @override
  Widget build(BuildContext context) {
    final da = Provider.of<Daily>(context);
    // var boi = CategoryIconService.expensetype;
    // var boy = boi[singlePE.category];
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Delete expence'),
                content: const Text(
                    'The selected field will be deleted permanently'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: const Text('DELETE'),
                    onPressed: () {
                      delete1(context, da);
                    },
                  )
                ],
              );
            });
      },
      child: Card(
        elevation: 15,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 200,
          margin: EdgeInsets.all(9.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              boi.icon,
                              size: 17,
                              color: boi.color,
                            )),
                        Text(boi.name)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Type :',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        ),
                        Text(
                          "  " + singlePE.type,
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Description :',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        ),
                        Text(
                          "  " + singlePE.description,
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Amount :',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        ),
                        Text(
                          "  " + singlePE.amount,
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Date :',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        ),
                        Text(
                          "  " +
                              singlePE.selectedDay.toString() +
                              "," +
                              singlePE.months[singlePE.selectedMonth - 1] +
                              " " +
                              singlePE.selectedYear.toString(),
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      singlePE.date.toDate().toString(),
                      style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                    )
                  ])),
        ),
      ),
    );
  }
}
