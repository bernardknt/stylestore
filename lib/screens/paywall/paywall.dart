import 'package:flutter/material.dart';

class Paywall extends StatefulWidget {
  @override
  _PaywallState createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  int selectedOffering = 0; // Keeps track of selected option (0, 1, or 2)

  List<Offering> offerings = [
    Offering(title: '1 Month', price: 50000, isSelected: false),
    Offering(title: '6 Months', price: 270000, isSelected: false),
    Offering(title: '1 Year', price: 480000, isSelected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return   Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        ...offerings.map((offering) => Padding(padding: EdgeInsets.all(10),
            child: _buildOfferingCard(offering))).toList(),
        // ElevatedButton(
        //   onPressed: () {
        //     // Handle subscription purchase based on selectedOffering
        //     print(
        //         'Selected Offering: ${offerings[selectedOffering].title}');
        //   },
        //   child: Text('Subscribe'),
        // ),
      ],
    );
  }

  Widget _buildOfferingCard(Offering offering) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: offering.isSelected ? Colors.blue[200] : Colors.grey[200],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              for (var i = 0; i < offerings.length; i++) {
                offerings[i].isSelected = (i == offerings.indexOf(offering));
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offering.title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: offering.isSelected ? FontWeight.bold : null,
                  ),
                ),
                Text(
                  'UGX ${offering.price.toString()}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: offering.isSelected ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Offering {
  final String title;
  final int price;
  bool isSelected;

  Offering({required this.title, required this.price, required this.isSelected});
}
