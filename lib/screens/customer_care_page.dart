
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../Utilities/constants/color_constants.dart';
import '../Utilities/constants/font_constants.dart';
import '../Utilities/constants/user_constants.dart';
import 'MobileMoneyPages/mobile_money_page.dart';
import 'delivery_page.dart';



class CustomerCarePage extends StatefulWidget {
  static String id = 'coach_page';

  @override
  _CustomerCarePageState createState() => _CustomerCarePageState();
}

class _CustomerCarePageState extends State<CustomerCarePage> {
  // final dateNow = new DateTime.now();
  late int price = 0;
  bool tutorialDone = true;
  late int quantity = 1;
  var formatter = NumberFormat('#,###,000');
  var userIdentifier = '';
  var email = '';
  var description = '';
  var instructions = [];
  var nutritionPoints = [];
  var name = '';
  var token = '';
  var question = '';
  var documentId = '';
  String initialId = 'feature';
  Random random = Random();
  List<String> coachNames = ['John', 'Emily', 'David', 'Sarah', 'Michael', 'Jessica', 'Matthew', 'Olivia', 'Daniel', 'Sophia', 'Christopher', 'Ava', 'Andrew', 'Emma', 'James', 'Isabella', 'William', 'Mia', 'Benjamin', 'Charlotte',];
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textFieldController = TextEditingController();


  // Future<void> vibrateDevice() async {
  //   // Check if the device can vibrate
  //   if (await Vibrate.canVibrate) {
  //     // Vibrate the device for a certain duration
  //     Vibrate.vibrate();
  //   }
  // }







  Future<void> uploadData() async {
    var finalQuestion = lastQuestion;
    final prefs = await SharedPreferences.getInstance();

    return chat.doc(serviceId)
        .set({
      'viewed': false,

      'date':  DateTime.now(),
      'message': message,
      'documentId': documentId,

      'receiver': 'customerCare',
      'senderUid': email,
      'sender': prefs.getString(kToken),
      'token': prefs.getString(kToken),
      'id':serviceId,

    })
        .then((value){


    } )
        .catchError((error) => print(error));
  }



  void defaultInitialization()async{
    final prefs = await SharedPreferences.getInstance();
    userIdentifier =  prefs.getString(kStoreIdConstant)?? "";
    documentId = prefs.getString(kToken)?? "";
    name = prefs.getString(kBusinessNameConstant)!;
    token = prefs.getString(kToken)!;
    email = prefs.getString(kStoreIdConstant)!;



    setState(() {

    });

  }



  @override
  void dispose() {
    _textFieldController.dispose();
    // _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();

    // advancedStatusCheck(newVersion);

  }





  List messageList = [];
  var messageStatusList = [];
  var lastInformationList = [];
  var chatBubbleVisibility = true;
  var nutriVisibility = true;
  var aiResponseLength = 200;
  var responseList = [];
  var manualList = [];
  var photoList = [];
  var photoImage = [];
  var manualListText = [];
  var idList = [];
  var dateList = [];
  var statusList = [];
  var paidStatusListColor = [];
  var message = '';
  String serviceId = 'iosMessage${uuid.v1().split("-")[0]}';
  var lastQuestion = '';
  List<double> opacityList = [];
  double textSize = 12.0;
  String fontFamilyMont = 'Montserrat-Medium';
  CollectionReference chat = FirebaseFirestore.instance.collection('customerCare');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final auth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    final random = Random();
    final randomCoach = coachNames[random.nextInt(coachNames.length)];


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
                      decoration: InputDecoration(
                        hintText: "...",
                        fillColor: kPureWhiteColor,
                        filled: true,

                        iconColor: kPureWhiteColor,
                        border:
                        //InputBorder.none,
                        OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),

                      // Clear the text field when the user submits the text
                      onSubmitted: (value) async {

                        message = value;
                        final prefs = await SharedPreferences.getInstance();

                        if (message != '') {

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
                          // Provider.of<BlenditData>(context, listen: false).changeLastQuestion(lastQuestion);
                          uploadData();
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
                      child: IconButton(

                          onPressed: () async {
                            // vibrateDevice();
                            final prefs = await SharedPreferences.getInstance();


                            if (message != '') {
                              lastQuestion = message;
                              serviceId = '${DateTime.now().toString()}${uuid.v1().split("-")[0]}';
                              uploadData();
                              _textFieldController.clear();
                            }

                          }, icon:  const Icon(Icons.send, color: kGreenThemeColor,)
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
          backgroundColor:
          // kBlack
          kBlueDarkColor
          // kGreyLightThemeColor
          ,
          // appBar: AppBar(
          //   automaticallyImplyLeading: true,
          //   backgroundColor: kBackgroundGreyColor,
          //   foregroundColor: kPureWhiteColor,
          //
          //   title: Text("Customer Care", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),
          //   centerTitle: true,
          //
          // ),

          body:

          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 20, left: 10, right: 10),
            child: Stack(

                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                    StreamBuilder<QuerySnapshot> (
                        stream: FirebaseFirestore.instance
                            .collection('customerCare')
                        // .where('sender', isEqualTo: userIdentifier)
                            .where('documentId', isEqualTo: userIdentifier)
                            .orderBy('date',descending: true)
                            .snapshots(),
                        builder: (context, snapshot)
                        {
                          if(!snapshot.hasData){
                            return Container();
                          }
                          else{
                            // THIS CODE EMPTIES ALL ARRAYS AND PICKS NEW DATA
                            print("MY GOODNESS THE senderId is : $userIdentifier");
                            messageList = [];
                            messageStatusList = [];
                            responseList = [];
                            idList = [];
                            dateList = [];
                            statusList = [];
                            paidStatusListColor = [];
                            opacityList = [];



                            // PICKING NEW DATA
                            var messagesFromChat = snapshot.data?.docs;
                            for( var doc in messagesFromChat!){
                              messageList.add(doc['message']);
                              dateList.add(doc['date'].toDate());
                              responseList.add(doc['sender']);

                            }
                            // return Text('Let us understand this ${deliveryTime[3]} ', style: TextStyle(color: Colors.white, fontSize: 25),);
                            return  messageList.length == 0 ? Padding(padding: const EdgeInsets.all(20),
                              child:
                              Center(child: Text("No Messages")),) :
                            Padding(
                              padding: const EdgeInsets.only(bottom: 110.0),
                              child:  ListView.builder(
                                  itemCount: messageList.length,
                                  reverse: true,
                                  itemBuilder: (context, index){
                                    return Column(
                                        children: [
                                          responseList[index]== userIdentifier? Align(
                                            alignment: Alignment.centerRight,
                                            child:
                                            Card(

                                              // margin: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                                              shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                                              shadowColor: kFontGreyColor,
                                              color: kCustomColor,
                                              elevation: 2.0,
                                              child: Container(
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
                                                          // statusList[index]
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
                                          ): Align(
                                            alignment: Alignment.centerLeft,
                                            child:
                                            Card(

                                              // margin: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                                              shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                                              shadowColor: kGreenThemeColor,
                                              // color: kBeigeColor,
                                              elevation: 2.0,
                                              child: Container(
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
                                                          // statusList[index]
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
                                        ]);


                                  }
                              ),
                            );
                          }

                        }

                    ),
                  ),

                  LowerTextForm(),
                  Positioned(
                    top: 50,
                      left: 30,
                      child: GestureDetector(

                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: kAppPinkColor,),
                              // kMediumWidthSpacing,
                              // kMediumWidthSpacing,
                              // kMediumWidthSpacing,
                              kMediumWidthSpacing,
                              Container(
                                // width: 200,
                                  decoration: BoxDecoration(

                                    color: kAppPinkColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.all( Radius.circular(20))

                                  ),
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text("Customer Care",  style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontWeight: FontWeight.bold, shadows: [Shadow(color: kBlack, blurRadius: 2 )]),),
                                    kSmallWidthSpacing,
                                    Lottie.asset('images/live.json', height: 20,  fit: BoxFit.contain ),
                                    // Icon(Icons.online_prediction, color: kPureWhiteColor,)
                                  ],
                                ),
                              ))
                            ],
                          )))




                ]),
          )
      ),
    );
  }


}



