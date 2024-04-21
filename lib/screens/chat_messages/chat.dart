

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/user_constants.dart';
import 'package:stylestore/controllers/responsive/responsive_page.dart';
import 'package:stylestore/screens/store_pages/store_page.dart';
import 'package:stylestore/screens/store_pages/store_page_web.dart';
import 'package:stylestore/screens/transactions_pages/unpaid_transactions_page.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../model/common_functions.dart';
import '../MobileMoneyPages/make_custom_mobile_money_payment.dart';

// import 'delivery_page.dart';



class ChatPage extends StatefulWidget {
  static String id = 'chat_page';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // final dateNow = new DateTime.now();
  late int price = 0;
  bool tutorialDone = true;
  late int quantity = 1;
  var formatter = NumberFormat('#,###,000');
  var userIdentifier = '';
  var description = '';
  var instructions = [];
  var nutritionPoints = [];
  double circularValue = 0;
  var name = '';
  var token = '';
  var question = '';
  String initialId = 'feature';
  String storeId = '';
  Random random = Random();
  bool updateMe = true;
  bool isAfrican = true;
  final TextEditingController _textFieldController = TextEditingController();



  String removeFirstCharacter(String str) {
    if (str.length > 1) {
      String result = str.substring(1);
      return result;
    } else {
      print('Error: String is too short to remove first character.');
      return "";
    }
  }

  void updateArticleCountValues() async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('chat');

    QuerySnapshot querySnapshot = await usersCollection.get();

    // Get current date
    DateTime now = DateTime.now();
    String dateString = '0?' + now.toIso8601String();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Update the articleCountValues field in each document
      await documentSnapshot.reference.update({'winning': false,'pointApplication': false});
    }
  }

  void createDocument() async {
    final userId = 'OYPETtqEedch29E51tikMPbZUKD2';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        "email": "adm3006@gmail.com",
        "firstName": "",
        "lastName": "",
        "loyalty": 1500,
        "loyaltyBefore": 0,
        " challengesActive": [],
        "challenge": false,
        "goal": "",
        "goalSet": false,
        "subscriptionEndDate": DateTime.now(),
        "subscriptionStartDate": DateTime.now(),
        "vision": "",
        "articleCount": 0,
        "articleCountValues": [],
        "aiActive": true,
        "height": 180,
        "weight": 70,
        "sex": "Female",
        "dateOfBirth": DateTime.now(),
        "preferencesId": [],
        "preferences": [],
        "phoneNumber": "",
        "country": "Uganda",
        "countryCode": "",
        "level": "Beginner",
        "token": "userTokenGoesHere",
        "creed": "",
        "trial": "Premium",
        "weekGoal": false,
        "chatPoints": [],
        "progress": [],
        "docId": userId,
        "winning":false,
        "pointApplication": false,
        "tag" :""


      });

      print('Document created successfully!');
    } catch (e) {
      print('Error creating document: $e');
    }
  }




// CALLABLE FUNCTIONS FOR THE NODEJS SERVER (FIREBASE)
  final HttpsCallable callableGoalUpdate = FirebaseFunctions.instance.httpsCallable('updateUserVision');
  CollectionReference trends = FirebaseFirestore.instance.collection('photoUpLoads');


  // Function to check the prompt to use for a particular country
  bool checkArrayForString(List<String> array, String searchString) {
    return array.contains(searchString);
  }




  void searchForPhrase(String text, String docId) async{
    final chatRef = FirebaseFirestore.instance.collection('chat').doc(docId);
    var possibleResponses = ['Wow, you know what $name, am not sure how to respond to that', 'It depends', 'Let me think about that for a moment $name' ];
    final random = Random();
    final randomIndex = random.nextInt(possibleResponses.length);
    final randomWord = possibleResponses[randomIndex];
    if (text.toLowerCase().contains("ai language model") || text.toLowerCase().contains("language model") || text.toLowerCase().contains("computer") ) {
      print("Error detected: $text");
      // randomly generate a value from the array possibleResponses
      await chatRef.update({'response': randomWord});
    }
  }


  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant)!;
    // Map<String, dynamic> jsonMap = json.decode(prefs.getString(kUserVision)!);
    // prompt = jsonMap['category'];
    // userIdentifier =  prefs.getString(kUniqueIdentifier)?? "";
    // name = prefs.getString(kFirstNameConstant)!;
    // token = prefs.getString(kToken)!;
    // isAfrican = isAfricanCountry(prefs.getString(kUserCountryName)!);
    // circularValue = Provider.of<AiProvider>(context, listen: false).dailyProgressPoint;


    // CommonFunctions().userSubscription(context);
    setState(() {
      // updateMe =  Provider.of<BlenditData>(context, listen: false).updateApp;
    });

  }

  // void getLastInformation() async{
  //
  //   if (messageList.length < 4){
  //     lastInformationList.clear();
  //     for (int i = 0; i < messageList.length; i++) {
  //       var userInfo = {"role": "user" , "content": messageList[i]};
  //       var assistantInfo = {"role": "assistant", "content": responseList[i]};
  //       lastInformationList.add(userInfo);
  //       lastInformationList.add(assistantInfo);
  //     }
  //   }else {
  //     lastInformationList.clear();
  //     for (int i = 0; i < 3; i++) {
  //       var userInfo = {"role": "user" , "content": messageList[i]};
  //       var assistantInfo = {"role": "assistant", "content": responseList[i]};
  //       lastInformationList.add(userInfo);
  //       lastInformationList.add(assistantInfo);
  //     }
  //   }
  //   setState(() {
  //
  //   });
  //   uploadData();
  // }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();

  }

  void searchForWordNutriup(String text) {
    if (text.toLowerCase().contains('nutriup')) {
      print('Detected');
    }
  }


  var messageList = [];
  var pointsList = [];
  var messageStatusList = [];
  var lastInformationList = [];
  var chatBubbleVisibility = true;
  var nutriVisibility = true;
  var aiResponseLength = 200;
  var responseList = [];
  var idList = [];
  var dateList = [];
  var statusList = [];
  // var paidStatusListColor = [];
  var message = '';
  // String serviceId = '';
  String serviceId = 'pic${uuid.v1().split("-")[0]}';
  var lastQuestion = '';
  var prompt = '';
  List<double> opacityList = [];
  double textSize = 12.0;
  String fontFamilyMont = 'Montserrat-Medium';
  CollectionReference chat = FirebaseFirestore.instance.collection('chat');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final auth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {


    Positioned LowerTextForm() {
      return Positioned(
        right: 0,
        left: 0,
        bottom: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:

          Row(
            children: [
              Expanded(
                flex:7,
                child: Stack(
                  children: [

                    TextField(
                      controller: _textFieldController,  // _textFieldController is a TextEditingController object
                      maxLines: null,
                      // maxLength: 200,
                      clipBehavior: Clip.antiAlias,
                      // keyboardType: TextInputType.multiline,
                      // minLines: 2,
                      // expands: true,

                      decoration: InputDecoration(
                        hintText: "...lets talk",
                        fillColor: kPureWhiteColor,
                        filled: true,

                        iconColor: kPureWhiteColor,
                        border:
                        //InputBorder.none,
                        OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        // shadowColor: Colors.green,
                        // shadowRadius: 5,
                        // shadowOffset: Offset(0, 2),
                      ),

                      // Clear the text field when the user submits the text
                      onSubmitted: (value) async {




                        message = value;
                        final prefs = await SharedPreferences.getInstance();

                        if (message != '') {
                          // increaseValueAndUploadToFirestore();
                          lastQuestion = message;
                          serviceId = '${DateTime.now().toString()}${uuid.v1().split("-")[0]}';
                          print(message.length);
                          if (message.length > 20) {
                            print(" HUHUHUHUH $message : ${message.length}");
                            aiResponseLength = 200;
                          } else {
                            print(" HUHUHUHUH $message : ${message.length}");
                            print("$message : ${message.length}");
                            aiResponseLength = 200;

                          }
                          // uploadData();
                          _textFieldController.clear();
                        }


                      },
                      onChanged: (value) {

                        message = value;
                        // Store the text input in a variable
                        // _inputText = value;
                      },
                    ),
                    Positioned(
                      right: 2,
                      // bottom: 2,
                      top: 5,
                      child:
                      IconButton(

                          onPressed: () async {


                            final prefs = await SharedPreferences.getInstance();
                            DateTime subscriptionDate = DateTime.now();
                            DateTime today = DateTime.now();

                            print(subscriptionDate);
                            if (subscriptionDate.isAfter(today)){

                            } else {


                            }
                          }, icon: Icon(Icons.send)
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      );
    }



    return GestureDetector(
      onTap: () {

        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
          AppBar(
            automaticallyImplyLeading: true,
            foregroundColor: kPureWhiteColor,
            backgroundColor:Colors.transparent,

            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 35,
                    child: InkWell(

                      child: ClipOval(


                          child:
                          isAfrican == true ? Image.asset('images/pilot2.png', fit: BoxFit.contain,):
                          Image.asset('images/nutritionist.jpg', fit: BoxFit.contain,)
                      ),
                    )),
                // kSmallWidthSpacing,


                Text('Captain', style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.w900),),
              ],
            ),
            centerTitle: true,
            actions: [


            ],
          ),


          body:

          GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.87,

                child: Stack(

                    children: [

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                        StreamBuilder<QuerySnapshot> (
                            stream: FirebaseFirestore.instance
                                .collection('chat')
                                .where('userId', isEqualTo: storeId)
                                .orderBy('time',descending: true)
                                .snapshots(),
                            builder: (context, snapshot)
                            {
                              if(!snapshot.hasData){

                                return Container();
                              }
                              else{
                                messageList = [];
                                messageStatusList = [];
                                responseList = [];
                                idList = [];
                                dateList = [];
                                statusList = [];
                                opacityList = [];

                                var orders = snapshot.data?.docs;
                                for( var doc in orders!){
                                  messageList.add(doc['message']);
                                  responseList.add(doc['response']);
                                  idList.add(doc['id']);
                                  messageStatusList.add(doc['status']);
                                  dateList.add(doc['time'].toDate());
                                  // searchForPhrase(doc['response'], doc['id']);

                                  if (doc['replied'] == true){
                                    statusList.add(Icon(LineIcons.doubleCheck, size: 15,color: kGreenThemeColor,));
                                    // paidStatusListColor.add(Colors.blue);
                                    opacityList.add(0.0);

                                  } else {
                                    statusList.add(Icon(LineIcons.check, size: 15,color: kFaintGrey,));
                                    // paidStatusListColor.add(Colors.grey);
                                    opacityList.add(1.0);
                                  }
                                  // print(responseList.last);


                                }
                                // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
                                return

                                  messageList.length == 0?Container(child: Center(child: Text("No Messages from Captain",style: kNormalTextStyle.copyWith(color: kPureWhiteColor), ),),):Padding(
                                    padding: const EdgeInsets.only(bottom: 110.0),
                                    child:  ListView.builder(
                                        itemCount: messageList.length,
                                        reverse: true,
                                        itemBuilder: (context, index){
                                          return
                                            Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child:
                                                  // manualList[index] == true? Container():
                                                  Card(

                                                    // margin: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                                                    color: kCustomColor,
                                                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                                                    shadowColor: kFaintGrey,
                                                    // color: kBeigeColor,
                                                    elevation: 2.0,
                                                    child: messageList[index] == ''?Container():Container(
                                                      width: 260,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text( '${DateFormat('EE, dd - HH:mm').format(dateList[index])}',textAlign: TextAlign.left,
                                                                    style: kNormalTextStyle.copyWith(fontSize: 10, color: kFaintGrey)
                                                                ),
                                                                kSmallWidthSpacing,
                                                                statusList[index]
                                                              ],
                                                            ),
                                                            Text( "${messageList[index]}",textAlign: TextAlign.left,
                                                                style: kNormalTextStyle.copyWith(fontSize: 15, color: kBlueDarkColor)
                                                            ),
                                                            kSmallHeightSpacing,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                kSmallHeightSpacing,
                                                // Lottie.asset('images/assistant.json',
                                                responseList[index] == ''?
                                                Align(
                                                    alignment:  Alignment.centerLeft,
                                                    child: Lottie.asset('images/incoming.json', width: 90))
                                                    :Align(alignment: Alignment.centerLeft, child: Row( children: [
                                                      Stack(
                                                    children: [
                                                      GestureDetector(
                                                        onLongPress: (){
                                                          Share.share('${responseList[index]}\n', subject: 'Check this out from BusinessPilot');
                                                        },
                                                        child: Card(
                                                            color:
                                                            // manualList[index] == false ?
                                                            // kPureWhiteColor:
                                                            kPureWhiteColor,
                                                            shadowColor: kPureWhiteColor,

                                                            elevation: 4,
                                                            shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20), bottomRight: Radius.circular(20))),


                                                            child: Padding(
                                                              padding: const EdgeInsets.all(18.0),
                                                              child: Container(
                                                                  width: 260,
                                                                  child: Column(
                                                                    crossAxisAlignment:CrossAxisAlignment.start ,

                                                                    children: [

                                                                      Text( '${DateFormat('EE, dd, MMM - HH:mm').format(dateList[index])}',textAlign: TextAlign.left,
                                                                          style: kNormalTextStyle.copyWith(fontSize: 10, color:  kBlueDarkColor,)
                                                                      ),
                                                                      // Linkify enables links to be clickable in the text
                                                                      Linkify(
                                                                          onOpen: (link) {
                                                                            // CommonFunctions().goToLink(link.url);
                                                                          },
                                                                          style: kNormalTextStyle.copyWith(color:kBlueDarkColor,
                                                                              fontSize: 15, fontWeight: FontWeight.w400),
                                                                          linkStyle: TextStyle(color: Colors.blue),
                                                                          text: responseList[index]),
                                                                      messageStatusList[index] =="receivables"?
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 10.0),
                                                                        child: Row(
                                                                          children: [
                                                                            kLargeHeightSpacing,
                                                                            TextButton(
                                                                                style: TextButton.styleFrom(
                                                                                  backgroundColor: kAppPinkColor,
                                                                                  foregroundColor: Colors.white, // White text on blue background
                                                                                ),
                                                                                onPressed: (){
                                                                                  // Navigator.pop(context);

                                                                                  showDialog(context: context, builder: (BuildContext context){
                                                                                    return
                                                                                      GestureDetector(
                                                                                          onTap: (){
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Scaffold(
                                                                                              appBar: AppBar(

                                                                                              ),
                                                                                              body: UnpaidTransactionsPage()));
                                                                                  });
                                                                                }, child: Text("View Clients")),
                                                                            kSmallWidthSpacing,
                                                                            TextButton(
                                                                                style: TextButton.styleFrom(
                                                                                  backgroundColor: kBlack,
                                                                                  foregroundColor: Colors.white, // White text on blue background
                                                                                ),
                                                                                onPressed: (){
                                                                                  // Navigator.pop(context);
                                                                                  print(CommonFunctions().extractNames(responseList[index]));
                                                                                  CommonFunctions().showDebtorsDialog(context,CommonFunctions().createChecklist(CommonFunctions().extractNames(responseList[index])));


                                                                                }, child: Text("Send Reminders")),
                                                                          ],
                                                                        ),
                                                                      ):
                                                                      messageStatusList[index] =="stock"?
                                                                      Column(
                                                                        children: [
                                                                          kLargeHeightSpacing,
                                                                          TextButton(
                                                                              style: TextButton.styleFrom(
                                                                                backgroundColor: kCustomColor,
                                                                                foregroundColor: kBlack, // White text on blue background
                                                                              ),
                                                                              onPressed: (){
                                                                                // Navigator.pop(context);

                                                                                showDialog(context: context, builder: (BuildContext context){
                                                                                  return
                                                                                    GestureDetector(
                                                                                        onTap: (){
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Scaffold(
                                                                                            appBar: AppBar(

                                                                                            ),
                                                                                            body: SuperResponsiveLayout(mobileBody: StorePageMobile(), desktopBody: StorePageWeb())));
                                                                                });
                                                                              }, child: Text("See Stock")),
                                                                        ],
                                                                      ):
                                                                      Container()

                                                                    ],
                                                                  )
                                                              ),
                                                            )),
                                                      ),
                                                      Positioned(
                                                        top: 10,
                                                        right: 10,
                                                        child: Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                            color: kBlack,
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: GestureDetector(
                                                              onTap: (){

                                                                Share.share('${responseList[index]}\nhttps://bit.ly/3I8sa4M', subject: 'Check this out from Nutri');

                                                              },

                                                              child: Icon(LineIcons.alternateShare, size: 15,color: kPureWhiteColor,)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  // instructions[index]!= null? Lottie.asset("images/cook.json", height: 30, width: 30): Container()

                                                ],
                                                ),
                                                )
                                              ],
                                            );}
                                    ),
                                  );
                              }

                            }

                        ),
                      ),

                      // LowerTextForm(),

                      Positioned(
                          bottom: 160,
                          right: 10,

                          child:

                          GestureDetector(
                              onTap: (){
                                setState(() {
                                  chatBubbleVisibility = !chatBubbleVisibility;
                                });
                              },


                              child:
                              nutriVisibility == true? Container():
                              Lottie.asset('images/lisa.json', height: 100, width: 100,))
                      ),


                    ]),
              ),
            ),
          )
      ),
    );
  }


}



