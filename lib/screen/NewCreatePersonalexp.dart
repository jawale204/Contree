import 'package:Contri/models/icons.dart';
import 'package:Contri/screen/TakePEInput.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  static String id = "CreatePersonalExp";
  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  String dropDownValue = "Expense";

  loadCategoryIcons() {
    if (dropDownValue == "Expense") {
      return CategoryIconService.expensetype;
    }
    if (dropDownValue == "Income") {
      return CategoryIconService.incomelist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.blue[400]),
          child: DropdownButton(
              value: dropDownValue,
              isDense: true,
              elevation: 16,
              onChanged: (value) {
                setState(() {
                  dropDownValue = value;
                });
              },
              items:
                  <String>['Income', 'Expense'].map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(fontSize: 20, color: Colors.white)));
                },
              ).toList()),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: loadCategoryIcons().map<InkWell>((e) {
          return InkWell(
            onTap: () {
              print(e.name);
              Navigator.push(context,MaterialPageRoute(builder: (context)=> TakePEInput(
                type: dropDownValue,
                category:e
              )));
            },
            child: Container(
              margin: EdgeInsets.all(3.0),
              color: Colors.blueGrey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(e.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 30,
                        child: Icon(
                          e.icon,
                          size: 25,
                          color: e.color,
                        )),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
