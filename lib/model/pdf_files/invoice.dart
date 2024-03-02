

import 'invoice_customer.dart';
import 'invoice_supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final Receipt paid;
  final InvoiceTemplate template;
  final List<InvoiceItem> items;

  Map<String, dynamic> toJson() {
    return {
      'info': this.info.toJson(), // Assuming you have toJson for InvoiceInfo
      'supplier': this.supplier.toJson(),
      'customer': this.customer.toJson(),
      'items': this.items.map((item) => item.toJson()).toList(),
      'paid': this.paid.toJson(),
    };
  }

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

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'number': number,
      'date': date.toIso8601String(), // Format date for JSON
      'dueDate': dueDate.toIso8601String(),
    };
  }
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
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice
    };
  }
}