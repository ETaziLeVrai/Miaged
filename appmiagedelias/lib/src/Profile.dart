import 'package:appmiagedelias/src/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Cart.dart';
import 'ClothesList.dart';

class Profile extends StatefulWidget {
  final String userId;
  Profile({required this.userId}); 
  @override
  _ProfileState createState() => _ProfileState(userId: this.userId);
}

class _ProfileState extends State<Profile> {
  final String userId;
  _ProfileState({required this.userId});

  int _selectedIndex = 2;
  String email = '';
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _password;
  String? _birthday;
  String? _adress;
  String? _code;
  String? _city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
          backgroundColor: Colors.green,
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(this.userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        Map<String, dynamic> user =
                            snapshot.data!.data() as Map<String, dynamic>;
                        if (!snapshot.hasData) {
                          return Center(child: Text("Veuillez patienter..."));
                        }
                        return Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      TextFormField(
                                        readOnly: true,
                                        initialValue: user['username'],
                                        decoration: InputDecoration(
                                          labelText: 'Nom d\'utilisateur',
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        readOnly: true,
                                        obscureText: true,
                                        initialValue: '***',
                                        decoration: InputDecoration(
                                          labelText: 'Mot de passe',
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        initialValue: user['birthday'],
                                        decoration: InputDecoration(
                                          labelText: 'Date de naissance',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Veuillez entrer votre date de naissance';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _birthday = value;
                                        },
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        initialValue: user['adress'],
                                        decoration: InputDecoration(
                                          labelText: 'Adresse',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Veuillez entrer votre adresse';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _adress = value;
                                        },
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        initialValue: user['postalCode'],
                                        decoration: InputDecoration(
                                          labelText: 'Code Postal',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Veuillez entrer votre code postal';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _code = value;
                                        },
                                      ),
                                      SizedBox(height: 20.0),
                                      TextFormField(
                                        initialValue: user['city'],
                                        decoration: InputDecoration(
                                          labelText: 'Ville',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Veuillez entrer votre ville';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _city = value;
                                        },
                                      ),
                                      SizedBox(height: 20.0),
                                      ElevatedButton(
                                          child: Text('Valider'),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _formKey.currentState!.save();

                                              // update user profile with new information
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc('GBTRW72QWOFj4Y92kBgN')
                                                  .update({
                                                'birthday': _birthday,
                                                'adress': _adress,
                                                'postalCode': _code,
                                                'city': _city,
                                              }).then((value) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Profil mis à jour')));
                                              }).catchError((error) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(error)));
                                              });
                                            }
                                          }),
                                          SizedBox(height: 20.0),
                                      ElevatedButton(
                                          child: Text('Se deconnecter'),
                                            style: ElevatedButton.styleFrom(primary: Colors.red,),
                                          onPressed: () async {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Login()));
                                          })
                                    ])));
                      })));
        }),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.green,
            selectedItemColor: Colors.white,
            currentIndex: _selectedIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag), label: 'Acheter'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart), label: 'Panier'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
            ],
            onTap: (int index) {
              _selectedIndex = index;
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Cart(userId: this.userId)),
                );
              }
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClothesList(userId: this.userId)),
                );
              }
            }));
  }
}
