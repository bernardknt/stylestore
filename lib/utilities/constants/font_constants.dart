// import 'package:flutter/material.dart';
// import 'color_constants.dart';
//
// const kSmallWidthSpacing = SizedBox(width: 5);
// const kMediumWidthSpacing = SizedBox(width: 15);
// const kSmallHeightSpacing = SizedBox(height: 5);
// const kLargeHeightSpacing = SizedBox(height: 15);
//
// double _fontSizeForDevice(BuildContext context, double baseSize) {
//   final screenWidth = MediaQuery.of(context).size.width;
//   if (screenWidth <= 320) {
//     return baseSize * 0.8; // Decrease font size for smaller screens
//   } else if (screenWidth >= 768) {
//     return baseSize * 1.2; // Increase font size for larger screens
//   }
//   return baseSize;
// }
//
// TextStyle kHeadingTextStyle(BuildContext context) => TextStyle(
//   fontSize: _fontSizeForDevice(context, 16),
//   color: kBlack,
//   fontFamily: 'Futura',
//   fontStyle: FontStyle.normal,
// );
//
// TextStyle kHeadingTextStyleGreyDark(BuildContext context) => TextStyle(
//   fontSize: _fontSizeForDevice(context, 14),
//   color: kFaintGrey,
//   fontFamily: 'Futura',
//   fontStyle: FontStyle.normal,
// );
//
// TextStyle kNormalTextStyle(BuildContext context) => TextStyle(
//   fontSize: _fontSizeForDevice(context, 14),
//   color: kFaintGrey,
//   fontFamily: 'Futura',
//   fontStyle: FontStyle.normal,
// );
//
// // Define other TextStyle functions in a similar manner
//
// const kIconSize = 20.0;




import 'package:flutter/material.dart';
import 'color_constants.dart';
const kSmallWidthSpacing = SizedBox(width: 5,);
const kMediumWidthSpacing = SizedBox(width: 15,);
const kSmallHeightSpacing =  SizedBox(height: 5);
const kLargeHeightSpacing =  SizedBox(height: 15);


const kHeadingTextStyle = TextStyle(fontSize: 16, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kHeadingTextStyleGreyDark = TextStyle(fontSize: 14, color: kFaintGrey, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kHeadingTextStyleGreenDark = TextStyle(fontSize: 13, color: kNewGreenThemeColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kHeadingTextStyleBanner = TextStyle(fontSize: 16, color: kPureWhiteColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kHeadingExtraLargeTextStyle = TextStyle(fontSize: 20, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kHeadingTextStyleWhite = TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kHeadingTextStyleGold = TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Futura', fontStyle: FontStyle.normal, shadows: [Shadow(color: kFontGreyColor, blurRadius:7.0 )]);
const kHeading2TextStyleBold = TextStyle(fontSize: 17, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal,fontWeight: FontWeight.normal );
const kHeading4TextStyleBoldLarge = TextStyle(fontSize: 20, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal,fontWeight: FontWeight.normal );
const kHeading3TextStyleBold = TextStyle(fontSize: 13, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal,fontWeight: FontWeight.normal );
const kHeading2TextStyle = TextStyle(fontSize: 16, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyle = TextStyle(fontSize: 15, color: kFontGreyColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleWhiteFavourites = TextStyle(fontSize: 15, color: kPureWhiteColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleWhiteFavouritesItalic = TextStyle(fontSize: 15, color: kAppPinkColor, fontFamily: 'Futura', fontStyle: FontStyle.normal,fontWeight: FontWeight.w100 );
const kNormalTextStyleBoldPink = TextStyle(fontSize: 16, color: kAppPinkColor, fontFamily: 'Futura', fontStyle: FontStyle.normal,  );
const kNormalTextStyleBoldGreen = TextStyle(fontSize: 16, color: kNewGreenThemeColor, fontFamily: 'Futura', fontStyle: FontStyle.normal,  );
const kNormalTextStyleWhiteLabel = TextStyle(fontSize: 15, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleWhitePendingLabel = TextStyle(fontSize: 12, color: kPureWhiteColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleSmall = TextStyle(fontSize: 14, color: kFontGreyColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleExtraSmall = TextStyle(fontSize: 10, color: kFontGreyColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleSmallBlack = TextStyle(fontSize: 14, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleSmallGrey = TextStyle(fontSize: 14, color: kFontGreyColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleExtraSmallGrey = TextStyle(fontSize: 12, color: kFontGreyColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleExtraSmallBabyPink = TextStyle(fontSize: 12, color: kBabyPinkThemeColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleExtraSmallGreen = TextStyle(fontSize: 13, color: kNewGreenThemeColor, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleDark = TextStyle(fontSize: 13, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleMoney = TextStyle(fontSize: 13, color: kBlack, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleWhite = TextStyle(fontSize: 13,  fontFamily: 'Futura', fontStyle: FontStyle.normal);
const kNormalTextStyleWhiteTrends = TextStyle(fontSize: 15,  fontFamily: 'Futura', fontStyle: FontStyle.normal, color: kPureWhiteColor);
const kNormalTextStyleWhiteTrendsSmall = TextStyle(fontSize: 13,  fontFamily: 'Futura', fontStyle: FontStyle.normal, color: kPureWhiteColor);
const kNormalTextStyleWhiteButtons = TextStyle(fontSize: 15,  fontFamily: 'Futura', fontStyle: FontStyle.normal, color: Colors.white);
const kNormalTextStyleWhiteButtonsSmall = TextStyle(fontSize: 13,  fontFamily: 'Futura', fontStyle: FontStyle.normal, color: Colors.white);
const kNormalTextStyleDarkYellow = TextStyle(fontSize: 13, color: Colors.orange, fontFamily: 'Futura', fontStyle: FontStyle.normal, );
const kNormalTextStyleDatesUnavailable = TextStyle(decoration: TextDecoration.lineThrough, fontSize: 13, color: Colors.red, fontFamily: 'Futura', fontStyle: FontStyle.italic, textBaseline: TextBaseline.ideographic);
const kNormalTextStylePhoto = TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Futura', fontStyle: FontStyle.normal,shadows: [Shadow(color: kFontGreyColor, blurRadius: 5)] );
const kHeadingLogo = TextStyle(fontSize: 50, color: Colors.white, fontFamily: 'Quas');
const kPicturesFontNormal = TextStyle(  fontSize: 13,fontFamily: 'Futura',fontWeight: FontWeight.normal, color: Colors.white, shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3.0, color: Color.fromARGB(255, 0, 0, 0),),]);
const kBannersFontNormal = TextStyle(  fontSize: 15,fontFamily: 'Futura',fontWeight: FontWeight.normal, color: kAppPinkColor,);
const kIconSize = 20.0;
