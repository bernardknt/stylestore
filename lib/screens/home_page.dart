
import 'dart:async';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/controllers/task_controller.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/analytics/analysis_page.dart';
import 'package:stylestore/screens/bluetooth_printer/bluetooth_printer.dart';
import 'package:stylestore/screens/customer_pages/customers_page.dart';
import 'package:stylestore/screens/expenses_pages/expenses.dart';
import 'package:stylestore/screens/payment_pages/pos2.dart';
import 'package:stylestore/screens/products_pages/restock_page.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/screens/sign_in_options/sign_in_page.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import 'package:stylestore/widgets/custom_popup.dart';
import 'package:stylestore/widgets/photo_widget.dart';
import 'package:stylestore/widgets/report_popup.dart';
import '../model/beautician_data.dart';
import '../model/common_functions.dart';
import '../utilities/constants/user_constants.dart';

import '../widgets/locked_widget.dart';
import '../widgets/rounded_icon_widget.dart';
import 'bluetoothPage.dart';
import 'change_store_photo.dart';
import 'edit_page.dart';
import 'new_printer.dart';

class HomePage extends StatefulWidget {
  static String id = 'home_page';

  @override

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var orderStatus = [];
  var colours = [];
  var location = [];
  var storeLocation = "";
  var customerName = [];
  var orderNumber = [];
  var formatter = NumberFormat('#,###,000');

  var pages = ['New Orders: 0}', 'DetoxPlansPage.id', 'SaladsPage.id', 'TropicalPage.id '];
  var orderContents = [];

  var instructions = [];
  var appointmentDate = [];
  var appointmentTime = [];
  var bookingFee = [];
  var note = [];
  var cardColor = [];
  var textColor = [];
  var phoneCircleColor = [];
  var names = [];
  var appointmentsToday = [];
  var customerPhone = [];
  var onlineStatus = [];
  var bellOpacity = [];
  List <Color> onlineStatusColour = [];
  var totalBill= [];
  var newOrderNumber = 0;
  late bool isCheckedIn;

  String businessName = 'Business';
  String userName = "";
  String image = '';
  String storeId = '';
  Map<String, dynamic> permissionsMap = {};
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Timer _timer;

  double calculateFontSize(BuildContext context, double baseFontSize) {
    // Calculate font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = baseFontSize;

    if (screenWidth <= 320) {
      fontSize = baseFontSize - 2.0;
    } else if (screenWidth <= 360) {
      fontSize = baseFontSize - 1.0;
    } else if (screenWidth >= 414) {
      fontSize = baseFontSize + 2.0;
    }

    return fontSize;
  }

  Future<void> updateBarcodes() async {

    QuerySnapshot storesSnapshot = await firestore.collection('stores').get();

    for (QueryDocumentSnapshot storeDoc in storesSnapshot.docs) {
      String storeId = storeDoc.id;

      await firestore.collection('stores').doc(storeId).update({
        'barcode': storeId,
        'scannable': false
      });
    }

    print('Barcode update complete');
  }
  Future<void> updatePermissionsForAllMedics() async {


    String newPermissions = '{"transactions": true,"expenses": true,"customers": true,"sales": true,"store": true,"analytics": true,"messages": true,"tasks": true,"admin": true,"summary": true,"employees": true,"notifications": true,"signIn": false,"takeStock": true, "qrCode": false}';

    try {
      QuerySnapshot querySnapshot = await firestore.collection('medics').get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({
          'permissions': newPermissions,
        });
      }

      print('Update completed');
    } catch (error) {
      print('Error: $error');
    }
  }



  // Function to check if the field stockTaking exists in a document
  bool fieldExists(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
    return data?.containsKey('stockTaking') ?? false;
  }

  // Function to update the document and add stockTaking field with an empty array
  Future<void> addStockTakingField(DocumentReference documentRef) {
    return documentRef.update({'sms': 5});
  }

  Future<void> updateDialogueAlert(docId) {

    return FirebaseFirestore.instance.collection('medics').doc(docId)
        .update({
      'restock': false,
      'realert': false,
      'report': false,
    })
        .then((value) => print("Call Ended"))
        .catchError((error) => print("Failed to send Communication: $error"));
  }


  Future incomingReportsStream()async{
    final prefs = await SharedPreferences.getInstance();
    var heading = "";
    var subHeading = "";
    var button = "";
    var anime = "";
    var functionToExecute = ()async{};

    var start = FirebaseFirestore.instance.collection('medics').where('id', isEqualTo: prefs.getString(kStoreIdConstant))
        .where('realert', isEqualTo: true)
        .snapshots().listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {


        if (doc['restock'] == true){
          heading = "Take Stock of Items";
          subHeading = "Time to see how much stock you have";
          button = "Take Stock";
          functionToExecute = ()async{
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReStockPage()));
          };
          //pageRoute = UpdateStockPage();
          anime = "report.json";
        }else if (doc['report'] == true){
          heading = "Your Days Report";
          subHeading = "We summarized Today's business for you.";
          button = "View Report";
          functionToExecute = ()async{
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool(kAnalysisMode, true);

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AnalysisPage()));
          };
          anime = "report.json";
        } else {
          print("Nothing");
          anime = "report.json";
        }

        setState(() {
          CoolAlert.show(
              lottieAsset: "images/$anime",
              context: context,
              type: CoolAlertType.success,
              text: subHeading,
              title: heading,
              confirmBtnText: button,
              confirmBtnTextStyle: kNormalTextStyle.copyWith(color: kPureWhiteColor),
              showCancelBtn: true,
              cancelBtnText: "Cancel",
              cancelBtnTextStyle: kNormalTextStyle,
              onCancelBtnTap: (){
                Navigator.pop(context);
                updateDialogueAlert(doc.id);
              },
              confirmBtnColor: kAppPinkColor,
              backgroundColor: kBlack, onConfirmBtnTap: ()async{
            updateDialogueAlert(doc.id);

              final prefs = await SharedPreferences.getInstance();
              Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));
              Navigator.pop(context);
              functionToExecute();


          }

          );

        });

      });
    });


    return start;
  }
  Future incomingAiStream()async{
    print("THIS RUNNNN OOOOOO");
    final prefs = await SharedPreferences.getInstance();
    var heading = "";
    var subHeading = "";
    var button = "";
    var anime = "";
    var functionToExecute = ()async{};

    var start = FirebaseFirestore.instance.collection('ai_analysis').where('storeId', isEqualTo: "qaYX1FNd7yMkyJVyRe92t6hoqF93"
      //prefs.getString(kStoreIdConstant)
    )
        .where('seen', isEqualTo: false)
        .snapshots().listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            isScrollControlled: true, context: context, builder: (context) {
          return ReportPopupWidget(backgroundColour: kBlueDarkColor,actionButton: "View Report", title: "Business Debrief Captain", subTitle: "Yesterday's Performance", function:(){}, report: doc['analysis'],);
        });


        //   if (doc['restock'] == true){
        //     heading = "Take Stock of Items";
        //     subHeading = "Time to see how much stock you have";
        //     button = "Take Stock";
        //     functionToExecute = ()async{
        //       Navigator.push(
        //           context, MaterialPageRoute(builder: (context) => ReStockPage()));
        //     };
        //     //pageRoute = UpdateStockPage();
        //     anime = "report.json";
        //   }else if (doc['report'] == true){
        //     heading = "Your Days Report";
        //     subHeading = "We summarized Today's business for you.";
        //     button = "View Report";
        //     functionToExecute = ()async{
        //       final prefs = await SharedPreferences.getInstance();
        //       prefs.setBool(kAnalysisMode, true);
        //
        //       Navigator.push(
        //           context, MaterialPageRoute(builder: (context) => AnalysisPage()));
        //     };
        //     anime = "report.json";
        //   } else {
        //     print("Nothing");
        //     anime = "report.json";
        //   }
        //
        //   setState(() {
        //     CoolAlert.show(
        //         lottieAsset: "images/$anime",
        //         context: context,
        //         type: CoolAlertType.success,
        //         text: subHeading,
        //         title: heading,
        //         confirmBtnText: button,
        //         confirmBtnTextStyle: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        //         showCancelBtn: true,
        //         cancelBtnText: "Cancel",
        //         cancelBtnTextStyle: kNormalTextStyle,
        //         onCancelBtnTap: (){
        //           Navigator.pop(context);
        //           updateDialogueAlert(doc.id);
        //         },
        //         confirmBtnColor: kAppPinkColor,
        //         backgroundColor: kBlack, onConfirmBtnTap: ()async{
        //       updateDialogueAlert(doc.id);
        //
        //       final prefs = await SharedPreferences.getInstance();
        //       Provider.of<BeauticianData>(context, listen: false).setStoreId(prefs.getString(kStoreIdConstant));
        //       Navigator.pop(context);
        //       functionToExecute();
        //
        //
        //     }
        //
        //     );
        //
        //   });
        //
      });
    });


    return start;
  }


  Future<void> signOutUser ()async {
    final prefs = await SharedPreferences.getInstance();
    final dateNow = new DateTime.now();
    showDialog(context: context, builder: ( context) {
      return Center(
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kAppPinkColor,),
              kSmallHeightSpacing,
              DefaultTextStyle(
                style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
                child: Text("Signing out of Work"),
              )
              // Text("Loading Contacts", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
            ],
          ));
    }
    );



    CollectionReference userOrder = FirebaseFirestore.instance.collection('attendance');

    String? orderId = prefs.getString(kAttendanceCode);
    return userOrder.doc(orderId)
        .update({
      'signOut':dateNow
    })
        .then((value) {
          Navigator.pop(context);
      Navigator.pushNamed(context, SignInUserPage.id);
      CommonFunctions().updateEmployeeSignInAndOutDoc(false);
      prefs.setBool(kIsCheckedIn, false);
    } )
        .catchError((error) {

      CoolAlert.show(
          lottieAsset: 'images/question.json',
          context: context,
          type: CoolAlertType.success,
          text: error,
          title: "An Error occurred",
          confirmBtnText: 'Yes',
          confirmBtnColor: Colors.red,
          cancelBtnText: 'Cancel',
          showCancelBtn: true,
          backgroundColor: kAppPinkColor,
          onConfirmBtnTap: (){



            Navigator.pop(context);
          }
      );
    }

       );
  }

  bool isLoading = false;
  final HttpsCallable callableSmsTransaction = FirebaseFunctions.instance.httpsCallable('updateAiSMS');


  void defaultsInitiation () async{

    
    final prefs = await SharedPreferences.getInstance();
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    String newName = prefs.getString(kBusinessNameConstant) ?? 'Hi';
    storeLocation = prefs.getString(kLocationConstant) ?? 'Hi';
    String newImage = prefs.getString(kImageConstant) ?? 'okola_logo.png';
    String newStoreId = prefs.getString(kStoreIdConstant) ?? 'Hi';
    String newUserName = prefs.getString(kLoginPersonName) ?? "Hi";
    bool newIsCheckedIn = prefs.getBool(kIsCheckedIn) ?? false;
    Provider.of<StyleProvider>(context, listen:false).setStoreValues(newStoreId, newImage);
    if (newIsCheckedIn == false){
      Navigator.pushNamed(context, SignInUserPage.id);
    }
    // incomingReportsStream();
    incomingAiStream();
    // Provider.of<BeauticianData>(context, listen: false).resetAppointmentToday();

    setState(() {
      // animationTimer(appointmentsToday);
      businessName = newName;
      image = newImage;
      storeId = newStoreId;
      isCheckedIn = newIsCheckedIn;
      userName = newUserName;
      print("GOGOOGOGOGOOGOGOOG ${prefs.get(kPhoneNumberConstant)}");



    });
  }

  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();

    FirebaseMessaging.instance.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: true
    );
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Get.toNamed(NOTIFICATIOINS_ROUTE);
      print('ZAKARABUS ${message.data['type']}');
    });

}
  final sound = 'message_alert.wav';

  @override
  Widget build(BuildContext context) {
    double baseFontSize = 16.0; // Set your base font size here
    final screenSize = MediaQuery.of(context).size.width.round();


    return Scaffold(

      backgroundColor: kPureWhiteColor,
      floatingActionButton: permissionsMap['admin']!=true?Container():FloatingActionButton(
        backgroundColor: kAppPinkColor.withOpacity(0.3),
          child: Icon(Iconsax.activity5, color: kBlueDarkColor,),

          onPressed: () async {
            // Navigator.pushNamed(context, NewPrinter.id);
            //Navigator.pushNamed(context, NewPrinterDonePerfect.id);
          }


    // showModalBottomSheet(
    //     backgroundColor: Colors.transparent,
    //     isScrollControlled: true, context: context, builder: (context) {
    //   return BluetoothPage();
    //return NewPrinter();
    //}
            // ReportPopupWidget(backgroundColour: kBlueDarkColor,actionButton: "View Report", title: "Business Debrief Captain", subTitle: "Yesterday's Performance", function:(){});



            // updateBarcodes();
            // loopThroughCollection();
            // updatePermissionsForAllMedics();
            // updateBusinessPhoneFromPhone();
            // dynamic serverCallableVariable = await callableSmsTransaction.call(<String, dynamic>{
            //   "userId" : "FE20230715-94",
            //   "client" : "Bernard Ntege",
            //   "amount" : "10000",
            //   "currency" : "UGX",
            //   "business" : "Fruts Express",
            //   "phone" : "0700457826"
            // }).catchError((error){print('Request failed with status code ${error}');
            // print('Response body: ${error}');
            // });
           // updatePaidAmountFromTotalFee();
            // Provider.of<StyleProvider>(context, listen: false).clearLists();
            //
            //
            // showModalBottomSheet(
            //     context: context,
            //     // isScrollControlled: true,
            //     builder: (context) {
            //       return RecordAppointment();
            //     });


            // await CommonFunctions().testingTesting;


        // backgroundColor: kAppPinkColor,
        // child: Icon(LineIcons.receipt, color: kPureWhiteColor,),

      ),
      appBar: AppBar(

        backgroundColor: Colors.white,
        // foregroundColor: Colors.blue,
          title: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(businessName),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kBackgroundGreyColor,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(10),
                              color: kAppPinkColor,
                            ),
                            child: Icon(Icons.circle, color: kPureWhiteColor,size: 15,),
                          ),
                        ),
                        kSmallWidthSpacing,
                        Text(storeLocation,overflow: TextOverflow.fade, style: kNormalTextStyleWhiteLabel.copyWith( fontSize: 12),),
                        kSmallWidthSpacing
                      ],
                    ),
                  ),
                  kMediumWidthSpacing,
                ],
              ),
            ],
          ),
        centerTitle: true,
        elevation:1 ,
        actions: [
          permissionsMap['signIn'] == false ? Container():Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            GestureDetector(
              onTap: (){
                showDialog(context: context, builder: (BuildContext context){
                  return CupertinoAlertDialog(
                    title:Text(cSignOut.tr),
                    content: Text('Are you Sure you want Sign Out at \n${DateFormat('hh:mm a EE, dd, MMM, yyy').format(DateTime.now())}'),
                    actions: [
                      CupertinoDialogAction(isDestructiveAction: true,
                          onPressed: (){
                            // _btnController.reset();
                            Navigator.pop(context);

                            // Navigator.pushNamed(context, SuccessPageHiFive.id);
                          },

                          child: Text(cCancel.tr)
                      ),
                      CupertinoDialogAction(isDefaultAction: true,
                        onPressed: (){
                          // Provider.of<StyleProvider>(context, listen: false).removeSelectedInvoicedItem(InvoiceItem(name: styleData.invoiceItems[index].name, quantity: styleData.invoiceItems[index].quantity, unitPrice: styleData.invoiceItems[index].unitPrice));

                          Navigator.pop(context);
                          signOutUser();

                        }, child: Text(cSignOut.tr),)
                    ],
                  );
                });



              },
              child: Container(
                // height: 10,
                width: 100,
                decoration: BoxDecoration(
                  color: kBlack,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(cSignOutOfWork.tr, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 13),)),
                // color: kAirPink,
              ),
            ),
          ),
        ],

        leading: GestureDetector(
            onTap: (){
              ZoomDrawer.of(context)!.toggle();

            },
            child: Icon(Icons.menu))
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: ListView(
          padding: EdgeInsets.all(20),

          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                GestureDetector(
                    onTap: (){
                      // buildShowDialog(context);
                      if(permissionsMap['admin'] == false ) {

                      } else {
                         Navigator.pushNamed(context, ChangeStorePhoto.id);
                        // showDialog(context: context, builder: ( context) {
                        //   return  CustomPopupWidget();
                        //
                        // });

                      }


                    },
                    child: RoundImageRing(radius: 50, outsideRingColor: kPureWhiteColor, networkImageToUse: image,)),
                kSmallWidthSpacing,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${cWelcome.tr} \n$userName\ $screenSize px", style: kHeading3TextStyleBold.copyWith(fontSize: 17, color: kFaintGrey),),


                  ],
                ),
              ],
            ),
            // kLargeHeightSpacing,
            // Text("Get Started", style: kHeading3TextStyleBold.copyWith(fontSize: 16, ),
            // ),
            kLargeHeightSpacing,

            // TicketDots(mainColor: kFontGreyColor,circleColor: kPureWhiteColor,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                permissionsMap['sales'] == true ?
                PhotoWidget(
                  onTapFunction: (){
                    Provider.of<StyleProvider>(context, listen: false).resetSelectedStockBasket();
                  Provider.of<StyleProvider>(context, listen: false).resetCustomerDetails();
                  Provider.of<StyleProvider>(context, listen: false).clearLists();
                  Navigator.pushNamed(context, POS.id );},
                  footer: cSale.tr,iconToUse: Iconsax.card_pos,
                  widgetColor: kCustomColorPink.withOpacity(0.3),
                  iconColor: kCustomColorPink,
                  fontSize: calculateFontSize(context, baseFontSize)
                  // 16,
                
                )
                    : Container(),
                kMediumWidthSpacing,
                permissionsMap['customers'] == true ?
                PhotoWidget(onTapFunction: (){  Navigator.pushNamed(context, CustomerPage.id );},footer: cCustomers, iconToUse: Iconsax.personalcard, widgetColor:kCustomColor.withOpacity(0.3) ,iconColor:kBlueDarkColor, fontSize: calculateFontSize(context, baseFontSize),):Container(),
  

            ],),
            kSmallHeightSpacing,
            permissionsMap['expenses'] == true ?
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: PhotoWidget(onTapFunction: (){  Navigator.pushNamed(context, ExpensesPage.id );},footer: cExpense, iconToUse: Iconsax.minus, widgetColor:kPureWhiteColor.withOpacity(0.3) ,iconColor:kBlueDarkColor,height: 40,width: double.infinity, fontSize: calculateFontSize(context, baseFontSize),),
            ):Container(),
  

            kLargeHeightSpacing,

            SizedBox(
              height: 400,
              child: TasksController()
            ),


          ],
        ),
      ),
    );
  }
  Future<void> upLoadOrder ()async {
    final dateNow = new DateTime.now();



    CollectionReference userOrder = FirebaseFirestore.instance.collection('attendance');
    final prefs =  await SharedPreferences.getInstance();
    String? orderId = prefs.getString(kAttendanceCode);
    return userOrder.doc(orderId)
        .update({
      'signOut':dateNow
    })
        .then((value) {
          Navigator.pop(context);
      Navigator.pushNamed(context, SignInUserPage.id);

    } )
        .catchError((error) => print("Failed to add user: $error"));
  }

}
