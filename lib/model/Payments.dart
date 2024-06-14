import 'package:cloud_firestore/cloud_firestore.dart';

class Payments {
  final String id;
  // final double amountToPay;
  final double paidAmount;
  final double totalFee;
  final String storeName;
  final String client;
  final String clientPhone;
  final String currency;
  final String storeId;
  final List items;
  final List history;

  Payments({required this.id,
    // required this.amountToPay,
    required this.items, required this.storeName,required this.paidAmount,  required this.totalFee, required this.client, required this.currency,
    required this.clientPhone, required this.history, required this.storeId});

  factory Payments.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Payments(
      id: doc.id,

      // amountToPay: data['amountToPay'],
      items: data['items'],
      history: data['paymentHistory'],
      client: data['client'],
      clientPhone: data['clientPhone'],
      currency: data['currency'],
      storeName: data['beauticianName'],
      totalFee: data['totalFee'],
      storeId: data['beautician_id'],
      paidAmount: data['paidAmount'],
    );
  }
}
