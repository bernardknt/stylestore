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
import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/constants/user_constants.dart';
import '../MobileMoneyPages/make_payment_page.dart';
import '../MobileMoneyPages/mm_payment_button_widget.dart';
import '../MobileMoneyPages/mm_payment_processing_widget.dart';

var uuid = const Uuid();

class SubscriptionMobileMoneyPage extends StatefulWidget {
  static String id = 'subscription_mobilePayment_page';

  const SubscriptionMobileMoneyPage({Key? key}) : super(key: key);


  @override
  _SubscriptionMobileMoneyPageState createState() => _SubscriptionMobileMoneyPageState();
}

class _SubscriptionMobileMoneyPageState extends State<SubscriptionMobileMoneyPage> {
  void defaultsInitiation () async{
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant)??"uuuuuuuu";
    email = prefs.getString(kEmailConstant)??"uuuuuuuu";

    String newName = prefs.getString(kBusinessNameConstant) ?? 'Minister';
    double? newAmount = prefs.getDouble(kBillValue);
    String newPhoneNumber = prefs.getString(kPhoneNumberConstant) ?? '0';
    String? newOrderId = const Uuid().v4();
    myController = TextEditingController()..text = CommonFunctions().processPhoneNumber(prefs.getString(kPhoneNumberConstant) ?? '0');

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
      'currency': Provider.of<StyleProvider>(context, listen: false).subscriptionPackageCurrency, // John Doe
      'date': dateNow, // Stokes and Sons
      'purpose': Provider.of<StyleProvider>(context, listen: false).subscriptionPackageToBuy,
      'uniqueID': orderId,
      'testID': transactionId,
      'storeId': storeId,
      'email': email,
      'duration':Provider.of<StyleProvider>(context, listen: false).subscriptionPackageDuration,

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
  String transactionId = 'BP${uuid.v1().split("-")[0]}';
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
        centerTitle: true,
        title: Text('Subscription Payment', style: kHeading2TextStyleBold.copyWith(fontWeight: FontWeight.w900),),
        backgroundColor: kPureWhiteColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

            color: Colors.white,
            padding: EdgeInsets.all(60),
            child: Center(
              child: Column(

                children: [
                  SubscriptionSummaryWidget(value: styleDataDisplay.subscriptionPackageToBuy, title: 'Subscription',),
                  kSmallHeightSpacing,
                  SubscriptionSummaryWidget(value: "${styleDataDisplay.subscriptionPackageDuration.toString()} Days", title: 'Duration',),
                  kSmallHeightSpacing,
                  SubscriptionSummaryWidget(value: "${styleDataDisplay.subscriptionPackageCurrency} ${CommonFunctions().formatter.format(styleDataDisplay.subscriptionPackageAmount)}", title: 'Amount',),
                  kSmallHeightSpacing,
                  SubscriptionSummaryWidget(value: transactionId, title: 'Txd',),
                  kLargeHeightSpacing,
                  kLargeHeightSpacing,
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
                      Expanded(child: TextForm(label: "Phone Number to Pay", controller: myController, keyBoardType: TextInputType.number,)),
                    ],
                  ),
                   kLargeHeightSpacing,

                  MobileMoneyPaymentButton(buttonTextColor:Colors.white,buttonColor: kAppPinkColor,lineIconFirstButton: LineIcons.paypal,
                      firstButtonFunction: ()async{
                        Navigator.pushNamed(context, MakePaymentPage.id);
                        showModalBottomSheet(context: context, builder: (context) => Container(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: PaymentProcessing(),
                        ));

                        String number = '256${myController.text}';
                        amountToCharge = styleDataDisplay.subscriptionPackageAmount.toString();
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

class SubscriptionSummaryWidget extends StatelessWidget {
  final String value;
  final String title;
  const SubscriptionSummaryWidget({
    super.key,
    required this.value, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBabyPinkThemeColor,
            borderRadius: BorderRadius.circular(8)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$title: ", style: kNormalTextStyle.copyWith(color: kBlack)),

            Text(value, style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, color: kBlack),)

          ],),
      ),
    );
  }
}
