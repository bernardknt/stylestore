import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/Utilities/constants/color_constants.dart';

import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/utilities/constants/user_constants.dart';

import '../Utilities/constants/font_constants.dart';




class PreferredCountrySelection extends StatefulWidget {
  @override
  _PreferredCountrySelectionState createState() =>
      _PreferredCountrySelectionState();
}

class _PreferredCountrySelectionState extends State<PreferredCountrySelection> {
  String selectedCountryCode = "+256";
  String selectedCountry = "Uganda";


  defaultInitialization() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
          ),
          Text(
            'To optimize your experience, please select your country.',
            textAlign: TextAlign.center,
            style: kNormalTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          kLargeHeightSpacing,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: kPlainBackground
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  kSmallWidthSpacing,
                  CountryCodePicker(
                    initialSelection: 'UG',
                    favorite: const [
                      "+250",
                      "+256",
                      "+254",
                    ],

                    showCountryOnly: false,
                    // Only show country name (optional)
                    onChanged: (code) {
                      setState(() {
                        selectedCountryCode = code.dialCode!;
                        selectedCountry = code.name!;
                        print("WUUUUWEEEEE: ${code.dialCode}");
                        selectedCountryCode != null
                            ? () => Navigator.pop(context)
                            : null;
                      });
                    },
                  ),
                  kLargeHeightSpacing,
                  Expanded(
                    child: Text(
                      "$selectedCountry",
                    
                      overflow: TextOverflow.fade,
                      style: kNormalTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: kBlack),
                    ),
                  ),
                ],
              ),
            ),
          ),
          kLargeHeightSpacing,
          kLargeHeightSpacing,
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(kAppPinkColor)),
            onPressed: () async{
              final prefs = await SharedPreferences.getInstance();
              String currency = CommonFunctions().getCurrencyCode(selectedCountryCode, context);
              prefs.setString(kCurrency, currency);
              prefs.setString(kCountryCode, selectedCountryCode);
              prefs.setString(kCountry, selectedCountry);
              // CommonFunctions().showSuccessNotification("$selectedCountry selected", "$selectedCountry and currency $currency have been set as your default");
              print("$currency, $selectedCountry");
              Navigator.pop(context);
            },
            child: Text(
              'Confirm $selectedCountry',
              textAlign: TextAlign.center,
              style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
            ),
          ),
        ],
      ),
    );
  }

}
