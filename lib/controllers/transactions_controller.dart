
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:line_icons/line_icons.dart';
import 'package:stylestore/screens/transaction_offline.dart';

import 'package:stylestore/screens/transactions_pages/new_transactions_page.dart';
import 'package:stylestore/screens/transactions_pages/unpaid_transactions_page.dart';

import '../model/common_functions.dart';
import '../utilities/constants/color_constants.dart';
import '../widgets/locked_widget.dart';






class TransactionsController extends StatefulWidget {
  static String id = 'transactions_controller';
  @override
  _TransactionsControllerState createState() => _TransactionsControllerState();
}

class _TransactionsControllerState extends State<TransactionsController> {
  Map<String, dynamic> permissionsMap = {};

  void defaultInitialization()async{
    permissionsMap = await CommonFunctions().convertPermissionsJson();
    setState(() {

    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return permissionsMap['transactions'] == false ? Scaffold( appBar: AppBar(foregroundColor: kPureWhiteColor, backgroundColor: kAppPinkColor,), body: LockedWidget(page: "Transactions")):DefaultTabController(
      length: 2,
      child:
      Scaffold(

          appBar: AppBar(
            // automaticallyImplyLeading: false,
            toolbarHeight: 40,
            backgroundColor: kBackgroundGreyColor,
            //title: Center(child: Text("Stock Page", style: TextStyle(color: kBiegeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),),),
            bottom: TabBar(
              indicator: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kAppPinkColor, kBackgroundGreyColor]),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.redAccent),

              //indicatorColor: kPinkDarkThemeColor,
              labelColor: kBlueDarkColorOld,
              unselectedLabelColor: kBlueDarkColorOld,
              tabs: [

                Tab(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(Icons.check_circle_outline, size: 16,),
                      SizedBox(width: 4,),
                      Text('All')]
                ),),
                Tab(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(LineIcons.creditCard, size: 20,),
                      SizedBox(width: 4,),
                      Text('Unpaid')]
                ),),


              ],
            ),
          ),
          body: TabBarView(
            children: [
              // TransactionsOnlinePage(),
              NewTransactionsPage(),
              // TransactionsProducts(),
              UnpaidTransactionsPage(),



              // VisaPage(),
            ],
          )
      ),
    );
  }
}
