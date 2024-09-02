import 'package:flutter/material.dart';
import 'package:flutter_test_1/list_page_widget.dart';
import 'package:flutter_test_1/login_widget.dart';
//import '_login_page.dart';
import 'ranking_widget.dart';
import 'home_page_widget.dart';
import 'list_maker_widget.dart';
import 'login_widget.dart';
import 'globals.dart' as globals;

void main() {
  globals.user_id_global = -1;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var user_id;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(), 
      routes:{
        '/login': (context) => const LoginWidget(),
        '/home': (context) => HomePageWidget(overall_user_id: globals.user_id_global),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  var logged_in_user_id = -1;

  @override
  void initState(){
    if(logged_in_user_id == -1){
      print("Directed to log on page.");
    }
    else{
      print("Loading Page");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/login"); 
          },
          child: Text('Rank'),
        ),
      ),
    );
  }
}
