import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupExpenseData extends StatefulWidget {
  final Groups obj;
  GroupExpenseData({this.obj});
  @override
  _GroupExpenseDataState createState() => _GroupExpenseDataState();
}

class _GroupExpenseDataState extends State<GroupExpenseData> {
  GlobalKey<ScaffoldState> _scaffoldstate = GlobalKey<ScaffoldState>();
  Stream<QuerySnapshot> a;
  Stream<QuerySnapshot> b;
  List<dynamic> check = [];
  List<dynamic> memberIds = [];
  Map<String, dynamic> totalSheet = {};
  var totalExp = 0;
  dothething(expense, name, date) {
    if (check.contains([name, date])) {
      return null;
    } else {
      totalExp = totalExp + expense["total"];
      check.add([name, date]);
      expense.forEach((key, value) {
        if (key != "total") {
          value.forEach((key1, value2) {
            if (key1 == "id") {
              if (!memberIds.contains(value2)) {
                totalSheet.addAll({value2: value});
                memberIds.add(value2);
              } else {
                Map<String, dynamic> use = totalSheet[value2];
                use['spent'] = use['spent'] + value['spent'];
                use['contri'] = use['contri'] + value['contri'];
              }
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var allexpense = Provider.of<SingleGroup>(context);
    a = allexpense.allExpense(widget.obj);
    return Scaffold(
      key: _scaffoldstate,
      appBar: AppBar(
        title: Text(widget.obj.groupName),
        centerTitle: true,
      ),
      body:
          ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: <
              Widget>[
        StreamBuilder(
            initialData: b,
            stream: a,
            builder: (BuildContext content, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                totalExp = 0;
                check = [];
                totalSheet = {};
                memberIds = [];
                snapshot.data.documents.forEach((doc) {
                  var a = SingleGroup.fromDocument(doc);
                  dothething(a.expense, a.name, a.date);
                });
                return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,

                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Expense Amount : ' + totalExp.toString(),
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: Center(child: Text('Member')),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: Center(child: Text('Contri')),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: Center(child: Text('spent')),
                          ),
                           SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: Center(child: Text('owe/lend')),
                          ),
                        ],
                      ),
                      if(memberIds.length>0)
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: memberIds.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map<dynamic, dynamic> plz =
                                totalSheet[memberIds[index]];
                            return Container(
                              height: 40,
                              margin: EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[300]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            plz["name"].split(" ")[0].length <
                                                    12
                                                ? Text(
                                                    "   " +
                                                        plz["name"]
                                                            .split(" ")[0],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                : Text(
                                                    "   " +
                                                        plz["name"]
                                                            .toString()
                                                            .split(" ")[0],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                            plz['email'].length < 19
                                                ? Text(
                                                    "      " + plz['email'],
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 9.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                : Text(
                                                    "      " +
                                                        plz['email']
                                                            .toString()
                                                            .substring(0, 19),
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 9.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Center(
                                            child: Text(
                                                (plz["contri"]).toString())),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Center(
                                            child: Text(
                                                (plz["spent"]).toString())),
                                      ),
                                       plz["contri"]-plz["spent"]>0?SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Center(
                                            child: Text(
                                                (plz["contri"]-plz["spent"]).toString()+"(L)")),
                                      ):SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Center(
                                            child: Text(
                                                (-(plz["contri"]-plz["spent"])).toString()+"(O)")),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        if(memberIds.length==0)

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("NO EXPENSE FOUND",style: TextStyle(fontSize:30,fontWeight: FontWeight.bold,color:Colors.blue))),
                        )
                        ,
                    ]);
              } else {
                return Center(child: Text("NO EXPENSE"));
              }
            }),
        SizedBox(
          height: 30,
        ),

        // Center(
        //   child: SaveButton(
        //       txt: 'Delete Expense',
        //       onpress: () {
        //         //  doit(context);
        //         //        Navigator.of(context).popUntil(ModalRoute(Group.id)) ;
        //       }),
        // )
      ]),
    );
  }
}
