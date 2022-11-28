import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
   const MyHomePage({super.key, required this.userModel,required this.firebaseUser});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('asdsdvd'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'jknnk,',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),

    );
  }
}