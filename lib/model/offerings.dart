
class Offering {
  final String title;
  final double price;
  final List benefits;
  final int duration;
  final bool popular;
  bool isSelected;

  Offering({required this.title, required this.price, required this.isSelected, required this.benefits,  required this.duration, this.popular = false});
}