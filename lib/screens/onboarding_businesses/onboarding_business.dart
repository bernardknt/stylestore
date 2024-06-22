import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/utilities/constants/icon_constants.dart';
import '../../Utilities/constants/font_constants.dart';
import '../../utilities/constants/word_constants.dart';
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
  late List<Step> stepsData;
  int activeStep = 0;
  double progress = 0.1;
  List<String> message = [
    "Welcome to Business Pilot",
    "Add Business Details",
    "Your Employment",
    "Finish",
  ];
  List<Widget> display = [
    WelcomeToBusinessPilot(),
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

  // Track completion status of each step
  List<bool> stepCompleted = [false, false, false, false];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundGreyColor,
      appBar: AppBar(
        backgroundColor: kBackgroundGreyColor,
        elevation: 0,
        title: Text(
          message[Provider.of<StyleProvider>(context, listen: true).onboardingIndex],
          style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: kBackgroundGreyColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width > 600
                    ? 700
                    : MediaQuery.of(context).size.width * 1,
                child: Card(
                  elevation: 10,
                  color: kPureWhiteColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: EasyStepper(
                          activeStep:
                          Provider.of<StyleProvider>(context, listen: true)
                              .onboardingIndex,
                          direction: Axis.horizontal,
                          activeStepBorderColor: kAppPinkColor,
                          finishedStepBackgroundColor: kBlueDarkColor,
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
                          steps: [
                            EasyStep(
                              customStep: Image.asset(
                                "images/pilot2.png",
                                height: 30,
                                fit: BoxFit.fitHeight,
                              ),
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
                            ),
                          ],
                          onStepReached: (index) {
                            // Allow moving to the next step only if the current step is completed
                            if (stepCompleted[index - 1] || index == 0) {
                              setState(() {
                                Provider.of<StyleProvider>(context, listen: false).setOnboardingIndex(index);
                              });
                            } else {
                              // Show an alert or message to complete the current step
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please complete the current step before moving to the next.'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: display[
                        Provider.of<StyleProvider>(context, listen: true)
                            .onboardingIndex],
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
      children: [
        kLargeHeightSpacing,
        Text(
          'Welcome Aboard',
          style: kHeading2TextStyle.copyWith(
              color: kBlack,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            cWelcomeOnboard,
            softWrap: true,
            textAlign: TextAlign.left,
            style: kNormalTextStyle.copyWith(
              color: kBlack,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
                "images/pilot2.png",
                height: 30,
                fit: BoxFit.fitHeight,
              ),
              Image.asset(
                "images/signature.png",
                height: 30,
                fit: BoxFit.fitHeight,
              )
            ],
          ),
        ),
        kLargeHeightSpacing,
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: CommonFunctions()
                  .convertToMaterialStateProperty(kAppPinkColor)),
          onPressed: () {
            // Mark step as completed and move to the next step
            setState(() {
              _OnboardingStepperState().stepCompleted[0] = true;
              Provider.of<StyleProvider>(context, listen: false).setOnboardingIndex(1);
            });
          },
          child: Text(
            "Go to Business Setup",
            style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
          ),
        )
      ],
    );
  }
}

