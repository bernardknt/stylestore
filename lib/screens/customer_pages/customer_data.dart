
import 'package:cloud_firestore/cloud_firestore.dart';

class AllCustomerData {
  final String documentId;
  final String fullNames;
  final String location;
  final String photo;
  final String info;
  final String phone;


  AllCustomerData({
    required this.fullNames,
    required this.location,
    required this.photo,
    required this.info,
    required this.phone,
    required this.documentId,
  });

  factory AllCustomerData.fromFirestore(DocumentSnapshot doc) {
    return AllCustomerData(
      documentId: doc.id,
      fullNames: doc['name'] ?? '',
      location: doc['location'] ?? '',
      photo: doc['image'] ?? '',
      info: doc['info'] ?? '',
      phone: doc['phoneNumber'] ?? '',



    );
  }
}
