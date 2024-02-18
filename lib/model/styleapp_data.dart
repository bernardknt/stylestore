
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stylestore/model/pdf_files/invoice.dart';
import 'package:stylestore/model/stock_items.dart';
import '../Utilities/constants/color_constants.dart';
import '../utilities/basket_items.dart';
import '../utilities/customer_items.dart';

class StyleProvider extends ChangeNotifier{
  // User defauults
  Map<String, String> countryNumbers = {
    "+213": "DZD", "+244": "AOA", "+229": "XOF", "+267": "BWP", "+226": "XOF", "+257": "BIF", "+238": "CVE", "+237": "XAF", "+236": "XAF", "+235": "XAF", "+269": "KMF",
    "+242": "XAF","+243": "CDF","+253": "DJF", "+20": "EGP", "+240": "XAF", "+291": "ERN", "+268": "SZL", "+251": "ETB", "+241": "XAF", "+220": "GMD", "+233": "GHS", "+224": "GNF", "+245": "XOF", "+225": "XOF", "+254": "KES", "+266": "LSL", "+231": "LRD", "+218": "LYD","+261": "MGA", "+265": "MWK", "+223": "XOF", "+222": "MRU", "+230": "MUR", "+212": "MAD", "+258": "MZN", "+264": "NAD", "+227": "XOF", "+234": "NGN", "+250": "RWF", "+239": "STN", "+221": "XOF", "+248": "SCR", "+232": "SLL", "+252": "SOS",
    "+27": "ZAR", "+211": "SSP", "+249": "SDG", "+255": "TZS", "+228": "XOF", "+216": "TND", "+256": "UGX", "+260": "ZMW", "+263": "ZWL","+1":"USD"

  }
  ;

  List  bulkNumbers = [];

  String userName = '';
  String userEmail = '';
  String userToken = '';
  bool doesMobile = false;
  bool isActive = true;
  String paymentStatus = 'Submitted';
  String customerName = '';
  String customerId = '';
  String customerNumber  = '';
  String customerLocation  = '';
  bool isStoreEmpty = false;
  bool kdsMode = false;


  String speciality = '';
  List specialistCategories = [];
  List specialistId = [];
  List specialistImages = [];
  String specialityId = '';

  String featuredSpeciality = '';
  List featuredNames = [];
  List featuredId = [];
  List featuredImages = [];
  // String specialityId = '';

  // Beautician information
  String beauticianLocation = '';
  String beauticianId = 'cat7b7171f0';
  String beauticianName = '';
  String beauticianImageUrl = '';
  int beauticianTransport = 0;
  List beauticianClients = [];
  List beauticianServices = [];
  List beauticianOperationModes = [];
  int beauticianServiceTime = 0;
  double beauticianRating= 0;
  int reviewsNumber = 0;
  int beauticianReviewNumber = 0;
  List servicesNames = [];
  List servicesOptionState = [];
  List servicesOptions = [];
  List servicesBasePrice = [];
  List servicesOptionsCheckbox = [[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false]];
  List servicesOptionsCheckboxBase = [[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false]];
  List boxColourMainList = [Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white];
  List stateOfBoxBefore =[];
  List <List<BasketItem>> basketItemsBefore = [];
  List postLikes = [];
  List postFavourites = [];
  List calendarBlackouts = [];
  List <DateTime>convertedCalendarBlackouts = [];
  double sliderForDistance = 3;
  double deliveryFee = 0.0;

  double totalPrice = 0.0;
  double paidPrice = 0.0;
  String paymentMethod = "Cash";
  double bookingPrice = 0.0;
  double bookingPercentage = 0.15;
  bool showLocationInstructions = false;
  String instructionsInfo = '';
  String transactionNote = '';

  Color bookButtonColor = kFontGreyColor;
  int openingTime = 8;
  int closingTime = 18;

  // Invoiced values
  double invoicedTotalPrice = 0;
  double invoicedPaidPrice = 0;
  double invoicedPriceToPay = 0;
  double invoicedBalance = 0;
  String invoicedCustomer = "";
  String invoiceTransactionId= "";
  String invoiceSms= "";
  String invoicedCustomerNumber = "700123456";
  DateTime invoicedDate = DateTime.now();
  List<DateTime> selectedTaskDates = [];



  // Basket Variables
  List<BasketItem> basketItems = [];
  List basketNameItems = [];
  List <double>basketItemsPrices = [];
  int basketNumber = 0;

  // input Upload info
  List <BasketItem> basketServiceOptionsToUpload = [];
  List <CustomerItem> basketCustomerOptionsToUpload = [];

  // Preference Colors
  List<Color> preferencesColorOfBoxes = [kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor,kButtonGreyColor];
  Color preferencesContinueColor = kButtonGreyColor;
  List preferencesSelected = [];
  DateTime appointmentDate = DateTime.now();
  //DateTime invoicedDate = DateTime.now();
  DateTime appointmentTime = DateTime.now();

  // appointment made provider details
  DateTime appointmentMadeDate = DateTime.now();
  DateTime appointmentMadeTime = DateTime.now();
  String appointmentMadeLocation = '';
  String appointmentMadeBeautician = '';
  String beauticianPhoneNumber = '';
  double appointmentMadeBeauticianLongitude = 0.0;
  double appointmentMadeBeauticianLatitude = 0.0;
  List appointmentMadeBeauticianItems = [];
  String appointmentMadeBeauticianStore = '';
  String taskToDo = '';
  String appointmentMadeAppointmentId = '';
  String appointmentMadeBeauticianId = '';
  double appointmentMadeTotalFee = 0.0;
  double appointmentMadeBookingFee = 0.0;
  int notificationId = 0;
  List <Stock> selectedStockItems = [];
  String pendingPaymentStatement = 'Payment in Process';
  String stockId = '';

  Color liveIndicatorColor = kGreenThemeColor;
  String liveIndicatorString = 'Online';

  DateTime paymentDate = DateTime.now();

  List <InvoiceItem> invoiceItems = [];
  Iterable<Contact>? contacts;
  Map youtubeVideos = {};

  String expense = "";

  void addBulkSmsList(value) {
    if (bulkNumbers.contains(value)) {
      bulkNumbers.remove(value);
    } else {
      bulkNumbers.add(value);
    }
    notifyListeners();
  }

  void enterKDSmode (value){
    kdsMode = value;
    notifyListeners();
  }

  void setIsStoreEmpty (bool value){
    isStoreEmpty = value;
    notifyListeners();
  }

  void setSelectedTaskDates (List<DateTime> dates){
    selectedTaskDates = dates;
    notifyListeners();
  }

  void setTaskToDo(task){
    taskToDo = task;
    notifyListeners();
  }

  void setExpense (newExpense){
    expense = newExpense;
    notifyListeners();
  }
  // create a function for the transaction Note
  void setTransactionNote (note){
    transactionNote = note;
    notifyListeners();
    print(transactionNote);
  }

  void addInvoicedItems (InvoiceItem item){
    invoiceItems.add(item);
    invoicedTotalPrice = 0;
    for(var i = 0; i<invoiceItems.length; ++i){
      invoicedTotalPrice += (invoiceItems[i].unitPrice * invoiceItems[i].quantity) ;
    }

    notifyListeners();
  }

  void resetSelectedStockBasket (){
    selectedStockItems.clear();
    notifyListeners();
  }
  void setStockAnalysisValues (itemId) {
    stockId = itemId;
    notifyListeners();
  }
  void setSubscriptionVariables (videos){
    youtubeVideos = videos;
    notifyListeners();
  }

  void setPendingPaymentStatement(){
    pendingPaymentStatement = 'Transaction Complete';
    notifyListeners();
  }

  void removeSelectedStockItems( Stock item){
  selectedStockItems.removeWhere((stock) => stock.id == item.id);
  notifyListeners();
  print(selectedStockItems);
  }

  void removeSelectedInvoicedItem( InvoiceItem item){
    invoiceItems.removeWhere((stock) => stock.name == item.name);
    invoicedTotalPrice = 0;
    for(var i = 0; i<invoiceItems.length; ++i){
      invoicedTotalPrice += (invoiceItems[i].unitPrice * invoiceItems[i].quantity) ;
    }
    notifyListeners();

  }

  void addSelectedStockItems( Stock item){
    selectedStockItems.add(item);
    notifyListeners();
    print(selectedStockItems);
  }

  void setSelectedStockItems( List<Stock> items){
    selectedStockItems.addAll(items);
    notifyListeners();
    print("THIS IS AT OPENING THE SUMMARY: ${selectedStockItems}");
  }
  void clearSelectedStockItems(){
    selectedStockItems.clear();
    notifyListeners();
    print("THIS IS AT OPENING THE SUMMARY: ${selectedStockItems}");
  }

  void setSyncedCustomers( gotContacts){
    contacts = gotContacts;
    notifyListeners();
  }

  void setPaymentMethod(method){
    paymentMethod = method;
    notifyListeners();
  }
 void setInvoicedPhoneNumber(phoneNumber){
   invoicedCustomerNumber = phoneNumber;
   notifyListeners();
 }
  void setPaymentDate(DateTime time){
    paymentDate = time;
    notifyListeners();
  }
  void setNotificationId (int id){
    notificationId = id;
    notifyListeners();
  }

  void clearInvoiceItems(){
    invoiceItems.clear();
    notifyListeners();
  }

  void setInvoiceItems(InvoiceItem value){
    invoiceItems.add(value);
  notifyListeners();
}
  void setInvoicedPriceToPay(price){
    invoicedPriceToPay = price/1.0;
    notifyListeners();
  }
  void setInvoicedValues (totalPrice, paidPrice, customerName, id, sms, customerNumber, date, paymentDifference, invoicedCustomerId){
    invoicedTotalPrice = totalPrice;
    invoicedPaidPrice = paidPrice;
    invoicedCustomer = customerName;
    invoiceTransactionId= id;
    invoiceSms= sms;
    invoicedCustomerNumber = customerNumber;
    invoicedDate = date;
    invoicedBalance = paymentDifference;
    customerId = invoicedCustomerId;
    notifyListeners();
  }
  void setSms (sms){
    invoiceSms = sms;
    notifyListeners();
  }

  void setPaidPrice (double price){
    paidPrice = price;
    notifyListeners();
  }

  void resetCustomerDetails (){
    customerName = "";
    notifyListeners();
  }
  void setLiveIndicatorValues (color, string){
    liveIndicatorColor = color;
    liveIndicatorString = string;

    notifyListeners();
  }
  void setInstructionsInfo(String instruction){
    instructionsInfo = instruction;
    notifyListeners();
  }

  void setPaymentStatus(String status ) {

    paymentStatus = status;
    if (status == 'Paid'){
      appointmentDate = DateTime.now();
      appointmentTime = DateTime.now();
    }
    notifyListeners();

  }

  void setCustomerNameOnly(String name) {

    customerName = name;
    notifyListeners();

  }

  void setCustomerName(String name,String number, id, location) {
    customerNumber = number;
    customerLocation = location;
    customerName = name;
    customerId = id;
    notifyListeners();

  }

  setStoreValues(newId, newImage){
    beauticianId = newId;
    beauticianImageUrl = newImage;
    notifyListeners();
  }



  void setAppointmentMade(date, time, location, beautician, phone, latitude, longitude, items, id, beauticianId, amountTotal, bookingFee){
    appointmentMadeDate = date;
    appointmentMadeTime = time;
    appointmentMadeBeautician = beautician;
    appointmentMadeAppointmentId = id;
    appointmentMadeBeauticianId = beauticianId;
    appointmentMadeLocation = location;
    beauticianPhoneNumber = phone;
    appointmentMadeBeauticianLatitude = latitude;
    appointmentMadeBeauticianLongitude = longitude;
    appointmentMadeBeauticianItems = items;
    appointmentMadeTotalFee = amountTotal;
    appointmentMadeBookingFee = bookingFee;

    notifyListeners();
  }

  void setSliderForDistance (radius){
    sliderForDistance = radius;
    notifyListeners();
  }

  // Dates
  void convertCalendarValues(calendarList){
    for (var date in calendarList){
      convertedCalendarBlackouts.add(date.toDate());
    }
    notifyListeners();
  }

  void setLocationInstructionsToFalse(){
    showLocationInstructions = true;
    notifyListeners();
  }



  // User defaults
  setUserDefaults (name, email, token){


    notifyListeners();
  }


  // Selected beautician services
  setAppointmentTimeDate(date, time){
    appointmentDate = date;
    appointmentTime = time;

    notifyListeners();
  }

  setInvoicedTimeDate(date){
    invoicedDate = date;
    notifyListeners();
  }

  setInvoicedCustomer(name, phone, id){
    invoicedCustomer = name;
    invoicedCustomerNumber = phone;
    customerId = id;

    notifyListeners();
  }



  setBookingPrice(double amount){
    bookingPrice = amount;

    notifyListeners();
  }

  void setServicesOptionsCheckbox (boxIndex, value, index, BasketItem item){

    var checkboxChecker  = servicesOptionsCheckboxBase[boxIndex][index]; // This checks the value of the default array of box values!
    var instanceOfCheckboxBase = [[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false]];
    stateOfBoxBefore = servicesOptionsCheckbox[boxIndex];

    print(stateOfBoxBefore);

    if (checkboxChecker == value){

      servicesOptionsCheckbox[boxIndex][index] = false;
      deleteItemFromBasket(item, 1, 0);


    }else {
      // print('checkboxBase1:$servicesOptionsCheckboxBase');
      servicesOptionsCheckbox[boxIndex] = instanceOfCheckboxBase[boxIndex];
      servicesOptionsCheckbox[boxIndex][index] = true;
      addToServiceBasket(item);

    }

    notifyListeners();
  }

  setBookButtonColor (){
    if (basketItems.isEmpty){
      bookButtonColor = kFontGreyColor;
    }else {
      bookButtonColor = kAppPinkColor;
    }
    notifyListeners();
  }

  void setBoxColorMainServices(Color selectedColor, int index, int valueIndex){
    // Here we compare the color of the box at number selected with the value of the checkbox whether selected at the selected box


    if (boxColourMainList[index] == selectedColor && servicesOptionsCheckboxBase[index][valueIndex] != servicesOptionsCheckbox[index][valueIndex]){

      boxColourMainList[index] = Colors.lightGreen;

    }else if (servicesOptionsCheckboxBase[index][valueIndex] == servicesOptionsCheckbox[index][valueIndex]){
      boxColourMainList[index] = Colors.white;
    } else {
      print(stateOfBoxBefore);
      Map optionsDataStored =  servicesOptions[index];
      var nameOfElement = optionsDataStored.keys.toList()[stateOfBoxBefore.indexOf(true)];
      // print(optionsDataStored['Groom Haircut']);
      // print(optionsDataStored);
      print(nameOfElement);
      //print(basketItems.length);
      print(basketNameItems.indexOf(nameOfElement));
      print(basketNameItems);

      totalPrice -= basketItemsPrices[basketNameItems.indexOf(nameOfElement)];
      basketNameItems.remove(nameOfElement);
      // basketNameItems.indexOf(nameOfElement);
      basketItems.removeAt(0);


      //basketItems.remove();
      print('namesLength: ${basketNameItems.length}');
      print('basketLet: ${basketItems.length}');


    }
    notifyListeners();
  }

  void setServicesOptions(serviceName, serviceOption, serviceState, servicePrice){
    servicesNames = serviceName;
    servicesOptions = serviceOption;
    servicesOptionState = serviceState;
    servicesBasePrice = servicePrice;
    notifyListeners();
  }

  // void setSelectedBeauticianInfo(location, modesOfOperation, name, imageUrl, rating, id, clients, services, reviewNumber, calendar){
  //   beauticianLocation = location;
  //   beauticianOperationModes = modesOfOperation;
  //   beauticianName = name;
  //   beauticianImageUrl = imageUrl;
  //   beauticianRating = rating;
  //   beauticianId = id;
  //   beauticianClients = clients;
  //   beauticianServices = services;
  //   beauticianReviewNumber = reviewNumber;
  //   calendarBlackouts = calendar;
  //   convertCalendarValues(calendarBlackouts);
  //
  //   notifyListeners();
  // }
  // void setBeauticianInfo(name, id){
  //   beauticianName = name;
  //   beauticianId = id;
  //   notifyListeners();
  // }
  void setRatingsNumber (newRatingNumber){
    reviewsNumber = newRatingNumber;
    notifyListeners();
  }
  void resetRatingsNumber(){
    reviewsNumber = 0;
    notifyListeners();
  }

  void setSpeciality(newSpeciality, newSpecialityId){
    speciality = newSpeciality;
    specialityId = newSpecialityId;
    notifyListeners();
  }


  void beauticianCarouselClear(){
    beauticianClients.clear();
    convertedCalendarBlackouts.clear();
    calendarBlackouts.clear();
    print(beauticianClients);
    notifyListeners();
  }
  void clearLists(){
    bookButtonColor = kFontGreyColor;
    servicesOptionsCheckbox = [[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false]];
    servicesOptionsCheckboxBase = [[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false],[false, false, false,false, false, false, false, false,false, false]];
    boxColourMainList = [Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white];
    totalPrice = 0;
    basketItemsPrices.clear();
    basketNameItems.clear();
    basketItems.clear();
    notifyListeners();
  }

  void setAllStoreDefaults(active, blackoutDates, beauticianImages, close, open, mobile, location, modes, phoneNumber, name, image, transport){
    isActive = active;
    calendarBlackouts = blackoutDates;
    beauticianClients = beauticianImages;
    closingTime = close;
    openingTime = open;
    doesMobile = mobile;
    beauticianLocation = location;
    beauticianOperationModes = modes;
    beauticianPhoneNumber = phoneNumber;
    beauticianName = name;
    beauticianImageUrl = image;
    beauticianTransport = transport;
    print("KOKOKOKOKO This code run");
    notifyListeners();
  }

  void setSpecialityList(category, id, images){
    specialistCategories = category;
    specialistId = id;
    specialistImages = images;
    notifyListeners();
  }

  void clearSpecialityList(){
    specialistCategories.clear();
    specialistId.clear();
    specialistImages.clear();
    notifyListeners();
  }

  void deleteItemFromBasket(BasketItem item, double quantity, int position){
    print('Basket item length before:${basketItems.length}');
    basketNameItems.remove(item.details);
    basketItemsPrices.remove(item.amount * quantity);


    basketItems.removeAt(position);
    basketNumber = basketItems.length;
    totalPrice -= (item.amount * quantity);
    setBookingPrice(totalPrice);
    setBookButtonColor();
    notifyListeners();
    print('New Basket item length after:${basketItems.length}');
  }

  void addToServiceUploadItem(BasketItem item){
    // print('Adding Basket item length before:${basketItems.length}');
    basketServiceOptionsToUpload.add(item);
    notifyListeners();
    print('KRKRKRKRK:${basketServiceOptionsToUpload.length}');
  }

  void resetServiceUploadItem(){
    // print('Adding Basket item length before:${basketItems.length}');
    basketServiceOptionsToUpload.clear();
    notifyListeners();
    // print('Adding New Basket item length after:${basketItems.length}');
  }

  void addToCustomerUploadItem(CustomerItem item){
    // print('Adding Basket item length before:${basketItems.length}');
    basketCustomerOptionsToUpload.add(item);
    notifyListeners();
    print('KRKRKRKRK:${ basketCustomerOptionsToUpload.length}');
  }

  void resetCustomerUploadItem(){
    // print('Adding Basket item length before:${basketItems.length}');
    basketCustomerOptionsToUpload.clear();
    notifyListeners();
    // print('Adding New Basket item length after:${basketItems.length}');
  }


  void addToServiceBasket(BasketItem item){
    print('Adding Basket item length before:${basketItems.length} for $item');
    if(basketItems.contains(item)){
      print("ZUNGULULU THIS LINE RUN");
      // basketItems.where((element) => false);
      basketItems[basketItems.indexOf(item)].quantity += 1;
      basketNumber = basketItems.length;
      totalPrice += (item.amount * item.quantity);
      basketNameItems.add(item.name);
      basketItemsPrices.add(item.amount);

    } else {
      print("ZUNGULULU ELSEEE RUN");
      basketItems.add(item);
      basketNumber = basketItems.length;
      totalPrice += (item.amount * item.quantity);
      basketNameItems.add(item.name);
      basketItemsPrices.add(item.amount);

    }


    setBookButtonColor();
    notifyListeners();
    print('Adding New Basket item length after:${basketItems.length}');
  }
// THE PREFERENCES PROVIDER IS HERE
  void setPreferencesBoxColor(index, color, name){

    if (color!= kBrightGreenThemeColor){
      preferencesSelected.add(name);
      preferencesColorOfBoxes[index] = kBrightGreenThemeColor;
    }else {
      preferencesColorOfBoxes[index] = kButtonGreyColor;
      preferencesSelected.remove(name);
    }
    if (preferencesSelected.isNotEmpty){
      preferencesContinueColor = kAppPinkColor;
    }else{
      preferencesContinueColor = kButtonGreyColor;
    }

    notifyListeners();
  }

  // Post and likes
  void resetPostLikes (){
    postLikes.clear();
    notifyListeners();
  }
  void setChangePostLikes(value, index){
    if (value == true ){
      postLikes[index] = Icon(CupertinoIcons.heart_fill, color: kAppPinkColor,);

    }else {
      postLikes[index] = Icon(CupertinoIcons.heart, color: kPureWhiteColor,);

    }
    notifyListeners();
  }
  void setPostLikes(value){
    if (value == true ){
      postLikes.add(Icon(CupertinoIcons.heart_fill, color: kAppPinkColor,));

    }else {
      postLikes.add(Icon(CupertinoIcons.heart, color: kPureWhiteColor,));

    }
    notifyListeners();
  }
  // For the favourite button
  void resetPostFavourites (){
    postFavourites.clear();
    notifyListeners();
  }
  void setChangeFavourite(value, index){
    if (value == true ){
      postFavourites[index] = Icon(Iconsax.star1, color: kAppPinkColor,size: 28,);

    }else {
      postFavourites[index] = Icon(Iconsax.star, color: kPureWhiteColor,size: 23,);

    }
    notifyListeners();
  }
  void setPostFavourites(value){
    if (value == true ){
      postFavourites.add(Icon(Iconsax.star1, color: kAppPinkColor,size: 23,));

    }else {
      postFavourites.add(Icon(Iconsax.star, color: kPureWhiteColor,size: 23,));
    }
    notifyListeners();
  }
}




