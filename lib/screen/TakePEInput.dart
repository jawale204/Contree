import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/models/icons.dart';
import 'package:Contri/widget/genbutton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TakePEInput extends StatelessWidget {
  final String type;
  final Category category;
  static final id = "TakePEInput";
  TakePEInput({this.type, this.category});
  final _description = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  validate(context, Daily personal) async {
    DateTime date = DateTime.now();
    bool yo = false;
    if (_formKey.currentState.validate() && personal.selectedDate != null) {
      yo = await personal.createPersonalExp(
          _description.value.text.toString(),
          _amount.value.text,
          date,
          personal.selectedDate,
          personal.selectedDay,
          personal.selectedMonth,
          personal.selectedYear,
          type,
          category);
    }
    if (yo) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var personal = Provider.of<Daily>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(type),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      category.icon,
                      size: 25,
                      color: category.color,
                    )),
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                BuildTextField(
                  controller: _description,
                  icon: Icons.edit,
                  labeltext: "Description",
                  helpertext: "Enter the Description",
                  isint: false,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter Description";
                    }
                    if (value.length > 15) {
                      return "Enter Dexcription in Range";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 5),
                BuildTextField(
                    controller: _amount,
                    labeltext: "Amount",
                    icon: Icons.monetization_on,
                    helpertext: "Enter the Amount",
                    isint: true,
                    validator: (value) {
                      try {
                        if (value.isEmpty) {
                          return "Enter valid Amount";
                        }
                        if (value.length > 10) {
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
                    }),
              ],
            ),
          ),
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
                    personal.getdate(context, personal);
                  },
                  child: Text(
                    "Select date",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),
              ),
              if (personal.selectedDate != null)
                Container(
                    height: 43,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        personal.selectedDay.toString() +
                            "," +
                            personal.months[personal.selectedMonth - 1] +
                            " " +
                            personal.selectedYear.toString(),
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    ))
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 50,
            child: Center(
              child: SaveButton(
                txt: 'Create',
                onpress: () {
                  validate(context, personal);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BuildTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labeltext;
  final String helpertext;
  final bool isint;
  final Function validator;
  final IconData icon;
  BuildTextField(
      {this.controller,
      this.labeltext,
      this.helpertext,
      this.isint,
      this.validator,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      maxLines: 1,
      maxLength: isint ? 10 : 15,
      maxLengthEnforced: true,
      keyboardType: isint ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        icon: Icon(icon),
        labelText: labeltext,
        helperText: helpertext,
      ),
    );
  }
}
