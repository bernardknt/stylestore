import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String id;
  final String itemName;
  final int quantity;
  final double price;
  final DateTime date;
  final List<Item> items;

  Purchase({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.date,
    required this.items,
  });

  factory Purchase.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    print('Firestore Data: $data');
    return Purchase(
      id: data['id'] ?? '',
      itemName: data['itemName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: data['price']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>).map((item) => Item.fromMap(item)).toList(),
    );
  }
}

class Item {
  final String product;
  final int quantity;
  final double price;
  final String quality;

  Item({
    required this.product,
    required this.quantity,
    required this.price,
    required this.quality,
  });

  factory Item.fromMap(Map<String, dynamic> data) {
    return Item(
      product: data['product'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: data['price']?.toDouble() ?? 0.0,
      quality: data['quality'] ?? '',
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Purchase {
//   final String storeId;
//   List<Item> items;
//   final DateTime date;
//
//
//   Purchase({
//
//     required this.storeId,
//     required this.date,
//     required this.items,
//
//   });
//
//   // Factory constructor to create a Product from a map
//
//   factory Purchase.fromSnapshot(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Cast for clarity
//     return Purchase(
//
//       storeId: data['storeId'] ?? '', // Handle potential null
//       date: (data['date'] as Timestamp).toDate(),
//       items: List<Item>.from(
//         data['items'].map(
//               (itemData) => Item(
//             // description: itemData['description']??"",
//             quality: itemData['quality'],
//             quantity: itemData['quantity'].toDouble(),
//             price: itemData['totalPrice'].toDouble(),
//             product: itemData['product']
//
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class Item {
//   // String description;
//   String product;
//   String quality;
//   double quantity;
//   double price;
//
//   Item({
//    // required this.description,
//     required this.quality, required this.product,required this.quantity, required this.price});
// }
