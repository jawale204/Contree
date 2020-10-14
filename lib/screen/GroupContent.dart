import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:Contri/screen/ExpenseDetail.dart';
import 'package:Contri/screen/Group.dart';
import 'package:Contri/screen/GroupChatScreen.dart';
import 'package:Contri/screen/SearchUsers.dart';
import 'package:Contri/screen/createExpense.dart';
import 'package:Contri/widget/progress.dart';
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
  Future<QuerySnapshot> allExpenses;
  Map<String, dynamic> memberlist;
  Future<QuerySnapshot> b;
  List<List> settleAndpay;
  int totalallexpense;
  List<List> membersCS = [];

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  dothis(sg) async {
    memberlist = await sg.allMembers(widget.obj);
  }

  settleandpay1(List sengleExp) {
    var j = 1;
    var cal = [];
    totalallexpense = totalallexpense + sengleExp[0];
    for (var i = 1; i <= sengleExp.length / 4; i++) {
      var a = [
        sengleExp[j],
        sengleExp[j + 1],
        sengleExp[j + 2],
        sengleExp[j + 3]
      ];
      cal.add(a);
      j = j + 4;
    }
    settleAndpay.add(cal);
  }

  settleandpay2(List<List> sAnde) {
    membersCS = [];
    memberlist.forEach((key, value) => {
          membersCS == null
              ? membersCS = [
                  [key, value]
                ]
              : membersCS.add([key, value])
        });
    for (var i = 0; i < sAnde.length; i++) {
      for (var j = 0; j < sAnde[i].length; j++) {
        if (membersCS[j].length < 3) {
          membersCS[j].add(sAnde[i][j][2]);
          membersCS[j].add(sAnde[i][j][3]);
        } else {
          membersCS[j][2] = sAnde[i][j][2] + membersCS[j][2];
          membersCS[j][3] = sAnde[i][j][3] + membersCS[j][3];
        }
      }
    }
  }

  dothisForExpenseTile(expense) {
    List<List> cal = [];
    var j = 1;
    for (var i = 1; i <= expense.length / 6; i++) {
      cal.add([
        expense[j],
        expense[j + 1],
        expense[j + 2],
        expense[j + 3],
        expense[j + 4],
        expense[j + 5]
      ]);
      j = j + 6;
    }
    return cal;
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
      SingleGroup sbg = new SingleGroup();
      await sbg.leaveGroup(widget.obj);
      Navigator.of(context).popUntil(ModalRoute.withName(Group.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sg = Provider.of<SingleGroup>(context, listen: true);
    allExpenses = sg.allExpense(widget.obj);
    dothis(sg);
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
            child: FutureBuilder(
              initialData: b,
              future: allExpenses,
              builder: (BuildContext content, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  totalallexpense = 0;
                  settleAndpay = [];
                  snapshot.data.documents.forEach((data1) {
                    var a = SingleGroup.fromDocument(data1);
                    settleandpay1(a.expense);
                  });
                  // if (settleAndpay.length > 0) {
                  //   settleandpay2(settleAndpay);
                  // return NamesAndOther(
                  //     totalallexpense: totalallexpense, membersCS: membersCS);
                  //   return Text(
                  //     'Group Expense : ' + totalallexpense.toString(),
                  //     style: TextStyle(
                  //         fontSize: 25,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white),
                  //   );
                  // } else {
                  return Text(
                    'Group Expense : ' + (totalallexpense).toString(),
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                  //  }
                } else {
                  return Text(
                    'Group Expense : ' + 0.toString(),
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }
              },
            ),
            preferredSize: Size.fromHeight(200.0)),
      ),
      body: Column(children: <Widget>[
        Expanded(
          flex: 5,
          child: Stack(
            children: <Widget>[
              FutureBuilder<QuerySnapshot>(
                  future: allExpenses,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    List<ExpensTile> names = [];
                    if (snapshot.hasData) {
                      var i = 0;
                      snapshot.data.documents.forEach((data1) {
                        var a = SingleGroup.fromDocument(data1);
                        // var go=dothisForExpenseTile(a.expense);
                        names.add(new ExpensTile(
                            a.name, a.date, a.expense, sg, widget.obj, i));
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                //passing Groups obj and members list to the createexpense page
                                builder: (context) => CreateExpense(
                                    memberlist: memberlist,
                                    obj: widget.obj,
                                    sg: sg)));
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

// class NamesAndOther extends StatelessWidget {
//   const NamesAndOther({
//     Key key,
//     @required this.totalallexpense,
//     @required this.membersCS,
//   }) : super(key: key);

//   final int totalallexpense;
//   final List<List> membersCS;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10),
//       child: Column(
//         children: <Widget>[
//           Text(
//             'Group Expense : ' + totalallexpense.toString(),
//             style: TextStyle(
//                 fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           ListView.builder(
//               shrinkWrap: true,
//               itemCount: membersCS.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return Container(
//                   height: 30,
//                   margin: EdgeInsets.all(3.0),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.0),
//                       color: Colors.grey[300]),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             "    " + membersCS[index][0],
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 17.0,
//                                 fontWeight: FontWeight.w400),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: <Widget>[
//                           if (membersCS[index][2] - membersCS[index][3] < 0)
//                             Container(
//                                 width: 105,
//                                 child: Text('owes : ' +
//                                     (-(membersCS[index][2] -
//                                             membersCS[index][3]))
//                                         .toString())),
//                           if (membersCS[index][2] - membersCS[index][3] > 0)
//                             Container(
//                               width: 105,
//                               child: Text('should get : ' +
//                                   (-(membersCS[index][3] - membersCS[index][2]))
//                                       .toString()),
//                             ),
//                           if (membersCS[index][2] - membersCS[index][3] == 0)
//                             Container(
//                               width: 105,
//                               child: Text('settled'),
//                             ),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               }),
//         ],
//       ),
//     );
//   }
// }

class ExpensTile extends StatefulWidget {
  final String name;
  final DateTime time;
  final List<dynamic> expense;
  final SingleGroup sg;
  final Groups obj;
  final int docId;

  ExpensTile(this.name, this.time, this.expense, this.sg, this.obj, this.docId);
  @override
  _ExpensTileState createState() => _ExpensTileState();
}

class _ExpensTileState extends State<ExpensTile> {
  var j;
  @override
  initState() {
    super.initState();
    dothis();
  }

  dothis() {
    var j = 1;
    for (var i = 1; i <= widget.expense.length / 6; i++) {
      if (HandleUser.userinfo.uid == widget.expense[j + 2]) {
        this.j = j;
      }
      j = j + 6;
    }
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
          subtitle: Text("Your Conti : " + widget.expense[j + 4].toString()),
          trailing: Column(
            children: <Widget>[
              Text("Total Amount : " + this.widget.expense[0].toString()),
              if ((widget.expense[j + 4] - widget.expense[j + 5]) < 0)
                Text("You owe : " +
                    (-(widget.expense[j + 4] - widget.expense[j + 5]))
                        .toString()),
              if ((widget.expense[j + 4] - widget.expense[j + 5]) > 0)
                Text("You lend : " +
                    (widget.expense[j + 4] - widget.expense[j + 5]).toString()),
              if ((widget.expense[j + 4] - widget.expense[j + 5]) == 0)
                Text(" Settled "),
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
                        this.widget.expense[0])));
          },
        ));
  }
}

class Pop {
  static String groupinfo = 'Leave Group';
  static String chat = 'Chat Screen';
  static String settings = 'Add Member';

  static List<String> pops = [groupinfo, chat, settings];
}
