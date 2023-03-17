import 'package:appmiagedelias/src/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Cart.dart';


class ClothesList extends StatefulWidget {
  final String userId;
  ClothesList({required this.userId});
  @override
  _ClothesListState createState() => _ClothesListState(userId: this.userId);
}

class _ClothesListState extends State<ClothesList> {
  final String userId; // nouvel attribut userId
_ClothesListState({required this.userId}); 
String cartId = ""; // Variable qui stockera l'id du cart correspondant à l'utilisateur

void initState() {
    super.initState();
    getCartId(); // Appel de la méthode getCartId() pour récupérer l'id du cart correspondant à l'utilisateur
  }

void getCartId() async {
    QuerySnapshot cartQuerySnapshot =
        await FirebaseFirestore.instance.collection("cart").get();
    bool cartExists =
        false; // Variable pour savoir si un cart correspondant à l'utilisateur existe déjà
    for (QueryDocumentSnapshot cart in cartQuerySnapshot.docs) {
      if (cart.get("userId") == this.userId) {
        // Si un cart correspondant à l'utilisateur existe déjà
        setState(() {
          cartId = cart.id; // On stocke son id dans la variable cartId
        });
        cartExists = true;
        break; // On sort de la boucle for
      }
    }
    if (!cartExists) {
      // Si aucun cart correspondant à l'utilisateur n'a été trouvé
      DocumentReference newCart =
          await FirebaseFirestore.instance.collection("cart").add({
        "userId": this.userId,
        "itemsIdList": [],
      });
      setState(() {
        cartId = newCart
            .id; // On stocke l'id du nouveau cart créé dans la variable cartId
      });
    }
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Vêtements'),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('clothes').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text("Veuillez patienter..."));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot clothe = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    goToDetails(context, clothe, cartId);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(clothe['image']),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clothe['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                clothe['size'],
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                '\$${clothe['price']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag), label: 'Acheter'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Panier'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          onTap: (int index) {
            _selectedIndex = index;
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Cart(userId: this.userId)),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(userId: this.userId)),
              );
            }

          },
        ));
  }
}

void goToDetails(BuildContext context, DocumentSnapshot clothe, String idCart) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(clothe['name']),
        content: Container(
          width: double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                child: Image.network(
                  clothe['image'],
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Text('Prix: \$${clothe['price']}'),
              Text('Taille: ${clothe['size']}'),
              Text('Marque: ${clothe['brand']}'),
              Text('Type: ${clothe['type']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Ajouter au Panier'),
            onPressed: () async {
              QuerySnapshot clothesQuerySnapshot =
                  await FirebaseFirestore.instance.collection('cart').get();

              List<String> clotheMapped = clothesQuerySnapshot.docs
                  .map((DocumentSnapshot documentSnapshot) => clothe.id)
                  .toList();

              await FirebaseFirestore.instance
                  .collection('cart')
                  .doc(idCart)
                  .update({'itemsIdList': FieldValue.arrayUnion(clotheMapped)});

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
