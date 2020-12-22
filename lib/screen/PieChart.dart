import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/models/icons.dart';
import 'package:Contri/widget/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class Piechart extends StatefulWidget {
  static String id = "PieChart";
  @override
  _PiechartState createState() => _PiechartState();
}

class _PiechartState extends State<Piechart> {
  String dropdownyear = DateTime.now().year.toString();
  String typeoftran = "Expense";
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
  Set<Color> colorExp = {};
  Map<String, double> pieDataExp = new Map();
  Set<Color> colorInc = {};
  Map<String, double> pieDataInc = new Map();
  var personal;
  Stream<QuerySnapshot> a;
  @override
  initState() {
    super.initState();
  }

  sortingChange() {
    a = personal.getPersonalExp(dropdownmonth, dropdownyear, typeoftran);
  }

  @override
  void didChangeDependencies() {
    personal = Provider.of<Daily>(context);
    a = personal.getPersonalExp(dropdownmonth, dropdownyear, typeoftran);
    super.didChangeDependencies();
  }

  forPieData(Daily dai) {
    if (dai.type == "Expense") {
      Category single = CategoryIconService.expensetype[dai.category];
      colorExp.add(single.color);
      pieDataExp.addAll({single.name: double.parse(dai.amount)});
    } else {
      Category single = CategoryIconService.incomelist[dai.category];
      colorInc.add(single.color);
      pieDataInc.addAll({single.name: double.parse(dai.amount)});
    }
  }

  @override
  Widget build(BuildContext context) {
    // var personal = Provider.of<Daily>(context);
    // Stream<QuerySnapshot> a =
    //     personal.getPersonalExp(dropdownmonth, dropdownyear, typeoftran);
    return Scaffold(
      appBar: AppBar(title: Text("Pie Chart")),
      body: Column(
        children: [
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
                        items: <String>["Expense", "Income"]
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
            child: StreamBuilder(
                stream: a,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    colorInc = {};
                    colorExp = {};
                    pieDataInc = {};
                    pieDataExp = {};
                    snapshot.data.documents.forEach((doc) {
                      Daily dai = Daily.fromDocument(doc);
                      forPieData(dai);
                    });
                    if (typeoftran == "Income" && pieDataInc.isEmpty) {
                      pieDataInc.addAll({"No Income": 100});
                      colorInc.add(Colors.blueAccent);
                    }
                    if (typeoftran == "Expense" && pieDataExp.isEmpty) {
                      pieDataExp.addAll({"No Expense": 100});
                      colorExp.add(Colors.blueAccent);
                    }
                    print(colorExp);
                    print(pieDataExp);
                    return SafeArea(
                      child: PieChart(
                        dataMap:
                            typeoftran == "Income" ? pieDataInc : pieDataExp,
                        colorList: typeoftran == "Income"
                            ? colorInc.toList()
                            : colorExp.toList(),
                        animationDuration: Duration(milliseconds: 2000),
                        initialAngleInDegree: 0,
                        chartValuesOptions: ChartValuesOptions(
                            showChartValuesInPercentage: true,
                            showChartValues: true),
                      ),
                    );
                  }
                  return circularProgress();
                }),
          )
        ],
      ),
    );
  }
}
