import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  final int index;
  final String name;
  final IconData icon;
  final Color color;

  Category(this.index, this.name, this.icon, this.color);
}

class CategoryIconService {
  static final expensetype = [
    Category(0, "Food", FontAwesomeIcons.pizzaSlice, Colors.green),
    Category(1, "Bills", FontAwesomeIcons.moneyBill, Colors.amber[100]),
    Category(2, "Transportaion", FontAwesomeIcons.bus, Colors.grey),
    Category(3, "Home", FontAwesomeIcons.home, Colors.orange[300]),
    Category(4, "Entertainment", FontAwesomeIcons.gamepad, Colors.cyanAccent),
    Category(5, "Shopping", FontAwesomeIcons.shoppingBag, Colors.deepOrange),
    Category(6, "Clothing", FontAwesomeIcons.tshirt, Colors.indigo),
    Category(7, "Insurance", FontAwesomeIcons.hammer, Colors.green[200]),
    Category(8, "Telephone", FontAwesomeIcons.phone, Colors.pink[200]),
    Category(9, "Health", FontAwesomeIcons.briefcaseMedical, Colors.lime),
    Category(10, "Sport", FontAwesomeIcons.footballBall, Colors.brown[100]),
    Category(11, "Beauty", FontAwesomeIcons.marker, Colors.pink),
    Category(12, "Education", FontAwesomeIcons.book, Colors.tealAccent[400]),
    Category(13, "Gift", FontAwesomeIcons.gift, Colors.red),
    Category(14, "Other", FontAwesomeIcons.ellipsisH, Colors.deepPurpleAccent),
  ];

 static final incomelist = [
    Category(0, "Salary", FontAwesomeIcons.wallet, Colors.tealAccent[400]),
    Category(1, "Awards", FontAwesomeIcons.moneyCheck, Colors.pink[200]),
    Category(2, "Grants", FontAwesomeIcons.gifts, Colors.lightGreen),
    Category(3, "Rental", FontAwesomeIcons.houseUser, Colors.yellow),
    Category(4, "Investment", FontAwesomeIcons.piggyBank, Colors.cyanAccent),
    Category(5, "Lottery", FontAwesomeIcons.dice, Colors.deepOrange),
 ];
}
