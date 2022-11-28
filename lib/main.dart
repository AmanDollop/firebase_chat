import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/modals/firebase_helper.dart';
import 'package:firebase_chat/modals/userModel.dart';
import 'package:firebase_chat/pages/home_page.dart';
import 'package:firebase_chat/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid=const Uuid();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? thisUserModel =
        await FireBaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
        MyAppLogin(userModel: thisUserModel, firebaseUser: currentUser),
      );
    } else {
      runApp(
        const MyApp(),
      );
    }
  } else {
    runApp(
      const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class MyAppLogin extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLogin(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
