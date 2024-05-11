import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/products.dart';

import '../screens/employee_pages/employee_details.dart';

class BeauticianData extends ChangeNotifier {
  List selectedOrder = [];
  String clientName = '';
  String clientId = '';
  String storeId = '';
  String location = '';
  String orderNumber = '';
  String instructions = '';
  String status = '';
  DateTime appointmentDate = DateTime.now();
  DateTime appointmentTime = DateTime.now();
  String phoneNumber = ' ';
  double bill = 0;
  double bookingFee = 0;
  String note = ' ';
  List itemDetails = [];
  int newOrdersNumber = 0;
  String item = ' ';
  double quantity = 0;
  String itemDescription = '';
  String itemPrice = '';
  double itemMinimumQuantity = 0;
  String itemId = ' ';
  String itemImage = ' ';
  String itemBarcode = ' ';
  bool itemSaleable = false;
  bool itemTracking = false;
  List<Product> productItems = [];
  AllEmployeeData? employeeInformation;

  String itemUnit = ' ';
  double price = 0;
  int appointmentsToday = 0;

  // NEW PROVIDER DETAILS CREATED
  String imagePath = '';
  String imageName = '';
  List<bool> visible = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  // Customer information
  String customerName = "";
  String employeeName = "";
  String employeePhoneNumber = "";
  Map<String, dynamic> employeePermissions = {};
  Map<String, dynamic> videoMap = {};
  String employeeCode = "";
  String employeeRole = "";
  String employeeId = "";
  String customerPhoneNumber = "";

  String customerNote = "";

  String customerPreferences = "";
  String customerImage = "";
  String customerLocation = "";
  String customerId = "";

  // Message Data
  String textMessage = "";
  String bulkNumbersForMessaging = "";
  String lottieImage = 'images/Hi5.json';
  String bannerMessage = 'Transaction Updated';


  void setBulkMessagingNumbers(String items) {
    bulkNumbersForMessaging = items;

    notifyListeners();
  }
  void setProductItems(List<Product> items) {
    productItems = items;
    notifyListeners();
  }

  void setEmployeePermission(String permissionKey, bool newValue) {
    if (employeePermissions.containsKey(permissionKey)) {
      employeePermissions[permissionKey] = newValue;
      notifyListeners(); // Notify listeners of the change
    }
  }

  void setAllEmployeePermission(Map<String, dynamic> permissions) {
    employeePermissions = permissions;
    notifyListeners(); // Notify listeners of the change
  }

  void setVideoWalkthrough(Map<String, dynamic> videoMaps) {
    videoMap = videoMaps;
    notifyListeners(); // Notify listeners of the change
  }

  void setLottieImage(image, message) {
    lottieImage = image;
    bannerMessage = message;
    notifyListeners();
  }

  void setTextMessage(String message) {
    textMessage = message;
    notifyListeners();
  }

  void setEmployeeDetails(name, phoneNumber, role, permissions, pin, id) {
    employeeName = name;
    employeePermissions = permissions;
    employeePhoneNumber = phoneNumber;
    employeeCode = pin;
    employeeRole = role;
    employeeId = id;

    notifyListeners();
  }

  void setCustomerDetails(
      name, phoneNumber, note, preferences, image, location, id) {
    customerName = name;
    customerNote = note;
    customerPhoneNumber = phoneNumber;
    customerPreferences = preferences;
    customerLocation = location;
    customerImage = image;
    customerId = id;
    notifyListeners();
  }

  void setClientName(name, id) {
    clientName = name;
    clientId = id;
    notifyListeners();
  }

  void changeCustomerDetailsVisibility(index) {
    visible[index] = !visible[index];
    notifyListeners();
    print(visible);
  }

  void setStoreId(values) {
    storeId = values;
    notifyListeners();
  }

  void setImageUploadData(String filePath, String fileName) {
    imagePath = filePath;
    imageName = fileName;
    notifyListeners();
  }

  void clearAppointments() {
    // appointmentsToday.clear();
    notifyListeners();
  }

  void setAppointmentToday(info) {
    appointmentsToday = info;
    notifyListeners();
  }

  void setSelectedOrder(listOfOrders) {
    selectedOrder = listOfOrders;
    notifyListeners();
  }

  void setEmployeeProfile(AllEmployeeData employeeData) {
    employeeInformation = employeeData;
    notifyListeners();
  }



void changeOrderDetails(
      newClientName,
      newLocation,
      newOrderNumber,
      newAppointmentDate,
      newNote,
      newItemsDetails,
      newStatus,
      newPhoneNumber,
      newBill,
      newBooking,
      newAppointmentTime) {
    clientName = newClientName;
    location = newLocation;
    orderNumber = newOrderNumber;
    appointmentDate = newAppointmentDate;
    appointmentTime = newAppointmentTime;

    note = newNote;
    itemDetails = newItemsDetails;
    phoneNumber = newPhoneNumber;
    status = newStatus;
    bill = newBill;
    bookingFee = newBooking;
    notifyListeners();
  }



  void changeItemDetails(newItemName, newQuantity, newDescription,
      newMinimumQuantity, newItemId, newPrice, newImage, tracking, saleable, barcode) {
    item = newItemName;
    quantity = newQuantity;
    itemDescription = newDescription;
    itemMinimumQuantity = newMinimumQuantity;
    itemId = newItemId;
    itemImage = newImage;
    itemSaleable = saleable;
    itemTracking = tracking;
    itemBarcode = barcode;

    // itemUnit = newItemUnit;
    price = newPrice;
    notifyListeners();
  }
}
