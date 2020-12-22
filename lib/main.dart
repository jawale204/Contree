import 'package:Contri/models/HandleUser.dart';
import 'package:Contri/models/dailyexpenseandActivity.dart';
import 'package:Contri/models/singleGroup.dart';
import 'package:Contri/screen/Body.dart';
import 'package:Contri/screen/NewCreatePersonalexp.dart';
import 'package:Contri/screen/PieChart.dart';
import 'package:Contri/screen/TakePEInput.dart';
import 'package:Contri/screen/Welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


void main()async {
   
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    
    runApp(Notes());
  });
}

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

String a;

class _NotesState extends State<Notes> {
// final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  
  @override
  void initState() {
    super.initState();
   
  }

  @override
  void dispose() {
    super.dispose();
  }

 

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HandleUser()),
        ChangeNotifierProvider<SingleGroup>(create: (context) => SingleGroup()),
        ChangeNotifierProvider(create: (context) => Daily()),
        ChangeNotifierProvider(create: (context)=> ActivityClass(),)
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Welcome.id,
          routes: {
            Welcome.id: (context) => Welcome(),
            Body.id: (context) => Body(),
            SelectCategory.id:(context)=>SelectCategory(),
            TakePEInput.id:(context)=>TakePEInput(),
            Piechart.id:(contect)=>Piechart()
          }),
    );
  }
}
