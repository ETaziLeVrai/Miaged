import 'package:appmiagedelias/src/Cart.dart';
import 'package:appmiagedelias/src/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:appmiagedelias/src/ClothesList.dart';
import 'firebase_options.dart';


void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(App());
} 

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIAGED',
            //home: LoginPage(),
            home: Login(),
      routes: {
      },
    );
  }
}
