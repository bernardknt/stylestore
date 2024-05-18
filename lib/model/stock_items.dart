class Stock {
  String name;
  String id;
  double _restock;
  double price;
  String description;
  String quality;
  String unit;

  Stock({
    required this.name,
    this.price = 0.0,
    this.description = "",
    this.quality = "",
    this.unit = 'pcs',
    required this.id,
    required double restock,
  }) : _restock = restock;

  double get restock => _restock;

  setRestock(double newValue) {
    _restock = newValue;
  }
}