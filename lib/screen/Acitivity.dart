import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/widget/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity>
    with AutomaticKeepAliveClientMixin {
  var da1;
  Stream<QuerySnapshot> a;
  @override
  initState() {
    super.initState();
    da1 = Provider.of<ActivityClass>(context, listen: false);
    a = da1.getActivity();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("Activity");
    return Container(
      child: StreamBuilder(
          stream: a,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<Widget> activity = [];
              snapshot.data.docs.forEach((element) {
                activity.add(Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  // height: 45,
                  margin: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Type :   " + element['type'],
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Activity :    " + element['data'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Date & Time :   " +
                              element['date'].toDate().toString(),
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ));
              });
              return activity.length != 0
                  ? ListView(
                      shrinkWrap: true,
                      children: activity,
                      scrollDirection: Axis.vertical)
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 100),
                        Text("No Activity Found")
                      ],
                    ));
            } else {
              return circularProgress();
            }
          }),
    );
  }
}
