
import 'package:cloud_firestore/cloud_firestore.dart';

class AllStockData {
  final String documentId;
  final double amount;
  final double quantity;
  final double restockValue;
  final double minimum;
  final String description;
  final String image;
  final String name;
  final String unit;
  final String storeId;
  final String barcode;
  final bool saleable;
  final bool ignore;
  final bool tracking;
  final List stockTaking;

  AllStockData({
    required this.documentId,
    required this.storeId,
    required this.amount,
    required this.unit,
    required this.quantity,
    required this.minimum,
    required this.description,
    required this.image,
    required this.name,
    required this.saleable,
    required this.tracking,
    required this.stockTaking,
    required this.ignore,
    required this.barcode,
    this.restockValue = 0.0,


  });

  factory AllStockData.fromFirestore(DocumentSnapshot doc) {
    return AllStockData(
      documentId: doc.id,
      amount: doc['amount']/1.0 ?? 0.0,
      quantity: doc['quantity']/1.0 ?? 0.0,
      minimum: doc['minimum']/1.0 ?? 0.0,
      description: doc['description'] ?? '',
      image: doc['image'] ?? '',
      storeId: doc['storeId'] ?? '',
      name: doc['name'] ?? '',
      saleable: doc['saleable'] ?? '',
      tracking: doc['tracking'] ?? '',
      stockTaking: doc['stockTaking'],
      barcode: doc['barcode'],
      unit: doc['unit'],
      ignore: doc['ignore'],

    );
  }
  // New method to get item by barcode
  AllStockData? getByBarcode(String barcode) {
    if (this.barcode == barcode) {
      return this;
    } else {
      return null;
    }
  }
}
