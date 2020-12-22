import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:Contri/screen/Body.dart';
import 'package:Contri/screen/ExpenseDetail.dart';

import 'package:Contri/screen/GroupChatScreen.dart';
import 'package:Contri/screen/GroupExpenseData.dart';
import 'package:Contri/screen/SearchUsers.dart';
import 'package:Contri/screen/createExpense.dart';
import 'package:Contri/widget/progress.dart';
import 'package:Contri/widget/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupContent extends StatefulWidget {
  static String id = 'GroupContent';
  final Groups obj;
  GroupContent({this.obj});
  @override
  _GroupContentState createState() => _GroupContentState();
}

class _GroupContentState extends State<GroupContent> {
  Stream<QuerySnapshot> allExpenses;
  dynamic memberlist=[];
  Future<QuerySnapshot> b;
  List<List> settleAndpay;
  Map<dynamic, dynamic> totalgroupdata = {};
  int totalallexpense;
  //List<List> membersCS = [];
  var selfTotalSpent = 0;
  var selfTotalContri = 0;
  List<dynamic> account = [];
  var sg;
  @override
  initState() {
    super.initState();
    sg = Provider.of<SingleGroup>(context, listen: false);
    allExpenses = sg.allExpense(widget.obj);
    //initialize();
  }

  // @override
  // void didChangeDependencies() {
  //   print("yo");
  //   sg = Provider.of<SingleGroup>(context);
  //   allExpenses = sg.allExpense(widget.obj);
  //   super.didChangeDependencies();
  // }

  // initialize() {
  //   print("valled");
  // }

  @override
  dispose() {
    super.dispose();
  }

  dothis(sg) async {
    memberlist = await sg.allMembers(widget.obj);
    if (memberlist.runtimeType == String) {
      toast(memberlist);
    }
    if (memberlist.length > 0) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  //passing Groups obj and members list to the createexpense page
                                  builder: (context) => CreateExpense(
                                      memberlist: memberlist,
                                      obj: widget.obj,
                                      sg: sg)));
                        } else {
                          toast("plz check internet connection");
                        }
  }

  settleandpay1(Map<dynamic, dynamic> singleExp, name, date) {
    if (account.contains([name, date])) {
      return null;
    } else {
      account.add([name, date]);
      var ind;
      totalallexpense = totalallexpense + singleExp["total"];
      singleExp.forEach((key, value) {
        ind = "";
        if (key != "total") {
          value.forEach((key1, value1) {
            if (value1 == HandleUser.userinfo.uid) {
              ind = key;
            }
          });
        }
        if (singleExp[ind] != null) {
          Map<dynamic, dynamic> bc = singleExp[ind];
          selfTotalContri = selfTotalContri + bc["contri"];
          selfTotalSpent = selfTotalSpent + bc["spent"];
        }
      });
    }
  }

  // settleandpay2(List<List> sAnde) {
  //   membersCS = [];
  //   memberlist.forEach((key, value) => {
  //         membersCS == null
  //             ? membersCS = [
  //                 [key, value]
  //               ]
  //             : membersCS.add([key, value])
  //       });
  //   for (var i = 0; i < sAnde.length; i++) {
  //     for (var j = 0; j < sAnde[i].length; j++) {
  //       if (membersCS[j].length < 3) {
  //         membersCS[j].add(sAnde[i][j][2]);
  //         membersCS[j].add(sAnde[i][j][3]);
  //       } else {
  //         membersCS[j][2] = sAnde[i][j][2] + membersCS[j][2];
  //         membersCS[j][3] = sAnde[i][j][3] + membersCS[j][3];
  //       }
  //     }
  //   }
  // }

  leavegrp() {
    SingleGroup sbg = new SingleGroup();
    leaveGroup(sbg);
    Navigator.pop(context);
  }

  void popmethod(String choice) async {
    if (choice == Pop.settings) {
      Navigator.push(
          context,
          MaterialPageRoute(
              //passing Groups obj and members list to the createexpense page
              builder: (context) => Search(obj: widget.obj)));
    } else if (choice == Pop.chat) {
      Navigator.push(
          context,
          MaterialPageRoute(
              //passing Groups obj and members list to the createexpense page
              builder: (context) => ChatScreen(obj: widget.obj)));
    } else if (choice == Pop.groupinfo) {
      // SingleGroup sbg = new SingleGroup();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: (selfTotalContri - selfTotalSpent == 0)
                    ? Text("Leave Group")
                    : Text("Expense not Settled"),
                content: (selfTotalContri - selfTotalSpent == 0)
                    ? Text('Do you want t leave this group?')
                    : Text("You have some unsettled Expenses"),
                actions: (selfTotalContri - selfTotalSpent == 0)
                    ? <Widget>[
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
                                child: const Text('LEAVE'),
                                onPressed: () {
                                  leavegrp();
                                  
                                },
                              )
                            ]),
                      ]
                    : <Widget>[
                        Center(
                          child: FlatButton(
                            child: const Text('CANCEL'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ]);
          });
    }
  }

  leaveGroup(sbg) async {
    await sbg.leaveGroup(widget.obj);
    toast("Group Left");
    Navigator.of(context, rootNavigator: true)
        .pop(ModalRoute.withName(Body.id));
  }

  @override
  Widget build(BuildContext context) {
    // var sg = Provider.of<SingleGroup>(context, listen: true);
    //dothis(sg);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.obj.groupName),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: popmethod,
            itemBuilder: (BuildContext context) {
              return Pop.pops
                  .map((String choice) => PopupMenuItem(
                        value: choice,
                        child: Text(choice),
                      ))
                  .toList();
            },
          )
        ],
        bottom: PreferredSize(
            child: StreamBuilder(
              // initialData: b,
              stream: allExpenses,
              builder: (BuildContext content, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  selfTotalContri = 0;
                  selfTotalSpent = 0;
                  totalallexpense = 0;
                  settleAndpay = [];
                  totalgroupdata = {};
                  account = [];
                  snapshot.data.documents.forEach((data1) {
                    var a = SingleGroup.fromDocument(data1);
                    settleandpay1(a.expense, a.name, a.date);
                  });
                  return Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Group Expense : ' + (totalallexpense).toString(),
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GroupExpenseData(obj: widget.obj)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[100],
                                ),
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Your Contri:' +
                                            (selfTotalContri).toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue),
                                      ),
                                      Text(
                                        'You Spent:' +
                                            (selfTotalSpent).toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue),
                                      ),
                                      selfTotalContri > selfTotalSpent
                                          ? Text(
                                              'You Lend:' +
                                                  (selfTotalContri -
                                                          selfTotalSpent)
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                            )
                                          : Text(
                                              'You Owe:' +
                                                  (-(selfTotalContri -
                                                          selfTotalSpent))
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                  //  }
                } else {
                  return Text(
                    'Total Expense : ' + 0.toString(),
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }
              },
            ),
            preferredSize: Size.fromHeight(150.0)),
      ),
      body: Column(children: <Widget>[
        Expanded(
          flex: 5,
          child: Stack(
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                  stream: allExpenses,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    List<ExpensTile> names = [];
                    if (snapshot.hasData) {
                      var i = 0;
                      snapshot.data.documents.forEach((data1) {
                        var a = SingleGroup.fromDocument(data1);
                        var ind;
                        a.expense.forEach((key, value) {
                          if (key != "total") {
                            value.forEach((key1, value) {
                              if (value == HandleUser.userinfo.uid) {
                                ind = key;
                              }
                            });
                          }
                        });
                        Map<dynamic, dynamic> plz;
                        if (ind != null) {
                          plz = a.expense[ind];
                        }
                        names.add(new ExpensTile(a.name, a.date, a.expense, sg,
                            widget.obj, i, plz, a.creator, a.pickedTime, a));
                        i = i + 1;
                      });

                      return ListView(children: names, shrinkWrap: true);
                    } else {
                      return circularProgress();
                    }
                  }),
              Positioned(
                child: ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      child: SizedBox(
                          width: 65,
                          height: 65,
                          child:
                              Icon(Icons.add, color: Colors.white, size: 25)),
                      onTap: () {
                        dothis(sg);
                      },
                    ),
                  ),
                ),
                bottom: 25,
                right: 25,
              )
            ],
          ),
        ),
      ]),
    );
  }
}

class ExpensTile extends StatefulWidget {
  final String name;
  final dynamic time;
  final Map<dynamic, dynamic> expense;
  final SingleGroup sg;
  final Groups obj;
  final int docId;
  final dynamic pickedTime;
  final String creator;
  final Map<dynamic, dynamic> plz;
  final SingleGroup a;
  ExpensTile(this.name, this.time, this.expense, this.sg, this.obj, this.docId,
      this.plz, this.creator, this.pickedTime, this.a);
  @override
  _ExpensTileState createState() => _ExpensTileState();
}

class _ExpensTileState extends State<ExpensTile> {
  var j;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2));
    return Container(
        height: 60,
        margin: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey[300],
        ),
        child: ListTile(
          isThreeLine: true,
          title: Text(this.widget.name),
          subtitle: widget.plz == null
              ? Text("Your Conti : " + (0).toString())
              : Text("Your Conti : " + widget.plz["contri"].toString()),
          trailing: widget.plz != null
              ? Column(
                  children: <Widget>[
                    Text(
                        "Total Amount : " + widget.expense["total"].toString()),
                    if ((widget.plz["contri"] - widget.plz["spent"]) < 0)
                      Text("You owe : " +
                          (-(widget.plz["contri"] - widget.plz["spent"]))
                              .toString()),
                    if ((widget.plz["contri"] - widget.plz["spent"]) > 0)
                      Text("You lend : " +
                          (widget.plz["contri"] - widget.plz["spent"])
                              .toString()),
                    if ((widget.plz["contri"] - widget.plz["spent"]) == 0)
                      Text(" Settled "),
                  ],
                )
              : Column(
                  children: <Widget>[
                    Text("Total Amount : " + widget.expense["total"].toString())
                  ],
                ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExpenseDetails(
                        this.widget.name,
                        this.widget.time,
                        this.widget.expense,
                        this.widget.sg,
                        this.widget.obj,
                        this.widget.docId,
                        widget.expense["total"],
                        this.widget.creator,
                        this.widget.pickedTime,
                        this.widget.a)));
          },
        ));
  }
}

class Pop {
  static String groupinfo = 'Leave Group';
  static String chat = 'Chat Screen';
  static String settings = 'Add Member';

  static List<String> pops = [chat, settings, groupinfo];
}
