import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Cart.dart';
import 'ClothesList.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, String> userNamesListMapped = {};

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').get().then((snapshot) {
      setState(() {
        userNamesListMapped = Map.fromIterable(snapshot.docs,
            key: (doc) => doc.get('username'), value: (doc) => doc.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Se connecter'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Text("Nom d'utilisateur: "),
            TextFormField(
              controller: _usernameController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer votre nom d\'utilisateur';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            Text("Mot de passe: "),
            TextFormField(
              controller: _passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer votre mot de passe';
                }
                return null;
              },
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              child: Text('Se Connecter'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String username = _usernameController.text;
                  String password = _passwordController.text;

                  if (userNamesListMapped.containsKey(username)) {
                    String userId = userNamesListMapped[username]!;
                    String userPassword = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get()
                        .then((doc) => doc.get('password'));

                    if (password == userPassword) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClothesList(userId: userId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mot de passe incorrect'),
                        ),
                      );
                    }
                  } else {
                    await FirebaseFirestore.instance.collection('users').add({
                      'username': username,
                      'password': password,
                      'adress': '',
                      'birthday': '',
                      'postalCode': '',
                      'city': '',
                    }).then((value) {
                      String userId = value.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClothesList(userId: userId),
                        ),
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
