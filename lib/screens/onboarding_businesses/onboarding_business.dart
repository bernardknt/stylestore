

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/screens/employee_pages/biodata_page_1.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';

import '../../Utilities/constants/font_constants.dart';
import '../../utilities/constants/word_constants.dart';
import '../sign_in_options/signup_pages/signup_web.dart';
import 'onboarding_business_setup.dart';

class OnboardingStepper extends StatefulWidget {
  static String id = "onboarding_data";
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
  List display = [
    WelcomeToBusinessPilot(),
    // OnboardingBusiness(),
    Padding(
      padding: const EdgeInsets.only(left: 18.0),
      child: Container(
          width: 500,
          height: 600,
          child: Expanded(child: OnboardingBusiness())),
    ),
    Container(color: kCustomColor, height: 300, width: 300,),
    Container(color: kGreenThemeColor, height: 300, width: 300,),
    Container(color: kRedColor, height: 300, width: 300,),
    Container(color: kRedColor, height: 300, width: 300,),

  ];



  // defaultInitialization(){
  //   stepsData = [
  //     Step(
  //
  //       title: Text("Welcome", style: kNormalTextStyle.copyWith(color: kBlack),),
  //
  //       // subtitle: Text("Onboarding"),
  //       content: Container(
  //         // elevation: 2,
  //         decoration: BoxDecoration(
  //             color: kBackgroundGreyColor,
  //             borderRadius: BorderRadius.circular(20)
  //
  //         ),
  //         child:
  //         Column(
  //           children: [
  //             kLargeHeightSpacing,
  //             Text('Welcome Fruts Express',style: kHeading2TextStyle.copyWith(color:  kBlack, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize:16),),
  //             Padding(
  //               padding: const EdgeInsets.all(12.0),
  //               child: Text(cWelcomeOnboard,
  //                 softWrap: true,
  //                 // maxLines: null,
  //                 textAlign: TextAlign.left,
  //                 style: kNormalTextStyle.copyWith(color:  kBlack,),),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Row(
  //                 children: [
  //                   Image.asset("images/pilot2.png",height: 30, fit: BoxFit.fitHeight,),
  //                   // kMediumWidthSpacing,
  //                   Image.asset("images/signature.png",height: 30, fit: BoxFit.fitHeight,)
  //
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       isActive: currentStep >= 0,
  //     ),
  //     Step(
  //
  //       title: Text("Business Details", style: kNormalTextStyle.copyWith(color: kBlack),),
  //       content: Container(
  //         child: Column(
  //           children: [
  //             Text('It Starts Here.',style: kHeading2TextStyle.copyWith(color:  kBlack, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize: 20),),
  //             Text("Business Starts with a de",style: kNormalTextStyle.copyWith(color:  kBlack),),
  //             // Categories(categoriesNumber: categories.length, categories: categories, pageName:[rulesFunction, planFunction,dateFunction ],)
  //
  //           ],
  //         ),
  //       ),
  //       isActive: currentStep >= 0,
  //     ),
  //     Step(
  //
  //       title: Text("Owner Details", style: kNormalTextStyle.copyWith(color: kBlack),),
  //       content: Container(
  //         child: Column(
  //           children: [
  //             Text('It Starts Here.',style: kHeading2TextStyle.copyWith(color:  kBlack, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize: 20),),
  //             Text("Business Starts with a de",style: kNormalTextStyle.copyWith(color:  kBlack),),
  //             // Categories(categoriesNumber: categories.length, categories: categories, pageName:[rulesFunction, planFunction,dateFunction ],)
  //
  //           ],
  //         ),
  //       ),
  //       isActive: currentStep >= 0,
  //     ),
  //   ];
  //   setState(() {
  //
  //   });
  // }


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
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(

          color: kBackgroundGreyColor,

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 700 : MediaQuery.of(context).size.width * 1,
                child: Card(
                  elevation: 10,
                  color: kPureWhiteColor,
                  child:
                  Column(

                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EasyStepper(
                        activeStep: activeStep,
                        direction: Axis.horizontal,
                        lineStyle: LineStyle(
                          lineLength: 100,
                          lineThickness: 6,
                          lineSpace: 4,
                          lineType: LineType.normal,
                          defaultLineColor: kAppPinkColor,
                          finishedLineColor: kBlueDarkColor,

                          progress: progress,
                          // progressColor: Colors.purple.shade700,
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
                            // lineText: 'Frutsexpress',
                          ),
                          EasyStep(
                            icon: Icon(kIconStore),
                            title: 'Business Setup',
                            lineText: 'Setup Business',
                          ),
                          EasyStep(
                            icon: Icon(CupertinoIcons.person_add),
                            title: 'Add Employee',
                            lineText: 'Choose Payment Method',
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
                       onStepReached: (index) => setState(() => activeStep = index),
                      ),
                      display[activeStep]
                    ],
                  ),
                  // EasyStepper(
                  //   activeStep: activeStep,
                  //   // lineLength: 50,
                  //   stepShape: StepShape.circle,
                  //   stepBorderRadius: 15,
                  //   borderThickness: 2,
                  //   // padding: 20,
                  //   stepRadius: 28,
                  //   finishedStepBorderColor: Colors.deepOrange,
                  //   finishedStepTextColor: Colors.deepOrange,
                  //   finishedStepBackgroundColor: kCustomColor,
                  //   activeStepIconColor: Colors.deepOrange,
                  //   showLoadingAnimation: false,
                  //   steps: [
                  //     EasyStep(
                  //       customStep: ClipRRect(
                  //         borderRadius: BorderRadius.circular(15),
                  //         child: Opacity(
                  //           opacity: activeStep >= 0 ? 1 : 0.3,
                  //           child: Image.asset('images/pilot2.png', fit: BoxFit.fill,),
                  //         ),
                  //       ),
                  //       customTitle: const Text(
                  //         'Welcome',
                  //         style: kNormalTextStyle,
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //     EasyStep(
                  //       customStep: ClipRRect(
                  //         borderRadius: BorderRadius.circular(15),
                  //         child: Opacity(
                  //           opacity: activeStep >= 1 ? 1 : 0.3,
                  //           child: Icon(kIconStore),
                  //         ),
                  //       ),
                  //       customTitle: const Text(
                  //         'Business',
                  //         style: kNormalTextStyle,
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //     EasyStep(
                  //       customStep: ClipRRect(
                  //         borderRadius: BorderRadius.circular(15),
                  //         child: Opacity(
                  //           opacity: activeStep >= 2 ? 1 : 0.3,
                  //           child: Image.asset('images/plane.png'),
                  //         ),
                  //       ),
                  //       customTitle: const Text(
                  //         'Dash 3',
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //     // EasyStep(
                  //     //   customStep: ClipRRect(
                  //     //     borderRadius: BorderRadius.circular(15),
                  //     //     child: Opacity(
                  //     //       opacity: activeStep >= 3 ? 1 : 0.3,
                  //     //       child: Image.asset('images/plane.png'),
                  //     //     ),
                  //     //   ),
                  //     //   customTitle: const Text(
                  //     //     'Dash 4',
                  //     //     textAlign: TextAlign.center,
                  //     //   ),
                  //     // ),
                  //     // EasyStep(
                  //     //   customStep: ClipRRect(
                  //     //     borderRadius: BorderRadius.circular(15),
                  //     //     child: Opacity(
                  //     //       opacity: activeStep >= 4 ? 1 : 0.3,
                  //     //       child: Image.asset('images/plane.png'),
                  //     //     ),
                  //     //   ),
                  //     //   customTitle: const Text(
                  //     //     'Dash 5',
                  //     //     textAlign: TextAlign.center,
                  //     //   ),
                  //     // ),
                  //   ],
                  //   onStepReached: (index) => setState(() => activeStep = index),
                  // ),
                  // Stepper (
                  //   connectorThickness: 0.2,
                  //
                  //
                  //   connectorColor: CommonFunctions().convertToMaterialStateProperty(kBlueDarkColor),
                  //   steps: stepsData,
                  //   // stepsData,
                  //   type: StepperType.horizontal,
                  //   currentStep: currentStep,
                  //   onStepTapped: (step) {
                  //     print("onStepTapped : " + step.toString());
                  //   },
                  //   onStepContinue: () {
                  //
                  //     if (currentStep == 0) {
                  //       // CommonFunctions().uploadStageChanges(id, Provider.of<AiProvider>(context, listen: false).appointmentDate, currentStep + 1);
                  //       setState(() {currentStep < stepsData.length - 1 ? currentStep += 1 : currentStep = 0;
                  //       });
                  //     } else {
                  //
                  //       setState(() {currentStep < stepsData.length - 1 ? currentStep += 1 : currentStep = 0;
                  //       });
                  //     }
                  //     // Create a switch statement to handle the different cases
                  //     // if (Provider.of<AiProvider>(context, listen: false).welcomeFacts.contains(false)){
                  //     Get.snackbar('Oops', 'You have not read the rules and plan schedule yet, or set a date for the challenge',
                  //         snackPosition: SnackPosition.BOTTOM,
                  //         backgroundColor: kCustomColor,
                  //         colorText: kBlack,
                  //         icon: Icon(Icons.dangerous_rounded, color: kAppPinkColor,));
                  //
                  //   },
                  //   onStepCancel: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeToBusinessPilot extends StatelessWidget {
  const WelcomeToBusinessPilot({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kLargeHeightSpacing,
          Text('Welcome Fruts Express',style: kHeading2TextStyle.copyWith(color:  kBlack, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize:20),),
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
            },
              child: Text("Go to Business Setup", style: kNormalTextStyle.copyWith(color: kPureWhiteColor),),



          )
        ],
      ),
    );
  }
}
