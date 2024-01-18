

import 'purchase_customer.dart';
import 'purchase_supplier.dart';

class PurchaseOrder {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final Receipt paid;
  final StockTemplate template;
  final List<StockItem> items;

  const PurchaseOrder({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    required this.template,
    required this.paid,

  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

class StockItem {
  final String description;
  // final DateTime date;
  final double quantity;
  // final double vat;
  final double unitPrice;

  const StockItem({
    required this.description,
    // required this.date,
    required this.quantity,
    // required this.vat,
    required this.unitPrice,
  });
}