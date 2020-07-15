import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/screen/Acitivity.dart';
import 'package:Contri/screen/Group.dart';
import 'package:Contri/screen/Personalexp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
   static String id='Body';
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body>with TickerProviderStateMixin {
 TabController _controller;
  @override
  initState(){
    super.initState();
    _controller=TabController(initialIndex: 1,length: 3, vsync: this,);
  }

 final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>(); 
  @override
  Widget build(BuildContext context) {
    final user=Provider.of<HandleUser>(context);
    return ChangeNotifierProvider(
      create: (c)=>Groups(),
          child: Scaffold(
            key: _scaffoldstate ,
        appBar: AppBar(actions: <Widget>[
          IconButton(icon: Icon(Icons.power_settings_new), onPressed:(){ 
           user.logout(context);
          })
        ],
        title: Text('ExpenseManage'),
       bottom: TabBar(
         controller: _controller ,
         tabs: [
            Tab(child:Text('Daily Expense') ,),
            Tab(child:Text('Groups')),
            Tab(child:Text('Activity')),
       ]),
        ),
        body: TabBarView(
        controller: _controller,
      children: <Widget>[
          PersonalExp(),
          Group(_scaffoldstate),
          Activity()
        ]),
  
      ),
    );
  }
}