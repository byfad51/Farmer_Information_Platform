import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wordadder/pages/AddQuestion.dart';
import 'package:wordadder/pages/Dashboard.dart';
import 'package:wordadder/pages/Login.dart';
import 'package:wordadder/pages/Profile.dart';
import 'package:wordadder/pages/Questions.dart';
import 'package:wordadder/pages/Register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
        primarySwatch: Colors.brown
        ),
      title: 'Farmer Information Platform',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/profile': (context) => ProfilePage(),
        '/list_question': (context) => QuestionListPage(),
        '/add_question': (context) => AskQuestionPage(),
      },
    );
  }
}

