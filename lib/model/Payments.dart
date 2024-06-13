import 'package:cloud_firestore/cloud_firestore.dart';

class Payments {
  final String id;
  // final double amountToPay;
  final double paidAmount;
  final double totalFee;
  final String beauticianName;
  final List items;

  Payments({required this.id,
    // required this.amountToPay,
    required this.items, required this.beauticianName,required this.paidAmount,  required this.totalFee});

  factory Payments.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Payments(
      id: doc.id,
      // amountToPay: data['amountToPay'],
      items: data['items'],
      beauticianName: data['beauticianName'],
      totalFee: data['totalFee'],
      paidAmount: data['paidAmount'],
    );
  }
}
