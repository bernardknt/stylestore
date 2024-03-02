class SmsMessage {
  String message;
  List recipients;
  DateTime timestamp;
  bool delivered;
  double cost;

  SmsMessage(
      {required this.message,
        required this.recipients,
        required this.timestamp,
        required this.delivered,
        required this.cost});
}
