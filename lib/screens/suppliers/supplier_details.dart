
import 'package:cloud_firestore/cloud_firestore.dart';

class AllSupplierData {
  final String documentId;
  final String fullNames;
  final String supplies;
  final String nationality;
  final String phone;
  final String address;
  final String email;


  AllSupplierData({
    required this.fullNames,
    required this.supplies,
    required this.nationality,
    required this.phone,
    required this.address,
    required this.email,
    required this.documentId,
  });

  factory AllSupplierData.fromFirestore(DocumentSnapshot doc) {
    return AllSupplierData(
      documentId: doc.id,
      fullNames: doc['name'] ?? '',
      supplies: doc['supplies'] ?? '',
      nationality: doc['nationality'] ?? '',
      phone: doc['phoneNumber'] ?? '',
      address: doc['address'] ?? '',
      email: doc['email'] ??'',

    );
  }
}
