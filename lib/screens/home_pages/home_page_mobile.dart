
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/controllers/task_controller.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/analytics/analysis_page.dart';
import 'package:stylestore/screens/customer_pages/customers_page.dart';
import 'package:stylestore/screens/expenses_pages/expenses.dart';
import 'package:stylestore/screens/payment_pages/pos_mobile.dart';
import 'package:stylestore/screens/products_pages/restock_page.dart';
import 'package:stylestore/screens/sign_in_options/sign_in_page.dart';
import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:stylestore/utilities/constants/word_constants.dart';
import 'package:stylestore/widgets/photo_widget.dart';
import 'package:stylestore/widgets/report_popup.dart';
import '../../model/beautician_data.dart';
import '../../model/common_functions.dart';
import '../../utilities/constants/user_constants.dart';
import '../chat_messages/chat.dart';

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
  String checkInTime ="..loading";

  String businessName = 'Business';
  String userName = "";
  String image = '';
  String storeId = '';
  Map<String, dynamic> permissionsMap = {};
  FirebaseFirestore firestore = FirebaseFirestore.instance;



  void updateMedicsSubscriptionDates() async {
    final medicsCollection = FirebaseFirestore.instance.collection('medics');
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));

    // Optional: Format dates as per your preference
    final dateFormat = DateFormat('yyyy-MM-dd'); // Example format

    try {
      // Get all documents in the medics collection
      final medicsSnapshot = await medicsCollection.get();

      // Use a WriteBatch to perform multiple updates efficiently
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (final doc in medicsSnapshot.docs) {
        batch.update(doc.reference, {
          'subscriptionStartDate': now, // Or now.toString()
          'subscriptionEndDate': endDate, // Or endDate.toString()
        });
      }

      await batch.commit();
      print('Medics subscriptions dates updated successfully!');
    } catch (e) {
      print('Error updating subscriptions dates: $e');
    }
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

    var start = FirebaseFirestore.instance.collection('ai_analysis').where('storeId', isEqualTo: "qaYX1FNd7yMkyJVyRe92t6hoqF93"

    )
        .where('seen', isEqualTo: false)
        .snapshots().listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            isScrollControlled: true, context: context, builder: (context) {
          return ReportPopupWidget(backgroundColour: kBlueDarkColor,actionButton: "View Report", title: "Business Debrief Captain", subTitle: "Yesterday's Performance", function:(){}, report: doc['analysis'],);
        });
      });
    });
    return start;
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
    int? storedTimestamp = prefs.getInt(kSignInTime);
    DateTime lastSignInTime = DateTime.now();
    if (storedTimestamp != null) {
      DateTime storedTime = DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
      final formattedTime = DateFormat('EE HH:mm aa').format(storedTime);
      checkInTime = formattedTime;
      lastSignInTime = storedTime;
    }
    Provider.of<StyleProvider>(context, listen:false).setStoreValues(newStoreId, newImage);
    if (newIsCheckedIn == false){
      Navigator.pushNamed(context, SignInUserPage.id);
    }
    CommonFunctions().checkPeriodAndSignOut(context, lastSignInTime);
    setState(() {
      businessName = newName;
      image = newImage;
      storeId = newStoreId;
      isCheckedIn = newIsCheckedIn;
      userName = newUserName;
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
      print('ZAKARABUS ${message.data['type']}');
    });

}
  final sound = 'message_alert.wav';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: kPureWhiteColor,
      appBar: AppBar(

        backgroundColor: Colors.white,
        // foregroundColor: Colors.blue,
          title:
          Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$userName", style: kHeading2TextStyleBold.copyWith(fontSize: 14,),),
              Container(
                  decoration: BoxDecoration(
                      color: kBlueDarkColor,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(checkInTime, style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 12),),
                  )),
            ],
          ),

          // Column(
          //   // mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Text(businessName),
          //     Row(
          //       // crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //
          //       children: [
          //         Container(
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(10),
          //             color: kBackgroundGreyColor,
          //           ),
          //           child: Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.all(2.0),
          //                 child: Container(
          //                   decoration: const BoxDecoration(
          //                     shape: BoxShape.circle,
          //                     // borderRadius: BorderRadius.circular(10),
          //                     color: kAppPinkColor,
          //                   ),
          //                   child: Icon(Icons.circle, color: kPureWhiteColor,size: 15,),
          //                 ),
          //               ),
          //               kSmallWidthSpacing,
          //               Text(storeLocation,overflow: TextOverflow.fade, style: kNormalTextStyleWhiteLabel.copyWith( fontSize: 12),),
          //               kSmallWidthSpacing
          //             ],
          //           ),
          //         ),
          //         kMediumWidthSpacing,
          //       ],
          //     ),
          //   ],
          // ),
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
                    content: Text('${cSignOutInstructions.tr} \n${DateFormat('hh:mm a EE, dd, MMM, yyy').format(DateTime.now())}'),
                    actions: [
                      CupertinoDialogAction(isDestructiveAction: true,
                          onPressed: (){

                            Navigator.pop(context);

                          },

                          child: Text(cCancel.tr)
                      ),
                      CupertinoDialogAction(isDefaultAction: true,
                        onPressed: (){

                          // Navigator.pop(context);
                          CommonFunctions().signOutUser(context, false);

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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     updateMedicsSubscriptionDates();
      //   },
      // ),
      floatingActionButton: permissionsMap['admin'] == false ?Container() :Stack(
          children: [
            // Container(
            //   height: 50,
            //   width: 80,
            // ) ,

            FloatingActionButton(
              onPressed: (){


                showDialog(context: context, builder: (BuildContext context){
                  return
                    GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: ChatPage());
                });
              },
              child:
              Image.asset("images/pilot2.png",height: 40, fit: BoxFit.fitHeight,),
              // Icon(Iconsax.airpod1, color: kPureWhiteColor,),
              backgroundColor: kBlueDarkColor,
            ),
            Positioned(
              left: 0,
              top: 0,
              child: CircleAvatar(
                backgroundColor: kAppPinkColor,
                radius: 7,
                child: Text("1", style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10),),
              ),
            ),
          ]
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: ListView(
          padding: EdgeInsets.all(20),

          children: [


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
                  footer: cSale.tr,iconToUse: Icons.point_of_sale,
                  widgetColor: kSalesButtonColor,
                  iconColor: kCustomColorPink,
                  fontSize: CommonFunctions().calculateFontSize(context)
                  // 16,
                
                )
                    : Container(),
                kMediumWidthSpacing,
                permissionsMap['customers'] == true ?
                PhotoWidget(onTapFunction: (){  Navigator.pushNamed(context, CustomerPage.id );},footer: cCustomers, iconToUse: Icons.people_alt_outlined,
                  widgetColor:kCustomersButtonColor ,
                  iconColor:kBlueDarkColor, fontSize: CommonFunctions().calculateFontSize(context),):Container(),
  

            ],),
            kSmallHeightSpacing,
            permissionsMap['expenses'] == true ?
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: PhotoWidget(onTapFunction: (){  Navigator.pushNamed(context, ExpensesPage.id );},footer: cExpense, iconToUse: Iconsax.minus, widgetColor:kPlainBackground.withOpacity(1) ,iconColor:kBlueDarkColor,height: 40,width: double.infinity, fontSize: CommonFunctions().calculateFontSize(context),),
            ):Container(),
  

            kLargeHeightSpacing,

            SizedBox(
              height: 500,
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
