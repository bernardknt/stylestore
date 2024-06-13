


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stylestore/model/Payments.dart';


class PaymentPage extends StatefulWidget {
  final String transactionId;
  static String id = "payments_page";

  PaymentPage({required this.transactionId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page ${widget.transactionId}'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('appointments').doc(widget.transactionId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Product not found'));
          }

          final product = Payments.fromFirestore(snapshot.data!);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Product ID: ${product.id}'),
                Text('Amount to Pay: \$${product.totalFee}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
