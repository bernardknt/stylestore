
class BasketItem {
  BasketItem({required this.amount, required this.quantity, required this.name, required this.details, required this.tracking});
  String name;
  double amount;
  double quantity;
  bool tracking;
  String details;
}