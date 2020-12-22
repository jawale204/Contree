import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:Contri/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CreateExpense extends StatefulWidget {
  static String id = 'CreateExpense';
  final Map<String, dynamic> memberlist;
  final SingleGroup sg;
  final Groups obj;
  CreateExpense({this.memberlist, this.obj, this.sg});
  @override
  _CreateExpenseState createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  final TextEditingController description = TextEditingController();
  final TextEditingController amount = TextEditingController();
  //COntrollers f o r input values of contri and spent of user
  List<TextEditingController> contribution = [];
  List<TextEditingController> spent = [];
  SingleGroup singlegroup;
  //member name and id in list
  List<List> members;
  var contrisum = [];
  var spentsum = [];
  // bool done = false;
  var width;

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
  final _formKey = GlobalKey<FormState>();
  List<List> useThisForMembers = [];
  @override
  initState() {
    super.initState();
    // singlegroup = Provider.of<SingleGroup>(context);
    // singlegroup.allMembers(widget.obj);
    makeList();
  }

  DateTime picked;
  int selectedMonth;
  int selectedDay;
  DateTime selectedDate;
  int selectedYear;
  Future<void> getdate(context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        lastDate: new DateTime.now(),
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2020));
    if (picked != null) {
      setState(() {
        this.picked = picked;
        selectedMonth = picked.month;
        selectedDay = picked.day;
        selectedDate = picked;
        selectedYear = picked.year;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();
//converts the memberlist map to list of list //initializes th controller dynamically
  makeList() {
    widget.memberlist.forEach((key, value) => {
          members == null
              ? members = [
                  [key, value]
                ]
              : members.add([key, value])
        });
    for (var i = 0; i < (members.length); i++) {
      Map a = members[i][1];
      useThisForMembers.add([
        a['email'],
        a['name'],
        a['uid'],
        a['photoUrl'],
      ]);
    }
    members.forEach((element) {
      var contricontroller = new TextEditingController();
      var spentcontroller = new TextEditingController();
      spent == null ? spent = [spentcontroller] : spent.add(spentcontroller);
      contribution == null
          ? contribution = [contricontroller]
          : contribution.add(contricontroller);
    });
  }

//converts the usersinfo and there contri,spent in an array where 0 index is the actual total amount and for every next 4 index interval we find userinfo and contri spent
  convert(context) async {
    DateTime time = DateTime.now();
    Map<dynamic, dynamic> exp = {};
    exp.addAll({"total": int.parse(amount.value.text)});
    print(exp);
    for (var i = 0; i < members.length; i++) {
      Map<String, dynamic> smember = {};
      smember.addAll({"email": useThisForMembers[i][0]});
      smember.addAll({"name": useThisForMembers[i][1]});
      smember.addAll({"id": useThisForMembers[i][2]});
      smember.addAll({"photourl": useThisForMembers[i][3]});
      smember.addAll({"contri": contrisum[i]});
      smember.addAll({"spent": spentsum[i]});
      exp.addAll({"${i + 1}": smember});
    }

    // creates obj to add expense
    var url = "https://www.googleapis.com/books/v1/volumes?q={http}";
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var check = await widget.sg
            .addExpense(exp, description.value.text, widget.obj, time, picked);
        if (check.runtimeType == bool) {
          snackBar(true, context);
          setState(() {
            Future.delayed(const Duration(milliseconds: 700), () {
              Navigator.pop(context);
            });
          });
        } else {
          toast(check);
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      toast("NO INTERNET");
    }
  }

  snackBar(bool present, context) {
    var message;
    if (present) {
      message = 'Expense Created';
    }
    final snackBar = SnackBar(content: Text(message));
    _scaffoldstate.currentState.showSnackBar(snackBar);
  }

//validates the description and amount // also if the fields in contri and spent are empty then considers them as Zero

  validate(context) async {
    if (_formKey.currentState.validate() && selectedDate != null) {
      var contrisum = 0;
      var spentsum = 0;
      var mainamount = int.parse(amount.value.text);
      contribution.forEach((element) {
        var val;
        if (element.value.text.isNotEmpty) {
          val = int.parse(element.value.text);
        } else {
          val = 0;
        }
        contrisum = val + contrisum;
        this.contrisum == null
            ? this.contrisum = [val]
            : this.contrisum.add(val);
      });
      spent.forEach((element) {
        var val;
        if (element.value.text.isNotEmpty) {
          val = int.parse(element.value.text);
        } else {
          val = 0;
        }
        spentsum = val + spentsum;
        this.spentsum == null ? this.spentsum = [val] : this.spentsum.add(val);
      });
      if ((spentsum == contrisum) && (contrisum == mainamount)) {
        _formKey.currentState.save();
        convert(context);
      } else {
        //if amount and sum of contri and sum of spent is not equal it shows error in the error box
        this.contrisum = [];
        this.spentsum = [];
        await showerror(mainamount, contrisum, spentsum);
      }
    }
  }

//shows error
  showerror(mainamount, contrisum, spentsum) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Values doesnot match'),
              content: Container(
                width: 250,
                height: 75,
                child: Column(
                  children: <Widget>[
                    Text('Total Contribution :$contrisum'),
                    Text('Total Spent :$spentsum'),
                    Text('Actual Amount :$mainamount'),
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldstate,
      appBar: AppBar(title: Text('Add Expense'), actions: <Widget>[
        GestureDetector(
            child: Center(
                child: Text('SAVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400))),
            onTap: () {
              validate(context);
            })
      ]),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Description ';
                            }
                            if (value.length > 15) {
                              return "Enter Description in Range";
                            }
                            return null;
                          },
                          maxLength: 15,
                          maxLengthEnforced: true,
                          controller: description,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.description),
                            labelText: "Description",
                            helperText: "Enter Description (Max length 15)",
                          ),
                           keyboardType: TextInputType.text,
                          //InputDecoration(hintText: 'Enter Description (Max length 15)'),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 10,
                          maxLengthEnforced: true,
                          validator: (value) {
                            try {
                              if (value.isEmpty) {
                                return "Enter valid Amount";
                              }
                              if (value.length > 10) {
                                return "Enter Amount in Range";
                              }
                              if (int.parse(value) < 0) {
                                return "Enter valid Amount";
                              } else {
                                return null;
                              }
                            } catch (e) {
                              return "Enter valid Amount";
                            }
                          },
                          controller: amount,
                          decoration:
                          InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.monetization_on),
                              labelText: "Amount",
                              helperText: 'Amount (Max length 10)',
                            ),
                             
                          keyboardType: TextInputType.numberWithOptions(),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: width * 0.35,
                      child: Center(child: Text('Member')),
                    ),
                    SizedBox(
                      width: width * 0.30,
                      child: Center(child: Text('Contributed')),
                    ),
                    SizedBox(
                      width: width * 0.30,
                      child: Center(child: Text('spent')),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (BuildContext context, int index) {
                      // List memberholder = members[index][1].values.toList();
                      return Container(
                        height: 40,
                        margin: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: width * 0.35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "   " +
                                            useThisForMembers[index][1]
                                                .split(' ')[0],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      useThisForMembers[index][0].length > 22
                                          ? Text(
                                              "    " +
                                                  useThisForMembers[index][0]
                                                      .substring(0, 21),
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 9.0,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          : Text(
                                              "    " +
                                                  useThisForMembers[index][0],
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
                            SizedBox(
                              width: width * 0.63,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    width: width * 0.32,
                                    child: Form(
                                      child: TextFormField(
                                        buildCounter: (BuildContext context,
                                                {int currentLength,
                                                int maxLength,
                                                bool isFocused}) =>
                                            null,
                                        controller: contribution[index],
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightBlueAccent,
                                                width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightBlueAccent,
                                                width: 2.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                        ),
                                        maxLength: 8,
                                        maxLengthEnforced: true,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        validator: (value) {
                                          try {
                                            if (value.isEmpty) {
                                              return "Enter valid Amount";
                                            }
                                            if (int.parse(value) < 0) {
                                              return "Enter valid Amount";
                                            } else {
                                              return null;
                                            }
                                          } catch (e) {
                                            return "Enter valid Amount";
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 20,
                                  // ),
                                  Container(
                                    width: width * 0.31,
                                    child: Form(
                                      child: TextFormField(
                                        buildCounter: (BuildContext context,
                                                {int currentLength,
                                                int maxLength,
                                                bool isFocused}) =>
                                            null,
                                        controller: spent[index],
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightBlueAccent,
                                                width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightBlueAccent,
                                                width: 2.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                        ),
                                        maxLength: 8,
                                        maxLengthEnforced: true,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        validator: (value) {
                                          try {
                                            if (value.isEmpty) {
                                              return "Enter valid Amount";
                                            }
                                            if (int.parse(value) < 0) {
                                              return "Enter valid Amount";
                                            } else {
                                              return null;
                                            }
                                          } catch (e) {
                                            return "Enter valid Amount";
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 10,
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: RaisedButton(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledColor: Colors.white,
                        onPressed: () {
                          getdate(context);
                        },
                        child: Text(
                          "Select date",
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      Container(
                          height: 43,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              selectedDay.toString() +
                                  "," +
                                  months[selectedMonth - 1] +
                                  " " +
                                  selectedYear.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
