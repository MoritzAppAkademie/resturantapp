//DetailScreen bauen mit Änderungs/Löschen Funktion
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  RestaurantDetailScreen({required this.restaurantId});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final plzController = TextEditingController();
  final ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  // Lädt die Daten des Restaurants
  void _loadRestaurantData() async {
    DocumentSnapshot restaurantSnapshot = await _firestore
        .collection('Restaurants')
        .doc(widget.restaurantId)
        .get();

    final restaurantData = restaurantSnapshot.data() as Map<String, dynamic>;

    nameController.text = restaurantData['Name'];
    plzController.text = restaurantData['PLZ'].toString();
    ratingController.text = restaurantData['Rating'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Löscht das Restaurant
              _firestore
                  .collection('Restaurants')
                  .doc(widget.restaurantId)
                  .delete();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: plzController,
              decoration: InputDecoration(labelText: 'PLZ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: ratingController,
              decoration: InputDecoration(labelText: 'Rating'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Speichert die Änderungen des Restaurants
                _firestore
                    .collection('Restaurants')
                    .doc(widget.restaurantId)
                    .update({
                  'Name': nameController.text,
                  'PLZ': int.parse(plzController.text),
                  'Rating': int.parse(ratingController.text),
                });
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
