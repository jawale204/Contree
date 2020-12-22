import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:Contri/widget/genbutton.dart';
import 'package:Contri/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
class ExpenseDetails extends StatelessWidget {
  final String name;
  final dynamic time;
  final Map<dynamic, dynamic> expense;
  final SingleGroup sg;
  final int docId;
  final int total;
  final Groups obj;
  final String creator;
  final dynamic pickedTime;
  final SingleGroup a;
  ExpenseDetails(this.name, this.time, this.expense, this.sg, this.obj,
      this.docId, this.total, this.creator, this.pickedTime,this.a);
  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();
  snackBar(bool present) {
    if (present != null) {
      var message;
      if (present) {
        message = 'Expense deleted';
      }
      final snackBar = SnackBar(content: Text(message));
      _scaffoldstate.currentState.showSnackBar(snackBar);
    }
  }

  final List months = [
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

  doit(context) async {
      var url = "https://www.googleapis.com/books/v1/volumes?q={http}";
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print('ala');
    bool p = await sg.deleteExpense(docId, obj, a);
    snackBar(p);

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      toast("NO INTERNET");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldstate,
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
      ),
      body:
          ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: <
              Widget>[
        SizedBox(
          height: 40,
        ),
        Center(
          child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Expense Amount : ' + total.toString(),
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
              width: MediaQuery.of(context).size.width * 0.35,
              child: Center(child: Text('Member')),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: Center(child: Text('Contributed')),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: Center(child: Text('spent')),
            ),
          ],
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: expense.length - 1,
            itemBuilder: (BuildContext context, int index) {
              Map<dynamic, dynamic> plz = expense["${index + 1}"];
              return Container(
                height: 40,
                margin: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[300]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.34,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              plz["name"].split(" ")[0].length < 12
                                  ? Text(
                                      "   " + plz["name"].split(" ")[0],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : Text(
                                      "   " +
                                          plz["name"].toString().split(" ")[0],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                              plz['email'].length < 22
                                  ? Text(
                                      "      " + plz['email'],
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : Text(
                                      "      " +
                                          plz['email']
                                              .toString()
                                              .substring(0, 21),
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child:
                              Center(child: Text((plz["contri"]).toString())),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Center(child: Text((plz["spent"]).toString())),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        SizedBox(
          height: 30,
        ),
        Container(
            height: 43,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Text("Date of Expense:"),
                Text(
                  "Date of Expense : " +
                      pickedTime.toDate().day.toString() +
                      "," +
                      months[pickedTime.toDate().month - 1] +
                      " " +
                      pickedTime.toDate().year.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
        SizedBox(
          height: 30,
        ),
        Center(
          child: SaveButton(
              txt: creator == HandleUser.userinfo.email
                  ? "Delete Expense"
                  : "$creator",
              onpress: () {
                creator == HandleUser.userinfo.email
                    ? doit(context)
                    : print("ucant");
              }),
        )
      ]),
    );
  }
}
