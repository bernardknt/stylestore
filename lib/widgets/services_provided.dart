import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numeral/numeral.dart';

import 'package:provider/provider.dart';


import '../model/styleapp_data.dart';
import '../utilities/basket_items.dart';
import '../utilities/constants/font_constants.dart';



class ServicesProvidedList extends StatefulWidget {
  ServicesProvidedList({required this.services, required this.boxColors,  required this.type, });
  //required this.provider,
  final List services;
  final List<Color> boxColors;
  // final List<dynamic> provider;
  final String type;

  @override
  State<ServicesProvidedList> createState() => _ServicesProvidedListState();
}

class _ServicesProvidedListState extends State<ServicesProvidedList> {
  // var prices = ['30k','23k', '45k', '90k'];
  var boxColors = [Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white];
  var optionPrices = [];
  var optionNames = [];

  @override
  Widget build(BuildContext context) {
    var styleData = Provider.of<StyleProvider>(context, listen: false);
    var styleDataChanged = Provider.of<StyleProvider>(context);


    return SizedBox(
      height: 50.0,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.services.length,
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              onLongPress: (){

                if (widget.type == 'main' ){

                  // Provider.of<BlenditData>(context, listen: false).changeSaladBoxColorMeat(boxColors[index], index, ingredients[index]);
                }
                else if (widget.type == 'other' ){

                  // Provider.of<BlenditData>(context, listen: false).changeSaladBoxColorLeaves(boxColors[index], index, ingredients[index]);
                }else{

                  // Provider.of<BlenditData>(context, listen: false).changeSaladBoxColorExtras(boxColors[index], index, ingredients[index]);
                }
              },
              onTap: (){
                // This gets a map of the data containing the options
                Map optionsDataStored = styleData.servicesOptions[index];
                // We need to convert this data to an array of information
                optionPrices = optionsDataStored.values.toList();
                optionNames = optionsDataStored.keys.toList();
                var serviceName = widget.services[index];

                var boxIndex = index; // This is the number of the box in the array




                if (styleData.servicesOptions[index].length == 0){
                  print('The product has no Value');
                  var box = optionsDataStored.values.toList();
                  print(optionsDataStored.values);
                  print(box);

                } else {
                  showDialog(context: context, builder: (BuildContext context)
                  {
                    return
                      AlertDialog(

                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Image.asset('images/blender_component.png', height: 25, width: 25,),
                              // SizedBox(width: 5,),
                              Expanded(
                                child: Text('Select a ${widget.services[index]} option (Ugx)',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.fade,
                                  style: kHeading2TextStyle,),
                              ),
                            ],
                          ),
                          content:
                          Container(
                            height: 250.0, // Change as per your requirement
                            width: 300.0,

                            child: Stack(
                              children: [
                                ListView.builder(
                                    itemCount: optionNames.length,
                                    shrinkWrap: true,
                                    primary: false,
                                    //blendedData.saladIngredientsNumber,
                                    itemBuilder: (context, index){
                                      return CheckboxListTile(

                                        activeColor: Colors.green,
                                        value: styleDataChanged.servicesOptionsCheckbox[boxIndex][index],
                                        onChanged: (value){
                                          // This changes the value of the checkbox
                                          styleData.setServicesOptionsCheckbox(boxIndex,value, index, BasketItem(amount: optionPrices[index], quantity: 1, name: serviceName, details: optionNames[index], tracking: false));
                                          // styleData.addToServiceBasket(BasketItem(amount: optionPrices[index], quantity: 1, name: serviceName, details: optionNames[index]));
                                          styleData.setBoxColorMainServices(boxColors[boxIndex], boxIndex, index);
                                          Navigator.pop(context);

                                        },
                                        title:Text('${optionNames[index]} - ${Numeral(optionPrices[index]).format() } ',
                                          overflow: TextOverflow.fade,
                                          textAlign: TextAlign.start,style: kNormalTextStyleDark,),
                                      );
                                    }),
                              ],
                            ),
                          )


                      );
                  });
                }


              },
              child: Container(
                //height: 130,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20 ),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: styleDataChanged.boxColourMainList[index]
                  // provider[index]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      widget.services[index], textAlign: TextAlign.justify,style: kHeadingTextStyle,
                    ),
                    Text(
                      'from ${Numeral(styleData.servicesBasePrice[index]).format()}', textAlign: TextAlign.justify,style: kNormalTextStyleSmallGrey,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

