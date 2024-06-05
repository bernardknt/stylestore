



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/Utilities/constants/font_constants.dart';

import '../../Utilities/constants/color_constants.dart';
import '../../controllers/subscription_controller.dart';
import '../../model/styleapp_data.dart';
import '../sign_in_options/sign_in_page.dart';

class OnboardingSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding Complete', style: kNormalTextStyle.copyWith(color: kBlack, fontSize: 20),),
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'You have successfully completed the onboarding process.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Provider.of<StyleProvider>(context, listen: false).setTrialMode();
                  Navigator.pushNamed(context, SignInUserPage.id);
                  showDialog(context: context, builder: (BuildContext context){
                    return
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child:
                          Scaffold(
                              appBar: AppBar(
                                automaticallyImplyLeading: false,
                                backgroundColor: kPureWhiteColor,
                                elevation: 0,
                                centerTitle: true,
                                title: Text("Automate your Business", style: kNormalTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 2, color: kAppPinkColor),),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SubscriptionController(),
                              ))
                      );
                  });

                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Access Your Account',
                  style: kNormalTextStyle.copyWith(color: kBlack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}