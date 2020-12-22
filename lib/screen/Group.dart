import 'package:Contri/models/Groups.dart';
import 'package:Contri/screen/GroupContent.dart';
import 'package:Contri/widget/constants.dart';
import 'package:Contri/widget/genbutton.dart';
import 'package:Contri/widget/progress.dart';
import 'package:Contri/widget/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//DateTime date = DateTime.now();

class Group extends StatefulWidget {
  static String id = 'Group';
  final GlobalKey<ScaffoldState> scaffoldcontroller;
  Group(this.scaffoldcontroller);
  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> with AutomaticKeepAliveClientMixin {
  TextEditingController controller = TextEditingController();
  Future<QuerySnapshot> b;
  GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  var groupsdoc;
  Stream<QuerySnapshot> a;
  @override
  initState() {
    super.initState();
    groupsdoc = Provider.of<Groups>(context, listen: false);
    a = groupsdoc.getGroups();
  }

  @override
  bool get wantKeepAlive => true;
  snackBar(bool present) {
    final snackBar = SnackBar(
      content: Text('Group Created'),
      duration: Duration(seconds: 2, milliseconds: 500),
    );
    widget.scaffoldcontroller.currentState.showSnackBar(snackBar);
  }

  dothis(groupsdoc) async {
    DateTime date1 = DateTime.now();
    Navigator.pop(context);

    dynamic check =
        await groupsdoc.createGroup(controller.value.text.toString(), date1);
    if (check.runtimeType != bool) {
      toast(check);
    }
    controller.clear();
  }

  Future<Null> doonrefresh(groupsdoc, a) async {
    a = await groupsdoc.getGroups();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("group");
    return RefreshIndicator(
      key: _refresh,
      onRefresh: () {
        return doonrefresh(groupsdoc, a);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Stack(children: <Widget>[
              StreamBuilder(
                stream: a,
                initialData: b,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<GroupList> searchGroup = [];
                    snapshot.data.documents.forEach((doc) {
                      Groups singleGroup = Groups.fromDocument(doc);
                      GroupList list = GroupList(ekGroup: singleGroup);
                      searchGroup.add(list);
                    });
                    return searchGroup.length != 0
                        ? ListView(
                            children: searchGroup,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          )
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group_add, size: 100),
                              Text("No Groups Found")
                            ],
                          ));
                  } else {
                    return circularProgress();
                  }
                },
              ),
              Positioned(
                bottom: 20,
                right: 50,
                left: 50,
                child: SaveButton(
                  txt: 'Create a new Group',
                  onpress: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Create New Group'),
                            content: Container(
                              width: 250,
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextField(
                                      controller: controller,
                                      decoration: KTextDecoration.copyWith(
                                          hintText: 'Enter group Name',
                                          hintStyle: TextStyle(
                                              color: Colors.black54))),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              Center(
                                child: SaveButton(
                                  onpress: () {
                                    if (controller.value.text
                                            .toString()
                                            .isNotEmpty &&
                                        controller.value.text
                                            .trim()
                                            .isNotEmpty) {
                                      dothis(groupsdoc);
                                    }
                                  },
                                  txt: 'Save',
                                ),
                              ),
                            ],
                          );
                        });
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class GroupList extends StatelessWidget {
  final Groups ekGroup;
  //takes Groups object for that group
  GroupList({this.ekGroup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(
        title: Text(ekGroup.groupName),
        leading: Icon(Icons.group),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              //pass that Groups object to the GroupContent page
              builder: (context) => GroupContent(obj: ekGroup),
            ),
          );
        },
      ),
    );
  }
}
