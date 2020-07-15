import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/widget/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    final da = Provider.of<Daily>(context);
    Future<QuerySnapshot> a = da.getActivity();
    return Container(
      child: FutureBuilder(
          future: a,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<Widget> activity = [];
              snapshot.data.documents.forEach((element) {
                activity.add(Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 45,
                  margin: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        element['data'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ),
                  ),
                ));
              });
              return ListView(
                  shrinkWrap: true,
                  children: activity,
                  scrollDirection: Axis.vertical);
            } else {
              return circularProgress();
            }
          }),
    );
  }
}
