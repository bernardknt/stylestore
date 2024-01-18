
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylestore/model/common_functions.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/sign_in_options/sign_in_page.dart';

import 'package:stylestore/utilities/constants/color_constants.dart';
import 'package:stylestore/utilities/constants/font_constants.dart';
import 'package:stylestore/widgets/TicketDots.dart';

import '../model/beautician_data.dart';
import '../utilities/constants/icon_constants.dart';
import '../utilities/constants/user_constants.dart';
import '../widgets/order_contents.dart';
import 'add_service.dart';
import 'service_edit_page.dart';
import 'package:intl/intl.dart';

class ServicesPage extends StatefulWidget {
  static String id = 'stock_page';

  @override

  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {

  var id = [];
  var basePriceList = [];
  var info = [];
  var itemName = [];
  var colour = [];
  var minimumQuantity = [];
  List<Map> items = [];
  var price = [];
  var formatter = NumberFormat('#,###,000');
  var storeId = '';



  void defaultsInitiation () async{
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString(kStoreIdConstant) ?? 'Hi';
    bool newIsCheckedIn = prefs.getBool(kIsCheckedIn) ?? false;
    if (newIsCheckedIn == false){
      Navigator.pushNamed(context, SignInUserPage.id);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultsInitiation();

  }
  @override
  Widget build(BuildContext context) {
    var kitchenData = Provider.of<BeauticianData>(context);
    var kitchenDataSet = Provider.of<BeauticianData>(context, listen: false);
    CollectionReference customerOrderStatus = FirebaseFirestore.instance.collection('orders');
    Future<void> changeOrderStatus(status) {
      // Call the user's CollectionReference to add a new user
      return customerOrderStatus.doc(kitchenData.orderNumber).update({
        "status": status
      })
          .then((value) => print("Status Changed"))
          .catchError((error) => print("Failed to change status: $error"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: kAppPinkColor,
            onPressed: (){
              // add Ingredient Here
              Provider.of<StyleProvider>(context, listen: false).resetServiceUploadItem();
              Navigator.pushNamed(context, AddServicePage.id);
              //Navigator.pushNamed(context, InputPage.id);
            },
            child: Icon(CupertinoIcons.add, color: kPureWhiteColor,)
        ),
      // appBar:AppBar(
      //   title: Text('Ingredients'),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //
      // ),
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').where('active', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
          );
        } else {
          id = [];
          basePriceList = [];
          info = [];
          itemName = [];
          minimumQuantity = [];
          items = [];
          colour = [];
          var services = snapshot.data!.docs;
          for (var service in services) {
           if (service.get('storeId') == storeId){
              id.add(service.get('id'));
              basePriceList.add(service.get('basePrice'));
              info.add(service.get('info'));
              itemName.add(service.get('name'));
              minimumQuantity.add(3);
              items.add(service.get('options'));
              price.add(0);
              colour.add(Colors.black45);
           } else{

           }
          }
          return ListView.builder(
              itemCount: id.length,
              shrinkWrap: true ,
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: (){
                    kitchenDataSet.changeItemDetails( itemName[index], basePriceList[index],  info[index], minimumQuantity[index], id[index],  price[index],"", false, false);
                    Navigator.pushNamed(context, ServicesEditPage.id);
                     // showItemFunc(context, itemName[index], quantity[index], info[index]);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),

                      child: Column(

                        children: [
                          TicketDots(
                            mainColor: kFaintGrey,
                            circleColor: kPureWhiteColor,),
                          Stack(
                            children: [
                              ListTile(
                                //title: Text(itemName[index]),
                                leading: Container(

                                  width: 20,
                                  
                                  child:
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      Text('${index + 1}'),
                                      // Expanded(child: Text(itemName[index],overflow: TextOverflow.clip, style: kNormalTextStyleDark.copyWith(fontSize: 15),)),
                                      // //Text(' (${units[index]})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colour[index]),),
                                    ],
                                  ),
                                ),
                                title: Text(itemName[index], style: kNormalTextStyleMoney.copyWith(fontSize: 16),),
                                subtitle: Container(
                                  child:
                                  ListView.builder(

                                      shrinkWrap: true,
                                      itemCount: items[index].keys.toList().length,
                                      itemBuilder: (context, i){
                                        return OrderedContentsWidget(
                                            orderIndex: i + 1,
                                            productDescription: '1',
                                            productName: items[index].keys.toList()[i],
                                            price:items[index].values.toList()[i]);
                                      }),
                                ),
                                // Text("${items[index].keys.toList()}", style: kNormalTextStyleMoney.copyWith(color: kFaintGrey)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // QuantityBtn(onTapFunction: (){}, text: '+', size: 35),
                                    // SizedBox(width: 5,),
                                    Text('${formatter.format(basePriceList[index])}', style: kNormalTextStyleDark,),
                                    // SizedBox(width: 5,),
                                    // QuantityBtn(onTapFunction: (){}, text: '-', size: 35)
                                  ],
                                ),
                ),
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                      onTap: (){
                                        CoolAlert.show(
                                            lottieAsset: 'images/question.json',
                                            context: context,
                                            type: CoolAlertType.success,
                                            text: "Are you sure you want to remove this from your services list",
                                            title: "Remove Item?",
                                            confirmBtnText: 'Yes',
                                            confirmBtnColor: Colors.red,
                                            cancelBtnText: 'Cancel',
                                            showCancelBtn: true,
                                            backgroundColor: kAppPinkColor,
                                            onConfirmBtnTap: (){
                                              // Provider.of<BlenditData>(context, listen: false).deleteItemFromBasket(blendedData.basketItems[index]);
                                              // FirebaseServerFunctions().removePostFavourites(docIdList[index],postId[index], userEmail);
                                              CommonFunctions().removeDocumentFromServer(id[index], 'services');

                                              Navigator.pop(context);
                                            }
                                        );

                                      },

                                      child: kIconCancel)),
                            ],
                          ),

                        ],
                      )
                  )
                );
              });
        }
      }
      )
    );

  }

}

