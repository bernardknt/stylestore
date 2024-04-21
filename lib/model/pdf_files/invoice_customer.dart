class Customer {
  final String name;
  final String address;
  final String phone;

  const Customer({
    required this.name,
    required this.address,
    required this.phone,
  });
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone
    };
  }
}

class InvoiceTemplate {
  final String type;
  final String salutation;
  final String totalStatement;
  final String currency;


  const InvoiceTemplate({
    required this.type,
    required this.salutation,
    required this.totalStatement,
    required this.currency

  });
}

class Receipt {
  final double amount;
  const Receipt({
    required this.amount,
  });
  Map<String, dynamic> toJson() {
    return {
      'amount': amount
    };
  }
}