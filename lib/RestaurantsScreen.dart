import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RestaurantsDetailScreen.dart';
import 'QueryTestScreen.dart';

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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                //Füge hier deinen Filter Screen ein
                MaterialPageRoute(builder: (context) => ()),
              );
            },
          ),
        ],
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          //Übergebe der Firestore Data an die DetailView
                          RestaurantDetailScreen(restaurantId: restaurantId),
                    ),
                  );
                },
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
    final _formKey = GlobalKey<FormState>(); // Form key for validation

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Neues Restaurant hinzufügen"),
          content: Form(
            key: _formKey, // Wrap the form with a Form widget for validation
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Input
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib einen Namen ein';
                    }
                    return null;
                  },
                ),

                // PLZ Input
                TextFormField(
                  controller: plzController,
                  decoration: InputDecoration(labelText: 'PLZ'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib eine PLZ ein';
                    }
                    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                      return 'PLZ muss 5 Ziffern haben';
                    }
                    return null;
                  },
                ),

                // Rating Input
                TextFormField(
                  controller: ratingController,
                  decoration: InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib ein Rating ein';
                    }
                    final rating = int.tryParse(value);
                    if (rating == null || rating < 1 || rating > 5) {
                      return 'Rating muss zwischen 1 und 5 liegen';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                // Validate form before submitting
                if (_formKey.currentState!.validate()) {
                  // Wenn alle Validierungen erfolgreich sind, füge das Restaurant hinzu
                  _firestore.collection('Restaurants').add({
                    'Name': nameController.text,
                    'PLZ': int.parse(plzController.text),
                    'Rating': int.parse(ratingController.text),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }
}
