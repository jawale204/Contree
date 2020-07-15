import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/widget/constants.dart';
import 'package:Contri/widget/genbutton.dart';
import 'package:Contri/widget/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalExp extends StatefulWidget {
  @override
  _PersonalExpState createState() => _PersonalExpState();
}

class _PersonalExpState extends State<PersonalExp> {
  final TextEditingController description = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  validator(da) async {
    DateTime date = DateTime.now();
    bool p;
    if (_formKey.currentState.validate()) {
      p = await da.createPersonalExp(
          description.value.text, amount.value.text, date);
    }
    if (p) {
      description.clear();
      amount.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final da = Provider.of<Daily>(context);
    Future<QuerySnapshot> a = da.getPersonalExp();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Stack(children: <Widget>[
            FutureBuilder(
              future: a,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Widget> exps = [];
                  snapshot.data.documents.forEach((doc) {
                    Daily dai = Daily.fromDocument(doc);
                    exps.add(PersonalExpSingle(dai));
                  });
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
                txt: 'Create a Expense',
                onpress: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Create new Expense'),
                          content: Container(
                            width: 250,
                            height: 220,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter Description';
                                        }
                                        return null;
                                      },
                                      controller: description, //controller,
                                      decoration: KTextDecoration.copyWith(
                                          hintText: 'Enter Description',
                                          hintStyle: TextStyle(
                                              color: Colors.black54))),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter Amount';
                                        }
                                        return null;
                                      },
                                      controller: amount, //controller,
                                      keyboardType:
                                          TextInputType.numberWithOptions(),
                                      decoration: KTextDecoration.copyWith(
                                          hintText: 'Enter Amount',
                                          hintStyle: TextStyle(
                                              color: Colors.black54))),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Center(
                                    child: SaveButton(
                                      onpress: () {
                                        validator(da);
                                      },
                                      txt: 'Save',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class PersonalExpSingle extends StatelessWidget {
  final Daily singlePE;

  delete1(context, da) async {
    bool p = await da.delete(singlePE);
    if(p){
       Navigator.of(context).pop();
    }
  }

  PersonalExpSingle(this.singlePE);
  @override
  Widget build(BuildContext context) {
    final da = Provider.of<Daily>(context);
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: 70,
        margin: EdgeInsets.all(9.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Description :',
                    style: TextStyle(fontSize: 15, color: Colors.grey[500]),
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
                    style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                  ),
                  Text(
                    "  " + singlePE.amount,
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
    );
  }
}
