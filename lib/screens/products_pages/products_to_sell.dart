import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:stylestore/widgets/TicketDots.dart';
import '../../../../../Utilities/constants/color_constants.dart';
import '../../../../../Utilities/constants/font_constants.dart';
import '../../model/styleapp_data.dart';
import '../../utilities/InputFieldWidget.dart';
import '../../utilities/constants/user_constants.dart';

class ProductsToSell extends StatefulWidget {
  @override
  State<ProductsToSell> createState() => _ProductsToSellState();
}

class _ProductsToSellState extends State<ProductsToSell> {
  // VariablesXx
  String title = 'Your';

  String userId = 'md4348a660';

  var amountList = [];
  var storeIdList = [];
  var descList = [];
  var imgList = [];
  var nameList = [];
  var formatter = NumberFormat('#,###,000');

  var containerToShow = Padding(
    padding: EdgeInsets.all(20),
    child: Container(
      child: Text(
        'This Provide has no products',
        textAlign: TextAlign.center,
        style: kHeading2TextStyleBold,
      ),
    ),
  );
  var checkBoxValue = false;
  void defaultsInitiation() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(kStoreIdConstant)!;
  }

  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width * 0.6;
    var styleData = Provider.of<StyleProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: kBackgroundGreyColor,
      floatingActionButton: FloatingActionButton.extended(
        splashColor: kBlueDarkColorOld,
        // foregroundColor: Colors.black,
        backgroundColor: kAppPinkColor,
        //blendedData.saladButtonColour,
        onPressed: () {
        },
        icon: const Icon(
          Iconsax.calendar,
          color: kPureWhiteColor,
        ),
        label: Text(
          'Total',
          style: kNormalTextStyle.copyWith(color: kPureWhiteColor),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.miniCenterFloat,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stores')
              .where('storeId', isEqualTo: styleData.beauticianId)
              .where('active', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {} else {
              amountList = [];
              descList = [];
              imgList = [];
              nameList = [];


              storeIdList = [];
              var appointments = snapshot.data!.docs;
              for (var appointment in appointments) {
                descList.add(appointment.get('description'));
                imgList.add(appointment.get('image'));
                nameList.add(appointment.get('name'));
                storeIdList.add(appointment.get('storeId'));
                //tokenList.add(event.get('subscribers'));
                amountList.add(appointment.get('amount'));
              }
              if (descList != []) {
                containerToShow = Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                      itemCount: imgList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              // showDialogFunc(context, imgList[index], title[index], descList[index], amountList[index], storeIdList[index]);
                            },
                            child: Column(
                              children: [
                                CheckboxListTile(


                                  title: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        child: Text(
                                          nameList[index],
                                          overflow: TextOverflow.clip,
                                          style: kHeadingTextStyle,
                                        ),
                                      ),
                                      InputFieldWidget(leftPadding: 10,
                                          rightPadding: 5,
                                          labelText: 'Ugx',
                                          hintText: '',
                                          keyboardType: TextInputType.number,
                                          controller: '${amountList[index]}',
                                          onTypingFunction: (value) {
                                            // description = value;
                                          }),
                                      InputFieldWidget(leftPadding: 15,
                                          rightPadding: 0,
                                          labelText: 'Qty',
                                          hintText: '',
                                          keyboardType: TextInputType.number,
                                          controller: '1',
                                          onTypingFunction: (value) {
                                            // description = value;
                                          }),
                                    ],
                                  ),
                                  value: checkBoxValue,
                                  activeColor: kBlueDarkColorOld,
                                  checkColor: kAppPinkColor,
                                  onChanged: (bool? value) {
                                    checkBoxValue = value!;
                                    setState(() {
                                      print('Yes');
                                    });
                                  },
                                ),
                                TicketDots(
                                  mainColor: kFaintGrey,
                                  circleColor: kBackgroundGreyColor,
                                  backgroundColor: kBackgroundGreyColor,
                                )
                              ],
                            )

                        );
                      }),
                );
              }
            }
            return containerToShow;
          }),
    );
  }
}

