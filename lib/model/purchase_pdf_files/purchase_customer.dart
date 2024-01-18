class Customer {
  final String name;
  final String address;
  final String phone;

  const Customer({
    required this.name,
    required this.address,
    required this.phone,
  });
}

class StockTemplate {
  final String type;
  final String salutation;
  final String totalStatement;


  const StockTemplate({
    required this.type,
    required this.salutation,
    required this.totalStatement,

  });
}

class Receipt {
  final double amount;



  const Receipt({
    required this.amount,


  });
}