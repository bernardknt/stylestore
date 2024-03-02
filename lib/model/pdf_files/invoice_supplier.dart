class Supplier {
  final String name;
  final String address;
  final String paymentInfo;
  final String phoneNumber;

  const Supplier({
    required this.name,
    required this.address,
    required this.paymentInfo,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'paymentInfo': paymentInfo,
      'phoneNumber': phoneNumber
    };
  }
}
