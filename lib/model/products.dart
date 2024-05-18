class Product {
  final String description;
  final String image;
  final String name;
  final String storeId;
  final double quantity;
  final bool tracking;
  final String id;
  final double minimum;
  final double amount;
  final String barcode;
  final String unit;

  Product({
    required this.description,
    required this.image,
    required this.name,
    required this.storeId,
    required this.quantity,
    required this.tracking,
    required this.id,
    required this.minimum,
    required this.amount,
    required this.barcode,
    required this.unit,
  });

  // Factory constructor to create a Product from a map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      name: map['name'] ?? '',
      storeId: map['storeId'] ?? '',
      quantity: map['quantity']/1.0 ?? 0.0,
      tracking: map['tracking'] ?? false,
      id: map['id'] ?? '',
      minimum: map['minimum'] /1.0?? 0.0,
      amount: map['amount']/1.0 ?? 0.0,
      barcode: map['barcode'] ?? '',
      unit: map['unit'] ?? '',

    );
  }
}
