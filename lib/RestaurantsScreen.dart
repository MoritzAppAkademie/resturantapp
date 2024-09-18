import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RestaurantsDetailScreen.dart';

class RestaurantListPage extends StatefulWidget {
  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurants"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Restaurants')
            .orderBy("PLZ", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore error: ${snapshot.error}");
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("No data found in Firestore");
            return Text("No data found");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final restaurants = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurantData =
                  restaurants[index].data() as Map<String, dynamic>;
              final restaurantId = restaurants[index].id;

              return ListTile(
                title: Text(restaurantData['Name'] ?? 'Unknown'),
                subtitle: Text(
                    'PLZ: ${restaurantData['PLZ']}, Rating: ${restaurantData['Rating']}'),
                //DetailScreen Navigation einbauen
              );
            },
          );
        },
      ),
      //Neues Restaurant Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRestaurantDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //Form für neue Restaurants
  void _showAddRestaurantDialog() {
    final nameController = TextEditingController();
    final plzController = TextEditingController();
    final ratingController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Neues Restaurant hinzufügen"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: plzController,
                  decoration: InputDecoration(labelText: "PLZ"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ratingController,
                  decoration: InputDecoration(labelText: "Rating"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Abbrechen")),
              TextButton(
                onPressed: () {
                  _firestore.collection("Restaurants").add({
                    "Name": nameController.text,
                    "PLZ": int.parse(plzController.text),
                    "Rating": int.parse(ratingController.text),
                  });
                  Navigator.of(context).pop();
                },
                child: Text("Hinzufügen"),
              ),
            ],
          );
        });
  }
}
