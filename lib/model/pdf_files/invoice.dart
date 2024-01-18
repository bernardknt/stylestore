

import 'invoice_customer.dart';
import 'invoice_supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final Receipt paid;
  final InvoiceTemplate template;
  final List<InvoiceItem> items;

  const Invoice({
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

class InvoiceItem {
  
  final String name;
  final String description;
  final double quantity;
  // final double vat;
  final double unitPrice;

  const InvoiceItem({
    this.description = "",
    required this.name,
    // required this.date,
    required this.quantity,
    // required this.vat,
    required this.unitPrice,
  });
}