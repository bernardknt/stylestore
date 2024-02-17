import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/screens/analytics/analysis_page.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../utilities/constants/user_constants.dart';
import '../home_pages/home_page_mobile.dart';


class LoadingAnalysisPage extends StatefulWidget {
   static String id = 'data_challenge_new';

  @override
  _LoadingAnalysisPageState createState() => _LoadingAnalysisPageState();
}

class _LoadingAnalysisPageState extends State<LoadingAnalysisPage> {



  late Timer _timer;
  var random = Random();
  // var inspiration = "Success is a journey shared with those who lift you HIGHER. With Support, Accountability and the right Challenge, every step is a VICTORY in the making.";
  //var inspiration = "In God we trust, but the rest of us need to bring data";
  var inspiration = "Without data you're just another person with an opinion.\n~Edwards Deming~";
  var message  = ['Well done', 'Keep Going', 'Your doing Great', 'You are killing this Challenge', 'Keep Going', 'Your a Champion', 'Standing Ovation👏', 'Keep going', 'You are winning'];
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  bool newUser = false;

  defaultInitialization() async{
    final prefs = await SharedPreferences.getInstance();
    newUser = prefs.getBool(kStartAnayltics) ?? false;
    setState(() {

    });


  }
  Future<Object?> getUserAge(String uid) async {

    final prefs = await SharedPreferences.getInstance();

    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    // prefs.setString(kUserVision, userDoc["vision"]);
    final userData = userDoc.data();

    return userData;
  }
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
    _startTyping();
    animationTimer();
  }
  String _displayText = '';
  int _characterIndex = 0;
  double opacityValue = 0.0;
  final String _text = 'Hello World';

  void _startTyping() {
    Timer.periodic(Duration(milliseconds: 80), (timer) {
      setState(() {
        if (_characterIndex < inspiration.length) {
          _displayText += inspiration[_characterIndex];
          _characterIndex++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  final _random = new Random();
  animationTimer() async{
    final prefs = await SharedPreferences.getInstance();
    // final player = AudioCache();
    // player.play("transition.wav");
    _timer = Timer(const Duration(milliseconds: 6000), () {
      // prefs.setBool(kChallengeActivated, true);


      // Navigator.pop(context);
      opacityValue = 1.0;
      setState(() {



      });


    });
  }

  Widget build(BuildContext context) {
    // var points = Provider.of<BlenditData>(context, listen: false).rewardPoints ;

    return Scaffold(
      backgroundColor: kPureWhiteColor,
      body: Container(

        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Lottie.asset('images/data.json', height: 300, width: 300, fit: BoxFit.contain ),
            kSmallHeightSpacing,
            Center(child: Text(_displayText ,textAlign: TextAlign.center, style: kHeading2TextStyleBold.copyWith(fontSize: 18, color: kBlack),)),
            kLargeHeightSpacing,
            Opacity(
              opacity: opacityValue,
              child: ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kAppPinkColor)),
                  onPressed: ()async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool(kStartAnayltics, true);
                    // Provider.of<AiProvider>(context, listen: false).resetQuestionButtonColors();
                    Navigator.pop(context);

                  }, child: newUser==false ? Text("Let's Go", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),):
              Text("View Report", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),)),
            )


          ],
        ),
      ),
    );
  }
}
