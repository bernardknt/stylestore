import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/widgets/text_form.dart';

import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../controllers/home_page_controllers/home_controller_mobile.dart';
import '../../controllers/responsive/responsive_page.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/user_constants.dart';

import 'make_payment_page.dart';
import 'mm_payment_button_widget.dart';
import 'mm_payment_processing_widget.dart';
var uuid = const Uuid();

class CustomMobileMoneyPage extends StatefulWidget {
  static String id = 'custom_mobilePayment_page';

  const CustomMobileMoneyPage({Key? key}) : super(key: key);


  @override
  _CustomMobileMoneyPageState createState() => _CustomMobileMoneyPageState();
}

class _CustomMobileMoneyPageState extends State<CustomMobileMoneyPage> {
  void defaultsInitiation () async{
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant)??"uuuuuuuu";
    email = prefs.getString(kEmailConstant)??"uuuuuuuu";

    String newName = prefs.getString(kBusinessNameConstant) ?? 'Minister';
    double? newAmount = prefs.getDouble(kBillValue);
    String newPhoneNumber = prefs.getString(kPhoneNumberConstant) ?? '0';
    String? newOrderId = const Uuid().v4();
    myController = TextEditingController()..text = CommonFunctions().processPhoneNumber(prefs.getString(kPhoneNumberConstant) ?? '0',  prefs.getString(kCountryCode)??"");

    // orderId = const Uuid().v4();


    setState(() {

      name = newName;
      //amount = int.parse(newAmount);

      phoneNumber = newPhoneNumber;
      orderId = newOrderId!;

    });
  }
// CALLABLE FUNCTIONS FOR THE NODEJS SERVER (FIREBASE)
  final HttpsCallable callableBeyonicPayment = FirebaseFunctions.instance.httpsCallable(kBeyonicServerName);
  // final HttpsCallable callableTransactionEmail = FirebaseFunctions.instance.httpsCallable(kEmailServerName);




  // THESE ARE FIRESTORE COLLECTION REFERENCES
  // CollectionReference userTransactions = FirebaseFirestore.instance.collection('userTransactions');
  CollectionReference paymentTransactions = FirebaseFirestore.instance.collection('transactions');


  // FIREBASE FIRESTORE STREAM TO CHECK WHETHER THE TRANSACTION HAS BEEN SUCCESSFUL

  Future<void> addMobileMoneyTransaction() {

    // final User? user = auth.currentUser;
    // final emailUID = user!.email;
    return paymentTransactions.doc(transactionId).set({
      'name': name,
      'amount_paid': amount, // John DoeStr
      'beyonic_charge': amountToCharge,
      'collectionID':0,
      'number': '256$phoneNumber',
      'payment_status': false,
      'currency': 'Ugx', // John Doe
      'date': dateNow, // Stokes and Sons
      'purpose': "SMS Renewal",
      'uniqueID': orderId,
      'testID': transactionId,
      'storeId': storeId,
      'email': email,
    })
        .then((value){

    })
        .catchError((error){

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
  }
  // VARIABLE DECLARATIONS

  var formatter = NumberFormat('#,###,000');
  String transactionId = 'mm${uuid.v1().split("-")[0]}';
  String storeId = '';
  String email = '';
  double amount = 0;
  String amountToCharge = '';
  String orderId = '';
  late String churchId ;
  final dateNow = new DateTime.now();
  double changeNumberOpacity = 0.0;
  String name = '';
  late String churchName;
  String setPhoneMessage = 'Set this as your default Number';
  late String phoneNumber;
  TextEditingController myController  = TextEditingController()..text = '';
  final TextEditingController amountController = TextEditingController();
  bool checkboxValue = false;
  double changeInvalidMessageOpacity = 0.0;
  String invalidMessageDisplay = 'Invalid Number';
  String fontFamily = 'Montserrat-Medium';
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    var styleDataDisplay = Provider.of<StyleProvider>(context);
    // amount = styleDataDisplay.bookingPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Load SMS Bundles', style: kHeading2TextStyleBold,),
        backgroundColor: kPureWhiteColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

            color: Colors.white,
            padding: EdgeInsets.all(60),
            child: Center(
              child: Column(

                children: [
                  // Text('Load Amount', textAlign: TextAlign.center, style: kHeading2TextStyleBold,),
                  // kLargeHeightSpacing,
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Text('+256'),
                  //     ),
                  //     kMediumWidthSpacing,
                  //     Expanded(
                  //       child:
                  //       TextField(
                  //         maxLength: 9,
                  //         controller: myController,
                  //         mouseCursor: MouseCursor.defer,
                  //         onChanged: (value){
                  //
                  //           setState(() {
                  //             if (value.split('')[0] == '7'){
                  //               invalidMessageDisplay = 'Incomplete Number';
                  //               if (value.length == 9 && value.split('')[0] == '7'){
                  //                 changeNumberOpacity = 1.0;
                  //                 phoneNumber = value;
                  //                 phoneNumber.split('0');
                  //                 print(value.split('')[0]);
                  //                 print(phoneNumber.split(''));
                  //                 changeInvalidMessageOpacity = 0.0;
                  //               } else if(value.length !=9 || value.split('')[0] != '7'){
                  //                 changeInvalidMessageOpacity = 1.0;
                  //                 changeNumberOpacity = 0.0;
                  //               }
                  //
                  //             }else {
                  //               invalidMessageDisplay = 'Number should start with 7';
                  //               changeInvalidMessageOpacity = 1.0;
                  //             }
                  //           });
                  //         }
                  //         ,keyboardType: TextInputType.number ,decoration:
                  //       InputDecoration(filled: true,
                  //         fillColor: Colors.white, labelText: 'Mobile Number',
                  //         border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10),),),),),
                  //     ),
                  //   ],
                  // ),
                  // //SizedBox(height: 10,),
                  // Opacity(opacity:changeInvalidMessageOpacity, child: Text(invalidMessageDisplay,overflow: TextOverflow.clip, style: TextStyle(color: Colors.red),)),
                  // Opacity(
                  //     opacity: changeNumberOpacity,
                  //     child: Center(
                  //       child: Row(
                  //         children: [
                  //           Checkbox(value: checkboxValue, onChanged: (value) async{
                  //             final prefs = await SharedPreferences.getInstance();
                  //             print(value);
                  //             setState(() {
                  //               checkboxValue = value!;
                  //               prefs.setString(kPhoneNumberConstant, phoneNumber);
                  //             });
                  //           }),
                  //           Text(setPhoneMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: kGreenJavasThemeColor), ),
                  //         ],
                  //       ),
                  //     )),
                  Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            color: kPlainBackground, 
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Padding(
                        
                        padding: const EdgeInsets.all(8.0),
                        child: Text("+256"),
                      )), 
                      kSmallWidthSpacing, 
                      kSmallWidthSpacing,
                      Expanded(child: TextForm(label: "Phone Number", controller: myController, keyBoardType: TextInputType.number,)),
                    ],
                  ),
                  TextForm(label: "Amount to Load", controller: amountController, keyBoardType: TextInputType.number,),
                  kLargeHeightSpacing,
                  // Text("$name You are making a payment of ${styleDataDisplay.bookingPrice == 0?'0':CommonFunctions().formatter.format(styleDataDisplay.bookingPrice)} Ugx for order $orderId", textAlign: TextAlign.center,
                  //     style: TextStyle(fontSize: 15,color: kBlueDarkColor, fontWeight: FontWeight.normal)),
                  // kLargeHeightSpacing,
                  MobileMoneyPaymentButton(buttonTextColor:Colors.white,buttonColor: kAppPinkColor,lineIconFirstButton: LineIcons.paypal,
                      firstButtonFunction: ()async{
                        Navigator.pushNamed(context, MakePaymentPage.id);
                        showModalBottomSheet(context: context, builder: (context) => Container(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: PaymentProcessing(),
                        ));

                        String number = '256${myController.text}';
                        amountToCharge = amountController.text.toString();
                        amount = double.parse(amountToCharge) ;
                        dynamic resp = await callableBeyonicPayment.call(<String, dynamic>{
                          'number': number,
                          'amount':amountToCharge,
                          'transId': transactionId
                          // orderId
                        });
                        CommonFunctions().transactionStream(context, orderId);
                        addMobileMoneyTransaction();
                        final prefs = await SharedPreferences.getInstance();
                        //prefs.setString(kChurchTransactionIdConstant, transactionId);
                        print('+256$phoneNumber message sent');
                        // Create a document in the Transactions Db
                      }, firstButtonText: 'Make Payment'),
                 kLargeHeightSpacing,
                  Opacity(
                      opacity: 0.5,
                      child: Image.asset('images/airtelMtn.png', height: 100, width: 100, )),
                  kLargeHeightSpacing,
                  GestureDetector(onTap: (){
                    Navigator.pop(context);
                  },
                    child: Text('Cancel', style: kNormalTextStyle.copyWith(color: kRedColor),),)
                ],
              ),
            ),

          ),
        ),
      ),

    );
  }
}
