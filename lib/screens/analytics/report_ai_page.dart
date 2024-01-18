import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../utilities/gliding_text.dart';




class ReportAiPage extends StatefulWidget {
  //  static String id = 'success_challenge_new';

  @override
  _ReportAiPageState createState() => _ReportAiPageState();
}

class _ReportAiPageState extends State<ReportAiPage> {



  late Timer _timer;
  var goalSet= "";
  var countryName = '';
  var countrySelected = false;
  var initialCountry = "";
  var countryFlag = '';
  var countryCode = "+256";
  var name = "";
  var random = Random();
  var inspiration = "Welcome to Nutri, Our goal is to help you achieve your nutrition and health goals, Anywhere you go. Let me set you up";
 // var message  = ['Well done', 'Keep Going', 'Your doing Great', 'You are killing this Challenge', 'Keep Going', 'Your a Champion', 'Standing Ovation👏', 'Keep going', 'You are winning'];
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  var userId = "";
  var modifiedValues = [];

  void defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();

  }


  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    _startTyping();
    animationTimer();
  }
  double opacityValue = 0.0;
  final String _text = 'Hello World';


  void _startTyping() {
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      // setState(() {
      //
      // });
    });
  }

  final _random = new Random();
  animationTimer() async{
    final prefs = await SharedPreferences.getInstance();
    _timer = Timer(const Duration(milliseconds: 3000), () {

      opacityValue = 1.0;
      setState(() {


      });


    });
  }

  Widget build(BuildContext context) {
    // var aiData = Provider.of<AiProvider>(context, listen: false);
    // var aiDataDisplay = Provider.of<AiProvider>(context);


    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medics')
            .doc("qaYX1FNd7yMkyJVyRe92t6hoqF93")
            //.doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print("EEEEERRRRRRRROOOOOORRR");
          }
          // return Container(child: Text("Nice",style: kHeading2TextStyleBold,),);
          String jsonString = '{"goal": "","vision": "","difficulty": "","target": "","action": [],"category": "","question": "","motivation": "","unit": ""}';

          // Access the vision field from the snapshot
          final analysis = snapshot.data?['analysis'] ?? jsonString;

          // Parse the vision JSON string
          final analysisData = jsonDecode(analysis);
          print(analysisData);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text("Marketing Strategy",  style: kNormalTextStyle.copyWith(color: kAppPinkColor),),
                    kLargeHeightSpacing,
                    Text(analysisData['advice'] ?? "", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)
                    // Card(
                    //   color: kCustomColor,
                    //   shape: const RoundedRectangleBorder(borderRadius:BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(20))),
                    //   // shadowColor: kGreenThemeColor,
                    //   // color: kBeigeColor,
                    //   elevation: 1.0,
                    //
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Container(
                    //         width: 260,
                    //         child: Text(analysisData['advice'] ?? "")
                    //         // Center(child:
                    //         // GlidingText(
                    //         //   text: analysisData['advice'],
                    //         //   delay: const Duration(seconds: 1),
                    //         // ),
                    //         //
                    //         // )
                    //     ),
                    //   ),
                    // ),

                    // Stack(
                    //   children: [
                    //     Lottie.asset('images/target.json', height: 180, width: 300, fit: BoxFit.contain ),
                    //     Positioned(
                    //         bottom: 55,
                    //         right: 0,
                    //         child: Container(
                    //             decoration: BoxDecoration(
                    //               color: kAppPinkColor,
                    //               borderRadius: BorderRadius.circular(20)
                    //             ),
                    //             child: Padding(
                    //           padding: const EdgeInsets.all(8.0),
                    //           child: Text(analysisData['target'], style: kNormalTextStyle.copyWith(color: kPureWhiteColor, fontSize: 10),),
                    //         )))
                    //   ],
                    // ),
                    // const Text("Select Any 2 Activities to Focus\nOn This Week",textAlign: TextAlign.center, style: kHeading2TextStyleBold,),
                    // kLargeHeightSpacing

                  ],
                ),
                // Container(
                //   height: 290,
                //   // width: 200,
                //   child: ListView.builder(
                //     itemCount: analysisData['action'].length,
                //     itemBuilder: (
                //         BuildContext context, int index)
                //     {
                //       return Container();
                //     },
                //   ),
                // ),

                // Padding(
                //   padding: const EdgeInsets.only(left: 50.0, right: 50),
                //   child: ElevatedButton(
                //       style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(aiDataDisplay.targetsContinueColor)),
                //       onPressed: ()async {
                //         if(aiDataDisplay.targetsContinueColor == kGreenThemeColor) {
                //           final prefs = await SharedPreferences.getInstance();
                //          print(aiDataDisplay.preferencesSelected);
                //          updateTasks();
                //           prefs.setString(kUserVision, vision);
                //
                //
                //
                //         } else {
                //           showDialog(context: context, builder: (BuildContext context){
                //             return
                //               CupertinoAlertDialog(
                //                 title: const Text('SELECT 2 TARGETS'),
                //                 content: Text("Please select 2 targets", style: kNormalTextStyle.copyWith(color: kBlack),),
                //                 actions: [CupertinoDialogAction(isDestructiveAction: true,
                //                     onPressed: (){
                //                       // _btnController.reset();
                //                       Navigator.pop(context);
                //                     },
                //                     child: const Text('Cancel'))],
                //               );
                //           });
                //         }
                //
                //
                //       }, child: Text("Continue", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
