
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/controllers/task_controller.dart';
import 'package:stylestore/model/printing/test_print1.dart';
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
import '../../controllers/responsive/responsive_dimensions.dart';
import '../../controllers/subscription_controller.dart';
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
  bool runOnce = false;
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

    });

}

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   final notificationIcon = Provider.of<StyleProvider>(context).notificationIcon;
  //   if (notificationIcon && runOnce == false) {
  //     runOnce = true;
  //     CommonFunctions().ShowCaptain(context, true );
  //   }
  // }

  final sound = 'message_alert.wav';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: kPureWhiteColor,
      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation:1 ,
        actions: [

          GestureDetector(
                onTap: (){
                  CommonFunctions().showChecklistToBeDoneDialog(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>PrintReceiptPage()));
                  //

                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, top: 7),
                  child: Container(
                      decoration: BoxDecoration(
                          color: kCustomColor,
                          borderRadius: BorderRadius.circular(boxCurve)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Icon(Iconsax.task, size: 22,),
                            Text("Checklist",style: kNormalTextStyle.copyWith(fontSize: 8, color: kBlack, fontWeight: FontWeight.w700),)
                          ],
                        ),
                      )),
                ),
              ),

          permissionsMap['signIn'] == false ? Container():Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            GestureDetector(
              onTap: (){
                showDialog(context: context, builder: (BuildContext context){
                  return CupertinoAlertDialog(
                    title:Text(cSignOut.tr),
                    content: Text('${cSignOutInstructions.tr} \n${DateFormat('kk:mm a EE, dd, MMM, yyy').format(DateTime.now())}'),
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

      floatingActionButton: permissionsMap['admin'] == false ?Container() :
      Stack(
          children: [
            Container(
              height: 100,
              width: 100,
              // color: kRedColor,

            ),
            Positioned(
              left: 40,
              right: 0,
              top: 20,
              child: FloatingActionButton(
                onPressed: ()async{
                  final prefs = await SharedPreferences.getInstance();
                  String name = prefs.getString(kBusinessNameConstant)??"";

                  Provider.of<StyleProvider>(context, listen: false).removeNotificationIcon();
                  showDialog(context: context, builder: (BuildContext context){
                    return
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child:
                          //TutorialVideoPage(videoUrl: "https://www.youtube.com/watch?v=3dtwm9RgDlU&ab_channel=Jayse")
                          ChatPage()
                        // SubscriptionController()
                      );
                  });

                },

                backgroundColor: kBlueDarkColor,
                child:
                Image.asset("images/pilot2.png",height: 40, fit: BoxFit.fitHeight,),
              ),
            ),
            Provider.of<StyleProvider>(context, listen: true).notificationIcon == true?
            Positioned(
                left: 20,
                top: 10,
                child:
                Lottie.asset("images/notificationIcon.json", height: 40)

            ):const SizedBox(),
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
                permissionsMap['expenses'] == true ?
                PhotoWidget(onTapFunction: (){  Navigator.pushNamed(context, ExpensesPage.id );},footer: cExpense, iconToUse:Icons.monetization_on ,
                  widgetColor:kCustomersButtonColor ,
                  iconColor:kBlueDarkColor, fontSize: CommonFunctions().calculateFontSize(context),):Container(),
  

            ],),
            kSmallHeightSpacing,
            permissionsMap['customers'] == true ?
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: PhotoWidget(onTapFunction: (){  Navigator.pushNamed(context, CustomerPage.id );},footer: cCustomers, iconToUse: Icons.people_alt_outlined, widgetColor:kPlainBackground.withOpacity(1) ,iconColor:kBlueDarkColor,height: 40,width: double.infinity, fontSize: CommonFunctions().calculateFontSize(context),),
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
