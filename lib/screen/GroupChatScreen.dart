import 'package:Contri/models/Groups.dart';
import 'package:Contri/models/HandleUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Groups obj;
  ChatScreen({this.obj});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messcontroller = TextEditingController();
  final key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GroupChat'),),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(widget.obj),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      focusColor: Colors.brown,
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    controller: messcontroller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: FlatButton(
                    color: Colors.blueAccent,
                      onPressed: () {
                        if (messcontroller.value.text.isNotEmpty) {
                          Firestore.instance
                              .collection('GroupsDB')
                              .document(widget.obj.groupId)
                              .collection('Chats')
                              .add({
                            'txt': messcontroller.value.text,
                            'date': DateTime.now().toIso8601String().toString(),
                            'sendby': HandleUser.userinfo.email
                          });
                          messcontroller.clear();
                        }
                      },
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final Groups obj;
  MessageStream(this.obj);

  @override
  Widget build(BuildContext context) {
    DocumentReference groups =
        Firestore.instance.collection('GroupsDB').document(obj.groupId);
    return Flexible(
          child: StreamBuilder<QuerySnapshot>(
          stream: groups.collection('Chats').orderBy('date').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> a) {
            if (a.hasData) {
              final messages = a.data.documents.reversed;
              List<MessageBubble> bubbles = [];
              messages.forEach((doc) {
                bool isme = false;
                if (HandleUser.userinfo.email == doc['sendby']) {
                  isme = true;
                }
                bubbles.add(
                    MessageBubble(isme, doc['txt'], doc['date'], doc['sendby']));
              });
              return ListView(
                shrinkWrap: true,
                children: bubbles,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                reverse: true,
              );
            } else {
              return CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              );
            }
          }),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String txt;
  final String date;
  final String sendby;
  MessageBubble(this.isMe, this.txt, this.date, this.sendby);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sendby,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                txt,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
