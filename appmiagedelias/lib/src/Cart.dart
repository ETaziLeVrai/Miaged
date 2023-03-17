import 'package:appmiagedelias/src/ClothesList.dart';
import 'package:appmiagedelias/src/Profile.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Cart extends StatefulWidget {
  final String userId;
  Cart({required this.userId});
  @override
  _CartState createState() => _CartState(userId: this.userId);
}

class _CartState extends State<Cart> {
  final String userId;
  String cartId =
      "";
  _CartState({required this.userId});

  @override
  void initState() {
    super.initState();
    getCartId();
  }

  void getCartId() async {
    QuerySnapshot cartQuerySnapshot =
        await FirebaseFirestore.instance.collection("cart").get();
    bool cartExists =
        false;
    for (QueryDocumentSnapshot cart in cartQuerySnapshot.docs) {
      if (cart.get("userId") == this.userId) {
        
        setState(() {
          cartId = cart.id;
        });
        cartExists = true;
        break;
      }
    }
    if (!cartExists) {
      
      DocumentReference newCart =
          await FirebaseFirestore.instance.collection("cart").add({
        "userId": this.userId,
        "itemsIdList": [],
      });
      setState(() {
        cartId = newCart
            .id;
      });
    }
  }

  Stream<DocumentSnapshot> cartStream() {
    return FirebaseFirestore.instance
        .collection('cart')
        .doc(cartId)
        .snapshots();
  }

  int _selectedIndex = 1;
  List<String> itemNames = [];
  num total = 0;
  List<String> itemIdList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Panier'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: cartStream(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text("Veuillez patienter..."));
            }

            
            Map<String, dynamic> cartData =
                snapshot.data!.data() as Map<String, dynamic>;
            itemIdList = List<String>.from(cartData['itemsIdList']);

            
            List<Future<DocumentSnapshot<Map<String, dynamic>>>> clothesList =
                [];
            for (int i = 0; i < itemIdList.length; i++) {
              Future<DocumentSnapshot<Map<String, dynamic>>> clothe =
                  FirebaseFirestore.instance
                      .collection('clothes')
                      .doc(itemIdList[i])
                      .get();
              clothesList.add(clothe);
            }

            return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
              future: Future.wait(clothesList),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                itemNames = [];
                total = 0;
                for (int i = 0; i < snapshot.data!.length; i++) {
                  Map<String, dynamic> itemData = snapshot.data![i].data()!;
                  itemNames.add(itemData['name']);
                  total += itemData['price'];
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemIdList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('clothes')
                                .doc(itemIdList[index])
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot<Object?>>
                                    snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }

                              
                              Map<String, dynamic> itemData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              String itemName = itemNames[index];
                              int itemPrice = itemData['price'];
                              String itemsize = itemData['size'];
                              String itemImageUrl = itemData['image'];

                              return ListTile(
                                leading: Image.network(itemImageUrl),
                                title: Text(itemName),
                                subtitle: Text(
                                    'Prix: \$${itemPrice} \nTaille: ${itemsize}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc('WXVxKIBPJa8w7c32Hseg')
                                        .update({
                                      'itemsIdList': FieldValue.arrayRemove(
                                          [itemIdList[index]])
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total:'),
                              Text('\$${total.toStringAsFixed(2)}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClothesList(userId: this.userId)),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(userId: this.userId)),
              );
            }
          },
        ));
  }
}
