import 'package:cloud_firestore/cloud_firestore.dart';

class Sales {
  final String storeId;
  final double totalFee;
  final double paidAmount;
  final String paymentMethod;
  final String client;
  List<Item> items;
  final DateTime date;


  Sales({

    required this.storeId,
    required this.totalFee,
    required this.paidAmount,
    required this.paymentMethod,
    required this.client,
    required this.date,
    required this.items,

  });

  // Factory constructor to create a Product from a map

  factory Sales.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Cast for clarity
    return Sales(

      storeId: data['sender_id'] ?? '', // Handle potential null
      totalFee: data['totalFee'] ?? 0.0, // Handle potential null
      client: data['client'] ?? '', // Handle potential null
      paymentMethod: data['paymentMethod'] ?? '', // Handle potential null
      paidAmount: data['paidAmount'].toDouble() ?? 0.0, // Handle potential null
      date: (data['order_time'] as Timestamp).toDate(),
      items: List<Item>.from(
        data['items'].map(
              (itemData) => Item(
              description: itemData['description'],
              product: itemData['product'],
              quantity: itemData['quantity'].toDouble(),
              price: itemData['totalPrice'].toDouble(),


          ),
        ),
      ),
    );
  }
}

class Item {
  String description;
  String product;
  double quantity;
  double price;

  Item({required this.description,  required this.product,required this.quantity, required this.price});
}
