

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/employee_pages/biodata_page_1.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';

import '../../Utilities/constants/font_constants.dart';
import '../../utilities/constants/word_constants.dart';
import '../sign_in_options/signup_pages/signup_web.dart';
import 'onboarding_business_setup.dart';
import 'onboarding_complete.dart';
import 'onboarding_employee.dart';

class OnboardingStepper extends StatefulWidget {
  static String id = "onboarding_data_stepper";
  @override
  _OnboardingStepperState createState() => _OnboardingStepperState();
}

class _OnboardingStepperState extends State<OnboardingStepper> {
  int currentStep = 0;
  late List <Step> stepsData;
  int activeStep = 0;
  int activeStep2 = 0;
  int reachedStep = 0;
  int upperBound = 5;
  double progress = 0.1;
  Set<int> reachedSteps = <int>{0, 2, 4, 5};
  List<String> message = [
    "Welcome to Business Pilot",
    "Add Business Details",
    "Your Employment",
    "Finish",
  ];
  List<Widget> display = [
    WelcomeToBusinessPilot(),
    // OnboardingBusiness(),
    Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          width: 500,
          height: 600,
          child: OnboardingBusiness()),
    ),
    Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          width: 500,
          height: 600,
          child: OnboardingEmployee()),
    ),
    OnboardingSuccessPage(),


  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // defaultInitialization();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundGreyColor,
      appBar: AppBar(
        backgroundColor: kBackgroundGreyColor,
        elevation: 0,
        title: Text(message[ Provider.of<StyleProvider>(context, listen: true).onboardingIndex], style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(

            color: kBackgroundGreyColor,

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 700 : MediaQuery.of(context).size.width * 1,
                child: Card(
                  elevation: 10,
                  color: kPureWhiteColor,
                  child:
                  Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: EasyStepper(
                          activeStep: Provider.of<StyleProvider>(context, listen: true).onboardingIndex,
                          direction: Axis.horizontal,
                          activeStepBorderColor: kAppPinkColor,
                          finishedStepBackgroundColor: kBlueDarkColor,
                          // activeStepBackgroundColor: kAppPinkColor,
                          lineStyle: LineStyle(
                            lineLength: 100,
                            lineThickness: 6,
                            lineSpace: 4,
                            lineType: LineType.normal,
                            defaultLineColor: kAppPinkColor,
                            finishedLineColor: kBlueDarkColor,


                            progress: progress,
                            progressColor: kBlueDarkColor,
                          ),
                          borderThickness: 10,
                          defaultStepBorderType: BorderType.normal,
                          internalPadding: 15,
                          loadingAnimation: 'images/notificationIcon.json',
                          steps:   [
                            EasyStep(
                              // icon: Icon(CupertinoIcons.cart),
                              customStep: Image.asset("images/pilot2.png",height: 30, fit: BoxFit.fitHeight,),
                              title: 'Welcome',
                              lineText: 'Setup Business',
                            ),
                            EasyStep(
                              icon: Icon(kIconStore),
                              title: 'Business Setup',
                              lineText: 'Position Details',
                            ),
                            EasyStep(
                              icon: Icon(CupertinoIcons.person_add),
                              title: 'Add Employee',
                              lineText: 'Get Started',
                            ),
                            EasyStep(
                              icon: Icon(CupertinoIcons.flag),
                              title: 'Finish',
                              // lineText: 'Confirm Order Items',
                            ),
                            // EasyStep(
                            //   icon: Icon(Icons.file_present_rounded),
                            //   title: 'Order Details',
                            //   lineText: 'Submit Order',
                            // ),
                            // EasyStep(
                            //   icon: Icon(Icons.check_circle_outline),
                            //   title: 'Finish',
                            // ),
                          ],
                         onStepReached: (index) => setState(() =>
                         Provider.of<StyleProvider>(context, listen: false).setOnboardingIndex(index)
                        ),
                        ),
                      ),
                        Expanded(
                            flex: 4,
                            child:display[ Provider.of<StyleProvider>(context, listen: true).onboardingIndex]

                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeToBusinessPilot extends StatefulWidget {
  const WelcomeToBusinessPilot({
    super.key,
  });

  @override
  State<WelcomeToBusinessPilot> createState() => _WelcomeToBusinessPilotState();
}

class _WelcomeToBusinessPilotState extends State<WelcomeToBusinessPilot> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kLargeHeightSpacing,
        Text('Welcome Aboard',style: kHeading2TextStyle.copyWith(color:  kBlack, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize:20),),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(cWelcomeOnboard,
            softWrap: true,
            // maxLines: null,
            textAlign: TextAlign.left,
            style: kNormalTextStyle.copyWith(color:  kBlack,),),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset("images/pilot2.png",height: 30, fit: BoxFit.fitHeight,),
              // kMediumWidthSpacing,
              Image.asset("images/signature.png",height: 30, fit: BoxFit.fitHeight,)

            ],
          ),
        ),
        kLargeHeightSpacing,
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: CommonFunctions().convertToMaterialStateProperty(kAppPinkColor)
          ),
          onPressed: (){
            // setState(() => activeStep = index);
            setState(() {
              Provider.of<StyleProvider>(context, listen: false).setOnboardingIndex(1);
            });

          },
            child: Text("Go to Business Setup", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),



        )
      ],
    );
  }
}
