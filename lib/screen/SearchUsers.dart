import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:Contri/widget/progress.dart';
import 'package:Contri/widget/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as http;

class Search extends StatefulWidget {
  final Groups obj;
  Search({this.obj});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController controller = TextEditingController();
  Future<QuerySnapshot> userResult;
  var loading = false;
  handleSearchQuery(String query) {
    loading = true;
    Future<QuerySnapshot> users = userRef
        .where('email', isGreaterThanOrEqualTo: query, isEqualTo: query)
        .get();
    setState(() {
      userResult = users;
      loading = false;
    });
  }

  clears() {
    controller.clear();
  }

  AppBar headSearch() {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Column(
        children: <Widget>[
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: 'search for user',
                prefixIcon: Icon(
                  Icons.account_box,
                  size: 35,
                  color: Colors.blue,
                ),
                suffixIcon:
                    IconButton(icon: Icon(Icons.clear), onPressed: clears()),
                filled: true),
            onFieldSubmitted: handleSearchQuery,
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldstate,
        backgroundColor: Colors.white,
        appBar: headSearch(),
        body: loading
            ? circularProgress()
            : FutureBuilder(
                future: userResult,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text("Search using Email Id"));
                  } else {
                    List<Container> searchResults = [];
                    snapshot.data.documents.forEach((doc) {
                      User user = User.fromDocument(doc);
                      Container searchresult =
                          useRResult(user, context, widget.obj, _scaffoldstate);
                      searchResults.add(searchresult);
                    });
                    return searchResults.length != 0
                        ? ListView(
                            children: searchResults,
                          )
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group, size: 100),
                              Text("No User Found")
                            ],
                          ));
                  }
                }));
  }
}

Container useRResult(User users, context, obj, key) {
  snackBar(bool present) {
    var message = !present ? 'Member added' : 'User already in the group';
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2, milliseconds: 500),
    );
    key.currentState.showSnackBar(snackBar);
  }

  final sg = Provider.of<SingleGroup>(context);
  doit() async {
    var url = "https://www.googleapis.com/books/v1/volumes?q={http}";
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        bool p = await sg.addMember(users, obj);
    Navigator.pop(context);
    snackBar(!p);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      toast("NO INTERNET");
    }
    
  }

  return Container(
    color: Colors.grey[400],
    child: Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Center(child: Text('Add User ?')),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          
                          Center(
                              child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          )),
                          Center(
                            child: FlatButton(
                              onPressed: () {
                                doit();
                              },
                              // txt: 'Add in Group',
                              child: Text("Add in Group"),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                })
          },
          child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(users.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: Text(
                users.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(users.email,
                  style: TextStyle(
                    color: Colors.white54,
                  ))),
        ),
        Divider(
          height: 2,
          color: Colors.white54,
        )
      ],
    ),
  );
}
