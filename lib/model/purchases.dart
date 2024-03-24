import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String storeId;
  List<Item> items;
  final DateTime date;


  Purchase({

    required this.storeId,
    required this.date,
    required this.items,

  });

  // Factory constructor to create a Product from a map

  factory Purchase.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Cast for clarity
    return Purchase(

      storeId: data['storeId'] ?? '', // Handle potential null
      date: (data['date'] as Timestamp).toDate(),
      items: List<Item>.from(
        data['items'].map(
              (itemData) => Item(
            description: itemData['description'],
            quality: itemData['quality'],
            quantity: itemData['quantity'].toDouble(),
            price: itemData['totalPrice'].toDouble(),
            product: itemData['product']

          ),
        ),
      ),
    );
  }
}

class Item {
  String description;
  String product;
  String quality;
  double quantity;
  double price;

  Item({required this.description, required this.quality, required this.product,required this.quantity, required this.price});
}
