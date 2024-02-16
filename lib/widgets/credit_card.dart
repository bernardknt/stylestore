import 'package:flutter/material.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';

class DebitCard extends StatelessWidget {
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String bankName;
  final Color? primaryColor; // Optional for more control over gradient

  const DebitCard({
    Key? key,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.bankName,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use primaryColor if provided, otherwise calculate a gradient based on bankName
    final gradient = primaryColor ?? _getGradientForBank(bankName);

    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: gradient as Gradient?,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildChip(chipText: 'Chip'), // Replace with actual chip design
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("                               ",),
                Text(
                  cardNumber.substring(0, 4) +
                      ' **** **** '
                      //+
                      //cardNumber.substring(12),
                  ,style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("                               ",),
              ],
            ),
            Text(
              "Wallet Balance UGX ${expiryDate.toUpperCase()}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLogo(bankName),
                Text(
                  cardHolderName.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper methods for chip and logo (replace with actual implementations)
Widget _buildChip({required String chipText}) {
  return Container(
    width: 40.0,
    height: 20.0,
    // decoration: BoxDecoration(
    //   color: Colors.white,
    //   borderRadius: BorderRadius.circular(8.0),
    // ),
    child: Center(
      child: Image.asset("images/cardchip.png"),
    ),
  );
}

Widget _buildLogo(String bankName) {
  // Replace with actual logo asset or network image
  return Image.asset(
    // 'assets/images/bank_logo_$bankName.png',
     'images/new_logo.png',
    width: 40.0,
    height: 20.0,
  );
}

// Generate gradients based on bank names (can be customized or replaced)
LinearGradient _getGradientForBank(String bankName) {
  switch (bankName) {
    case 'Standard Chartered':
      return LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF00C8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'Centenary Bank':
      return LinearGradient(
        colors: [kBlueDarkColor, kAppPinkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'Equity Bank':
      return LinearGradient(
        colors: [Color(0xFFE81C4F), Color(0xFFF77737)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    default:
      return LinearGradient(
        colors: [Color(0xFF007ACC), Color(0xFF00C8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}
