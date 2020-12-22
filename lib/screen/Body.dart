import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/screen/Acitivity.dart';
import 'package:Contri/screen/Group.dart';
import 'package:Contri/screen/Personalexp.dart';
import 'package:Contri/screen/PieChart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  static String id = 'Body';
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with TickerProviderStateMixin {
  TabController _controller;
  @override
  initState() {
    super.initState();
    _controller = TabController(
      initialIndex: 1,
      length: 3,
      vsync: this,
    );
  }

  logout(user) {
    user.logout(context);
  }

  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<HandleUser>(context);
    return ChangeNotifierProvider(
      create: (c) => Groups(),
      child: Scaffold(
        key: _scaffoldstate,
        appBar: AppBar(
          title: Text('Contri'),
          bottom: TabBar(controller: _controller, tabs: [
            Tab(
              child: Text('Daily Expense'),
            ),
            Tab(child: Text('Groups')),
            Tab(child: Text('Activity')),
          ]),
        ),
        body: TabBarView(controller: _controller, children: <Widget>[
          PersonalExp(),
          Group(_scaffoldstate),
          Activity()
        ]),
        drawer: Drawer(
            child: ListView(
          children: [
              
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  accountEmail: Text(HandleUser.userinfo.email,
                      style: TextStyle(fontSize: 20)),
                  accountName: Text(HandleUser.userinfo.displayName,
                      style: TextStyle(fontSize: 25)),
                  currentAccountPicture: Center(
                      heightFactor: 100,
                      widthFactor: 100,
                      child: CircleAvatar(
                        radius: 50,
                        child: Image.network(
                          HandleUser.userinfo.photoUrl,
                        ),
                      ))),
            ),
              Container(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Piechart.id);
                },
                child: ListTile(
                  title: Text("Pie Chart", style: TextStyle(fontSize: 20,color:Colors.blueAccent)),
                  trailing: Icon(Icons.pie_chart,color: Colors.blueAccent),
                ),
              ),
            ),
            Container(
                child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content:
                            const Text('Do you want to logout of the app?'),
                        actions: <Widget>[
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
                                child: const Text('LOGOUT'),
                                onPressed: () {
                                  logout(user);
                                },
                              )
                            ],
                          ),
                        ],
                      );
                    });
              },
              child: ListTile(
                title: Text("Logout", style: TextStyle(fontSize: 20,color:Colors.blueAccent)),
                trailing: Icon(Icons.logout,color:Colors.blueAccent),
              ),
            )),
          ],
        )),
      ),
    );
  }
}
